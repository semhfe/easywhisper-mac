# 🎙️ EasyWhisper for macOS

[![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon%20%2F%20Intel-black?logo=apple&style=flat-square)](https://apple.com)
[![Whisper.cpp](https://img.shields.io/badge/Engine-whisper.cpp%20(Metal%20GPU)-blue?style=flat-square)](https://github.com/ggml-org/whisper.cpp)
[![Model](https://img.shields.io/badge/Model-ggml--large--v3--turbo-orange?style=flat-square)](https://huggingface.co/ggerganov/whisper.cpp)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)

Mac'inizdeki ders, toplantı ve video kayıtlarınızı (`.mp4`, `.mkv`, `.mov`) **tamamen yerel**, **Apple Silicon Metal GPU hızlandırmalı** `whisper.cpp` (`ggml-large-v3-turbo`) ve `Silero VAD` ile zaman damgalı `.srt` altyazılarına dönüştüren hepsi bir arada macOS otomasyonu.

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

## 🚀 Özellikler

- **🖱️ Finder Sağ Tık Entegrasyonu (Quick Action):** Videoya sağ tıklayıp *"EasyWhisper - Altyazı Üret"* demeniz yeterli.
- **📂 Masaüstü Droplet Uygulaması (`EasyWhisper.app`):** Videoları uygulamanın simgesine sürükleyip bırakarak anında transkripsiyon başlatın.
- **📥 Otomatik İzlenen Klasör (`EasyWhisper_Watch`):** Masaüstündeki bu klasöre atılan veya indirilen videolar otomatik olarak algılanıp altyazısı yanına oluşturulur.
- **🖥️ Canlı Akış Terminal Penceresi:** Transkripsiyon anında canlı yüzde ilerlemesi (`progress = %45`) ve konuşulan metinler zaman damgalarıyla Terminal penceresinde anlık akar.
- **🛡️ Silero VAD (Voice Activity Detection):** Sessiz anlarda modelin halüsinasyon görmesini ve altyazı zaman damgalarının kaymasını önler.
- **⚡ M-Serisi Metal GPU Hızlandırması:** Apple Silicon (M1, M2, M3, M4) çipleri üzerinde maksimum performans.
- **🔔 macOS Bildirimleri & Finder Gösterimi:** İşlem tamamlandığında sesli uyarı ("Glass") çalar ve oluşan `.srt` dosyası Finder'da seçili olarak açılır.
- **🔒 Güvenli Dosya Kilitleme:** İndirilmekte olan (`.crdownload`, `.part`, `.download`) dosyalar atlanır ve yarış durumlarını (race condition) engelleyen `.lock` mekanizması kullanılır.

---

## 🕹️ Nasıl Kullanılır?

| Yöntem | Nasıl Yapılır? |
|---|---|
| **Finder Sağ Tık** | Finder'da videoya sağ tıklayın ➔ **Hızlı Eylemler (Quick Actions)** ➔ **EasyWhisper - Altyazı Üret** |
| **Sürükle-Bırak** | Videoyu Masaüstündeki **EasyWhisper.app** simgesi üzerine bırakın |
| **Otomatik Klasör** | Videoları Masaüstündeki **`EasyWhisper_Watch`** klasörüne taşıyın |
| **Terminal (CLI)** | `easywhisper /path/to/video.mp4` |

---

## ⚙️ Yapılandırma

Ayarlarınızı `~/.config/easywhisper/config.env` dosyasından dilediğiniz zaman değiştirebilirsiniz:

```bash
# Dil seçimi (tr, en, auto vb.)
LANGUAGE="tr"

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
