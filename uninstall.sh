#!/bin/bash
set -e

# ==============================================================================
# EasyWhisper - macOS Kaldırma (Uninstall) Betiği
# ==============================================================================

echo ""
echo -e "\033[1;33mEasyWhisper kaldırılıyor...\033[0m"

# LaunchAgent durdur ve sil
launchctl unload "$HOME/Library/LaunchAgents/com.easywhisper.watch.plist" 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/com.easywhisper.watch.plist"

# Finder Hızlı Eylemleri temizle
rm -rf "$HOME/Library/Services/EasyWhisper.workflow"
/System/Library/CoreServices/pbs -flush 2>/dev/null || true

# Masaüstü Droplet uygulamasını sil
rm -rf "$HOME/Desktop/EasyWhisper.app"

# Binary sil
rm -f "$HOME/.local/bin/easywhisper"

echo -e "\033[1;32m✓ EasyWhisper tetikleyicileri ve komutları başarıyla kaldırıldı.\033[0m"

read -p "İndirilen yapay zeka modellerini de silmek istiyor musunuz? (~1.5 GB) [e/H]: " confirm
if [[ "$confirm" =~ ^[eEyY]$ ]]; then
    rm -rf "$HOME/.easywhisper"
    rm -rf "$HOME/.config/easywhisper"
    echo "✓ Model ve ayar dosyaları temizlendi."
else
    echo "• Modeller saklandı (~/.easywhisper/models)."
fi

killall Finder 2>/dev/null || true
echo "Tamamlandı."
