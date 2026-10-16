#!/bin/bash
set -e

# ==============================================================================
# EasyWhisper - macOS Tek Komutla Otomatik Kurulum Betiği
# https://github.com/semhfe/easywhisper-mac
# ==============================================================================

echo ""
echo -e "\033[1;36m============================================================\033[0m"
echo -e "\033[1;32m  🎙️  EasyWhisper - macOS Kurulum Sihirbazı\033[0m"
echo -e "\033[1;36m============================================================\033[0m"
echo ""

# 1. macOS Uyumluluk Kontrolü
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "\033[1;31m[HATA] EasyWhisper yalnızca macOS üzerinde çalışır.\033[0m" >&2
    exit 1
fi

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Kaynak dizini belirle (yerel repo mu yoksa curl ile mi çalıştı?)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
TEMP_DIR=""

if [[ ! -f "$SCRIPT_DIR/bin/easywhisper" ]]; then
    echo ">> Kaynak kodlar indiriliyor..."
    TEMP_DIR=$(mktemp -d)
    curl -fsSL https://github.com/semhfe/easywhisper-mac/archive/refs/heads/main.tar.gz | tar -xz -C "$TEMP_DIR" --strip-components=1
    SCRIPT_DIR="$TEMP_DIR"
fi

cleanup_on_exit() {
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup_on_exit EXIT

# 2. Dizinlerin Hazırlanması
echo ">> [1/6] Dizinler oluşturuluyor..."
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/easywhisper"
mkdir -p "$HOME/.easywhisper/models"
mkdir -p "$HOME/Desktop/EasyWhisper_Watch"
mkdir -p "$HOME/Library/LaunchAgents"
mkdir -p "$HOME/Library/Services"

# 3. Bağımlılık Kontrolü (ffmpeg & whisper-cli)
echo ">> [2/6] Bağımlılıklar denetleniyor..."

# Homebrew kontrolü
if ! command -v brew >/dev/null 2>&1; then
    echo -e "\033[1;33m[UYARI] Homebrew bulunamadı.\033[0m"
    echo "Bağımlılıkları kurabilmek için Homebrew önerilir: https://brew.sh"
fi

# ffmpeg
if ! command -v ffmpeg >/dev/null 2>&1; then
    echo ">> ffmpeg kuruluyor (Homebrew ile)..."
    if command -v brew >/dev/null 2>&1; then
        brew install ffmpeg
    else
        echo -e "\033[1;31m[HATA] ffmpeg bulunamadı ve Homebrew yüklü değil. Lütfen 'brew install ffmpeg' yapın.\033[0m" >&2
        exit 1
    fi
else
    echo "   ✓ ffmpeg mevcut: $(command -v ffmpeg)"
fi

# whisper-cli
WHISPER_BIN=""
for candidate in \
    "$(which whisper-cli 2>/dev/null)" \
    "/opt/homebrew/bin/whisper-cli" \
    "/usr/local/bin/whisper-cli" \
    "$HOME/whisper.cpp/build/bin/whisper-cli" \
    "$HOME/whisper.cpp/main"; do
    if [[ -n "$candidate" && -x "$candidate" ]]; then
        WHISPER_BIN="$candidate"
        break
    fi
done

if [[ -z "$WHISPER_BIN" ]]; then
    echo ">> whisper.cpp (Metal hızlandırmalı) kuruluyor (Homebrew ile)..."
    if command -v brew >/dev/null 2>&1; then
        brew install whisper-cpp
        WHISPER_BIN="$(which whisper-cli || echo "/opt/homebrew/bin/whisper-cli")"
    else
        echo -e "\033[1;31m[HATA] whisper-cli bulunamadı ve Homebrew yüklü değil.\033[0m" >&2
        exit 1
    fi
fi
echo "   ✓ whisper-cli mevcut: $WHISPER_BIN"

# 4. Model Kontrolü ve İndirme
echo ">> [3/6] Modeller kontrol ediliyor..."

# Silero VAD Modeli (~885 KB)
VAD_MODEL="$HOME/.easywhisper/models/ggml-silero-v5.1.2.bin"
if [[ ! -f "$VAD_MODEL" ]]; then
    if [[ -f "$HOME/whisper.cpp/models/ggml-silero-v5.1.2.bin" ]]; then
        VAD_MODEL="$HOME/whisper.cpp/models/ggml-silero-v5.1.2.bin"
    else
        echo "   >> Silero VAD modeli indiriliyor (~885 KB)..."
        curl -fsSL "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-silero-v5.1.2.bin" -o "$VAD_MODEL"
    fi
fi
echo "   ✓ VAD modeli hazır: $VAD_MODEL"

# Whisper ggml-large-v3-turbo modeli (~1.5 GB)
TURBO_MODEL="$HOME/.easywhisper/models/ggml-large-v3-turbo.bin"
if [[ ! -f "$TURBO_MODEL" ]]; then
    if [[ -f "$HOME/whisper.cpp/models/ggml-large-v3-turbo.bin" ]]; then
        TURBO_MODEL="$HOME/whisper.cpp/models/ggml-large-v3-turbo.bin"
    else
        echo -e "\033[1;33m>> ggml-large-v3-turbo.bin modeli indirilecek (~1.5 GB)...\033[0m"
        curl -L --progress-bar "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin" -o "$TURBO_MODEL"
    fi
fi
echo "   ✓ Whisper modeli hazır: $TURBO_MODEL"

# 5. Konfigürasyon Dosyası Oluşturma
echo ">> [4/6] Konfigürasyon dosyası kaydediliyor (~/.config/easywhisper/config.env)..."
if [[ ! -f "$HOME/.config/easywhisper/config.env" ]]; then
    cat << EOF > "$HOME/.config/easywhisper/config.env"
# EasyWhisper Yapılandırması
WHISPER_BIN="$WHISPER_BIN"
MODEL_PATH="$TURBO_MODEL"
VAD_MODEL_PATH="$VAD_MODEL"
LANGUAGE="tr"
PROMPT="Keep original language. No translation."
ENTROPY_THRESHOLD="2.8"
MAX_CONTEXT="64"
KEEP_AUDIO="false"
OUTPUT_TXT="false"
EOF
else
    # Mevcut config varsa koru, eksik anahtarları ekle
    touch "$HOME/.config/easywhisper/config.env"
    grep -q "^KEEP_AUDIO=" "$HOME/.config/easywhisper/config.env" || echo 'KEEP_AUDIO="false"' >> "$HOME/.config/easywhisper/config.env"
    grep -q "^OUTPUT_TXT=" "$HOME/.config/easywhisper/config.env" || echo 'OUTPUT_TXT="false"' >> "$HOME/.config/easywhisper/config.env"
fi

# 6. Komut Satırı Motorunu Kurma
echo ">> [5/6] Motor ve tetikleyiciler yükleniyor..."
cp "$SCRIPT_DIR/bin/easywhisper" "$HOME/.local/bin/easywhisper"
chmod +x "$HOME/.local/bin/easywhisper"
# Geriye dönük uyumluluk için alias
ln -sf "$HOME/.local/bin/easywhisper" "$HOME/.local/bin/ders_srt_uret.sh"

# Droplet Uygulamasını Derleme (Masaüstü)
rm -rf "$HOME/Desktop/Ders SRT Üret.app" 2>/dev/null || true
"$SCRIPT_DIR/app/build_droplet.sh" "EasyWhisper.app" "$HOME/Desktop"

# Finder Hızlı Eylemi (Quick Action)
rm -rf "$HOME/Library/Services/EasyWhisper.workflow"
rm -rf "$HOME/Library/Services/Ders SRT Uret.workflow" 2>/dev/null || true
cp -R "$SCRIPT_DIR/services/EasyWhisper.workflow" "$HOME/Library/Services/EasyWhisper.workflow"

# pbs servisine kaydet
defaults write pbs NSServicesStatus -dict-add '"com.easywhisper.service - EasyWhisper - SRT Üret - runWorkflowAsService"' '{ "enabled_context_menu" = 1; "enabled_services_menu" = 1; }'
defaults write pbs FinderActive -dict-add '"com.easywhisper.service"' 1

# LaunchAgent Yapılandırması
AGENT_PLIST="$HOME/Library/LaunchAgents/com.easywhisper.watch.plist"
sed "s|{{HOME}}|$HOME|g" "$SCRIPT_DIR/launchagent/com.easywhisper.watch.plist.template" > "$AGENT_PLIST"
plutil -lint "$AGENT_PLIST" >/dev/null 2>&1 || true

launchctl unload "$AGENT_PLIST" 2>/dev/null || true
launchctl load "$AGENT_PLIST" 2>/dev/null || true

# 7. Sistem Önbelleklerini Yenileme
echo ">> [6/6] macOS menü önbellekleri yenileniyor..."
/System/Library/CoreServices/pbs -flush 2>/dev/null || true
killall Finder 2>/dev/null || true

echo ""
echo -e "\033[1;32m============================================================\033[0m"
echo -e "\033[1;32m  🎉 EasyWhisper Başarıyla Kuruldu!\033[0m"
echo -e "\033[1;32m============================================================\033[0m"
echo ""
echo "Kullanabileceğiniz Yöntemler:"
echo "  1. 🖱️  Finder Sağ Tık: Herhangi bir video veya ses dosyasına sağ tıklayıp 'EasyWhisper - SRT Üret' seçin."
echo "  2. 📂 Masaüstü Sürükle-Bırak: Medyaları Masaüstündeki 'EasyWhisper.app' simgesine bırakın."
echo "  3. ⚙️  Ayarlar Paneli: 'EasyWhisper.app' simgesine çift tıklayarak ayarları (WAV saklama, TXT, Dil) yapılandırın."
echo "  4. 📥 Otomatik Klasör: Medyaları '~/Desktop/EasyWhisper_Watch' klasörüne atın."
echo "  5. 💻 Terminal: ~/.local/bin/easywhisper <medya_yolu>"
echo ""
