# EasyWhisper macOS v1.1 Geliştirmeleri Uygulama Planı

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** EasyWhisper'a isim genelleştirmesi ("SRT Üret"), doğrudan ses dosyası desteği (.mp3, .wav, .m4a, .aac, .flac, .ogg), akıllı ffmpeg bypass mekanizması ve çift tıklamayla açılan yerel macOS ayarlar paneli (KEEP_AUDIO, OUTPUT_TXT, Dil) eklemek.

**Architecture:** 
- Finder Quick Action (`services/EasyWhisper.workflow`) `NSSendFileTypes` genişletilerek `public.movie` yanına `public.audio` eklenir. Menü adı "EasyWhisper - SRT Üret" olarak güncellenir.
- Çekirdek motor (`bin/easywhisper`), girdi dosyasının uzantısını analiz eder. Eğer dosya `whisper-cli` tarafından doğrudan desteklenen bir ses formatıysa (`.wav`, `.mp3`, `.ogg`, `.flac`), gereksiz ffmpeg dönüştürme adımını atlayıp doğrudan transkripsiyona geçer. `KEEP_AUDIO=true` ise ffmpeg ile ayrıştırılan WAV dosyasını kalıcı olarak medyanın yanında saklar. `OUTPUT_TXT=true` ise `-otxt` bayrağını ekleyerek `.txt` dosyası üretir.
- Masaüstü Droplet uygulaması (`app/build_droplet.sh`), AppleScriptObjC (`AppKit`) kullanarak yerel bir NSAlert ayar penceresi sunar. Çift tıklandığında mevcut `~/.config/easywhisper/config.env` değerlerini okuyup checkbox ve açılır liste ile gösterir, kaydedildiğinde dosyayı günceller.
- Kurulum sihirbazı (`install.sh`), kaldırma betiği (`uninstall.sh`) ve dokümantasyon (`README.md`) yeni yeteneklere göre senkronize edilir, test edilip GitHub'a pushlanır.

**Tech Stack:** macOS zsh, AppleScript / AppleScriptObjC (AppKit NSAlert), Automator Quick Action, Whisper.cpp CLI (Metal GPU), FFmpeg, Git/GitHub CLI.

## Global Constraints
- Yalnızca macOS yerel araçları ve bağımlılıkları (`whisper-cli`, `ffmpeg`, `osacompile`) kullanılır.
- Kullanıcı-yüzü metinlerde "Ders" kelimesi tamamen kaldırılır ve "SRT Üret" / "EasyWhisper" terminolojisi benimsenir.
- Geriye dönük uyumluluk korunur (`~/.local/bin/ders_srt_uret.sh` alias'ı korunur, eski yapılandırma dosyaları bozulmadan okunur).
- Ayarlar paneli harici üçüncü parti bağımlılık (Python UI, Electron vb.) gerektirmeden tamamen yerel AppleScriptObjC ile çalışır.

---

### Task 1: İsim Genelleştirmesi ve Finder Servisi Güncellemesi
**Files:**
- Modify: `services/EasyWhisper.workflow/Contents/Info.plist`
- Modify: `install.sh`
- Modify: `uninstall.sh`

**Interfaces:**
- Consumes: Finder Context Menu
- Produces: "EasyWhisper - SRT Üret" Finder servisi; `public.movie` ve `public.audio` dosya tipleri

- [ ] **Step 1: Info.plist dosyasında servis adını "EasyWhisper - SRT Üret" ve dosya tiplerini `public.movie` + `public.audio` yap**
- [ ] **Step 2: `install.sh` içindeki pbs kayıt anahtarını güncelle ve eski "Ders SRT Üret" kalıntılarını temizle**
- [ ] **Step 3: `uninstall.sh` betiğinde olası eski masaüstü droplet ve servis kalıntılarını da temizle**
- [ ] **Step 4: Doğrulama: `plutil -lint services/EasyWhisper.workflow/Contents/Info.plist` çalıştır ve doğrula**
- [ ] **Step 5: Commit:** `git commit -m "feat: generalize naming to 'SRT Uret' and support audio types in quick action"`

---

### Task 2: bin/easywhisper Motorunda Doğrudan Ses Desteği, Akıllı Bypass, KEEP_AUDIO ve OUTPUT_TXT
**Files:**
- Modify: `bin/easywhisper`
- Modify: `launchagent/com.easywhisper.watch.plist.template`

**Interfaces:**
- Consumes: `~/.config/easywhisper/config.env` (`KEEP_AUDIO`, `OUTPUT_TXT`, `LANGUAGE`)
- Produces: `${base_no_ext}.srt`, opsiyonel `${base_no_ext}.txt`, opsiyonel `${base_no_ext}.wav`

- [ ] **Step 1: `config.env` okuma bloğuna `KEEP_AUDIO` ve `OUTPUT_TXT` değişkenlerini ekle**
- [ ] **Step 2: `bin/easywhisper` içindeki `scan_directory` ve dosya işleme fonksiyonunu ses dosyası uzantılarını (`.mp3`, `.wav`, `.m4a`, `.aac`, `.flac`, `.ogg`) kapsayacak şekilde güncelle**
- [ ] **Step 3: Akıllı Geçiş Mantığını Ekle:**
  - Eğer dosya `wav`, `mp3`, `ogg`, `flac` ise ffmpeg ayrıştırma adımını atla, doğrudan `$WHISPER_BIN`'e ver.
  - Eğer dosya video veya m4a/aac gibi ara format ise ffmpeg ile 16kHz mono WAV çıkar.
  - `KEEP_AUDIO="true"` ise oluşturulan WAV dosyasını `/tmp` yerine dosyanın yanına `${base_no_ext}.wav` olarak kaydet ve temizlikte silme.
- [ ] **Step 4: `OUTPUT_TXT="true"` ise `$WHISPER_BIN` komutuna `-otxt` parametresini ekle**
- [ ] **Step 5: Test:** Scratch dizininde oluşturulacak bir MP3 ve bir WAV dosyası üzerinde `bin/easywhisper` çalıştırıp ffmpeg bypass'ını ve çıktı dosyalarını doğrula.
- [ ] **Step 6: Commit:** `git commit -m "feat: add direct audio support, smart bypass, KEEP_AUDIO and OUTPUT_TXT flags"`

---

### Task 3: Masaüstü Droplet Uygulamasına Çift Tık Ayarlar Paneli (AppleScriptObjC)
**Files:**
- Modify: `app/build_droplet.sh`

**Interfaces:**
- Consumes: `~/.config/easywhisper/config.env`
- Produces: `EasyWhisper.app` (Masaüstü Droplet + Çift Tık Ayarlar Paneli)

- [ ] **Step 1: `app/build_droplet.sh` betiğinde `on run` bloğunu AppleScriptObjC `NSAlert` modal penceresiyle yeniden yapılandır:**
  - Checkbox 1: Ayrıştırılan ses dosyasını (.wav) sakla (`KEEP_AUDIO`)
  - Checkbox 2: Düz metin (.txt) dökümü de üret (`OUTPUT_TXT`)
  - Açılır Menü (PopUpButton): Model Dili (`Türkçe`, `İngilizce`, `Otomatik Algıla`)
- [ ] **Step 2: `config.env` dosyasını okuyarak mevcut durumları checkbox ve popup'a yansıt**
- [ ] **Step 3: "Kaydet" tıklandığında `~/.config/easywhisper/config.env` dosyasını atomik/güvenli olarak güncelle ve bildirim göster**
- [ ] **Step 4: `on open droppedFiles` bloğunda ses ve video dosyalarının eksiksiz aktarıldığından emin ol**
- [ ] **Step 5: Test:** `app/build_droplet.sh` ile `EasyWhisper.app` derle ve sözdizimi doğrulamasını tamamla.
- [ ] **Step 6: Commit:** `git commit -m "feat: add native AppleScriptObjC settings dialog on app double-click"`

---

### Task 4: Dokümantasyon, install.sh Senkronizasyonu, Uçtan Uca Doğrulama ve GitHub Push
**Files:**
- Modify: `install.sh`
- Modify: `README.md`

**Interfaces:**
- Consumes: Tüm geliştirilmiş bileşenler
- Produces: Senkronize edilmiş v1.1 deposu ve GitHub main güncellemesi

- [ ] **Step 1: `install.sh` içindeki varsayılan ayarları (`KEEP_AUDIO="false"`, `OUTPUT_TXT="false"`), yeni menü başlığını ve rehber metinlerini güncelle**
- [ ] **Step 2: `README.md` dosyasını yeni özelliklerle (Ses dosyası desteği, Ayarlar paneli ekranı, konfigürasyon parametreleri) zenginleştir**
- [ ] **Step 3: Canlı ortamda `install.sh` çalıştırarak tüm sistemin (Droplet, Service, CLI) güncellendiğini doğrula**
- [ ] **Step 4: Gerçek ses ve video dosyalarıyla uçtan uca smoke test yap**
- [ ] **Step 5: Git commit oluştur ve `git push origin main` ile GitHub'a aktar**
- [ ] **Step 6: Kullanıcıya yapılan değişiklikleri ve kullanım adımlarını raporla**
