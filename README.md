# 🎙️ EasyWhisper for macOS

[![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon%20%2F%20Intel-black?logo=apple&style=flat-square)](https://apple.com)
[![Whisper.cpp](https://img.shields.io/badge/Engine-whisper.cpp%20(Metal%20GPU)-blue?style=flat-square)](https://github.com/ggml-org/whisper.cpp)
[![Model](https://img.shields.io/badge/Model-ggml--large--v3--turbo-orange?style=flat-square)](https://huggingface.co/ggerganov/whisper.cpp)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)

Mac'inizdeki tüm video (`.mp4`, `.mkv`, `.mov`, `.avi`, `.webm`) ve ses kayıtlarınızı (`.mp3`, `.wav`, `.m4a`, `.aac`, `.flac`, `.ogg`) **tamamen yerel**, **Apple Silicon Metal GPU hızlandırmalı** `whisper.cpp` (`ggml-large-v3-turbo`) ve `Silero VAD` ile zaman damgalı `.srt` altyazılarına ve düz metin dökümlerine (`.txt`) dönüştüren hepsi bir arada macOS otomasyonu.

> 🔒 **%100 Gizlilik:** Hiçbir ses veya veri buluta gitmez, tüm işlem Mac'inizin yerel donanımı üzerinde gerçekleşir.

---

## ⚡ Hızlı Kurulum (Tek Komut)

Terminal'inizi açın ve aşağıdaki komutu yapıştırın:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/semhfe/easywhisper-mac/main/install.sh)"
```

### Alternatif (Git ile):
```bash
git clone https://github.com/semhfe/easywhisper-mac.git
cd easywhisper-mac
./install.sh
```

---

## 🚀 Yeni Özellikler (v1.1)

- **🖱️ Finder Sağ Tık Entegrasyonu:** Herhangi bir video veya ses dosyasına sağ tıklayıp *"EasyWhisper - SRT Üret"* demeniz yeterli.
- **🎵 Doğrudan Ses Desteği & Akıllı Geçiş (Smart Bypass):** `.mp3`, `.wav`, `.ogg`, `.flac` gibi doğrudan desteklenen ses formatlarında ffmpeg video ayrıştırma adımı atlanır ve doğrudan transkripsiyona başlanır.
- **⚙️ Çift Tık Ayarlar Paneli (Native UI):** Masaüstündeki `EasyWhisper.app` simgesine çift tıkladığınızda yerel macOS ayar penceresi açılır:
  - `[ ] Ayrıştırılan ses dosyasını (.wav) sakla (KEEP_AUDIO)`
  - `[ ] Düz metin (.txt) dökümü de üret (OUTPUT_TXT)`
  - `Model Dili Seçimi (Türkçe, İngilizce, Otomatik Algıla)`
- **📂 Masaüstü Droplet Uygulaması (`EasyWhisper.app`):** Medya dosyalarını simgenin üzerine sürükleyip bırakarak anında transkripsiyon başlatın.
- **📥 Otomatik İzlenen Klasör (`EasyWhisper_Watch`):** Masaüstündeki bu klasöre atılan veya indirilen video/ses dosyaları otomatik olarak algılanıp altyazısı yanına oluşturulur.
- **🖥️ Canlı Akış Terminal Penceresi:** Transkripsiyon anında canlı ilerleme ve konuşulan metinler zaman damgalarıyla renkli Terminal penceresinde anlık akar.
- **🛡️ Silero VAD (Voice Activity Detection):** Sessiz anlarda modelin halüsinasyon görmesini ve altyazı zaman damgalarının kaymasını önler.
- **⚡ M-Serisi Metal GPU Hızlandırması:** Apple Silicon (M1, M2, M3, M4) çipleri üzerinde maksimum performans.
- **🔔 macOS Bildirimleri & Finder Gösterimi:** İşlem tamamlandığında sesli uyarı ("Glass") çalar ve oluşan `.srt` dosyası Finder'da seçili olarak açılır.

---

## 🕹️ Nasıl Kullanılır?

| Yöntem | Nasıl Yapılır? |
|---|---|
| **Finder Sağ Tık** | Finder'da video veya ses dosyasına sağ tıklayın ➔ **Hızlı Eylemler (Quick Actions)** ➔ **EasyWhisper - SRT Üret** |
| **Sürükle-Bırak** | Medyaları Masaüstündeki **EasyWhisper.app** simgesi üzerine bırakın |
| **Ayarlar Paneli** | Masaüstündeki **EasyWhisper.app** simgesine **çift tıklayın** |
| **Otomatik Klasör** | Medyaları Masaüstündeki **`EasyWhisper_Watch`** klasörüne taşıyın |
| **Terminal (CLI)** | `easywhisper /path/to/media.mp4` |

---

## ⚙️ Yapılandırma (`config.env`)

Ayarlarınızı arayüzden veya doğrudan `~/.config/easywhisper/config.env` dosyasından dilediğiniz zaman değiştirebilirsiniz:

```bash
# Dil seçimi (tr, en, auto vb.)
LANGUAGE="tr"

# Ekstra Çıktı Ayarları
KEEP_AUDIO="false"      # true yapılırsa videodan ayrıştırılan .wav silinmez, videonun yanında saklanır
OUTPUT_TXT="false"      # true yapılırsa .srt'nin yanında .txt düz metin dökümü de oluşturulur

# Model yolları
WHISPER_BIN="/opt/homebrew/bin/whisper-cli"
MODEL_PATH="$HOME/.easywhisper/models/ggml-large-v3-turbo.bin"
VAD_MODEL_PATH="$HOME/.easywhisper/models/ggml-silero-v5.1.2.bin"

# Teknik terimlerin çevrilmesini önleme komutu
PROMPT="Keep original language. No translation."

# Tekrar döngülerini önleme eşikleri
ENTROPY_THRESHOLD="2.8"
MAX_CONTEXT="64"
```

---

## 🗑️ Kaldırma (Uninstall)

Sistemi kaldırmak isterseniz:

```bash
cd easywhisper-mac && ./uninstall.sh
```
Veya:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/semhfe/easywhisper-mac/main/uninstall.sh)"
```

---

## 📄 Lisans

Bu proje [MIT Lisansı](LICENSE) altında sunulmaktadır.
