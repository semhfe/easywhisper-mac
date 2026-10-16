#!/bin/zsh
set -e

# ==============================================================================
# EasyWhisper Droplet Derleyici
# https://github.com/semhfe/easywhisper-mac
# ==============================================================================

APP_NAME="${1:-EasyWhisper.app}"
TARGET_DIR="${2:-$HOME/Desktop}"
TARGET_PATH="$TARGET_DIR/$APP_NAME"

echo ">> Droplet derleniyor: $TARGET_PATH"

TMP_SCRIPT=$(mktemp /tmp/easywhisper_droplet_XXXXXX.applescript)

cat << 'EOF' > "$TMP_SCRIPT"
use framework "Foundation"
use framework "AppKit"
use scripting additions

on open droppedFiles
    set runnerPath to "/tmp/easywhisper_" & (do shell script "date +%s") & ".command"
    set cmdFile to open for access POSIX file runnerPath with write permission
    set eof cmdFile to 0
    write "#!/bin/zsh" & linefeed to cmdFile
    repeat with aFile in droppedFiles
        set p to POSIX path of aFile
        write "$HOME/.local/bin/easywhisper " & quoted form of p & linefeed to cmdFile
    end repeat
    write "rm -f \"$0\"" & linefeed to cmdFile
    close access cmdFile
    do shell script "chmod +x " & quoted form of runnerPath & "; open -a Terminal " & quoted form of runnerPath
end open

on run
    -- 1. Mevcut ayarları oku
    set curAudio to (do shell script "source $HOME/.config/easywhisper/config.env 2>/dev/null; echo \"${KEEP_AUDIO:-false}\"")
    set curTxt to (do shell script "source $HOME/.config/easywhisper/config.env 2>/dev/null; echo \"${OUTPUT_TXT:-false}\"")
    set curLang to (do shell script "source $HOME/.config/easywhisper/config.env 2>/dev/null; echo \"${LANGUAGE:-tr}\"")

    -- 2. Pencereyi ön plana getir
    current application's NSApp's activateIgnoringOtherApps:true

    -- 3. NSAlert oluştur
    set myAlert to current application's NSAlert's alloc()'s init()
    myAlert's setMessageText:"EasyWhisper Ayarları"
    myAlert's setInformativeText:("Altyazı ve transkripsiyon tercihlerinizi belirleyin:" & linefeed & "(İşlem yapmak için video veya ses dosyalarını uygulamanın üzerine sürükleyip bırakabilirsiniz.)")
    myAlert's addButtonWithTitle:"Kaydet"
    myAlert's addButtonWithTitle:"Vazgeç"

    -- Aksesuar Görünümü
    set container to current application's NSView's alloc()'s initWithFrame:(current application's NSMakeRect(0, 0, 380, 115))

    -- Checkbox 1: KEEP_AUDIO
    set chkAudio to current application's NSButton's alloc()'s initWithFrame:(current application's NSMakeRect(10, 80, 360, 24))
    chkAudio's setButtonType:(current application's NSSwitchButton)
    chkAudio's setTitle:"Ayrıştırılan ses dosyasını (.wav) sakla"
    if curAudio is "true" or curAudio is "1" then
        chkAudio's setState:1
    else
        chkAudio's setState:0
    end if
    container's addSubview:chkAudio

    -- Checkbox 2: OUTPUT_TXT
    set chkTxt to current application's NSButton's alloc()'s initWithFrame:(current application's NSMakeRect(10, 50, 360, 24))
    chkTxt's setButtonType:(current application's NSSwitchButton)
    chkTxt's setTitle:"Düz metin (.txt) dökümü de üret"
    if curTxt is "true" or curTxt is "1" then
        chkTxt's setState:1
    else
        chkTxt's setState:0
    end if
    container's addSubview:chkTxt

    -- Label: Dil
    set lblLang to current application's NSTextField's alloc()'s initWithFrame:(current application's NSMakeRect(10, 15, 80, 22))
    lblLang's setStringValue:"Model Dili:"
    lblLang's setBezeled:false
    lblLang's setDrawsBackground:false
    lblLang's setEditable:false
    lblLang's setSelectable:false
    container's addSubview:lblLang

    -- PopUpButton: Dil Seçimi
    set popLang to current application's NSPopUpButton's alloc()'s initWithFrame:(current application's NSMakeRect(95, 12, 220, 26)) pullsDown:false
    popLang's addItemsWithTitles:{"Türkçe (tr)", "İngilizce (en)", "Otomatik Algıla (auto)"}
    if curLang is "en" then
        popLang's selectItemAtIndex:1
    else if curLang is "auto" then
        popLang's selectItemAtIndex:2
    else
        popLang's selectItemAtIndex:0
    end if
    container's addSubview:popLang

    myAlert's setAccessoryView:container

    -- 4. Modalı göster
    set userResp to myAlert's runModal()
    if userResp is (current application's NSAlertFirstButtonReturn) then
        set newAudio to "false"
        if (chkAudio's state()) is 1 then
            set newAudio to "true"
        end if

        set newTxt to "false"
        if (chkTxt's state()) is 1 then
            set newTxt to "true"
        end if

        set idx to (popLang's indexOfSelectedItem()) as integer
        set newLang to "tr"
        if idx is 1 then
            set newLang to "en"
        else if idx is 2 then
            set newLang to "auto"
        end if

        set shCmd to "
        f=\"$HOME/.config/easywhisper/config.env\"
        mkdir -p \"$(dirname \"$f\")\"
        touch \"$f\"
        update_cfg() {
            local k=\"$1\"
            local v=\"$2\"
            if grep -q \"^${k}=\" \"$f\"; then
                sed -i '' \"s|^${k}=.*|${k}=\\\"${v}\\\"|\" \"$f\"
            else
                echo \"${k}=\\\"${v}\\\"\" >> \"$f\"
            fi
        }
        update_cfg \"KEEP_AUDIO\" " & quoted form of newAudio & "
        update_cfg \"OUTPUT_TXT\" " & quoted form of newTxt & "
        update_cfg \"LANGUAGE\" " & quoted form of newLang & "
        "
        do shell script shCmd
        display notification "Ayarlar başarıyla güncellendi." with title "EasyWhisper" sound name "Glass"
    end if
end run
EOF

osacompile -o "$TARGET_PATH" "$TMP_SCRIPT"
rm -f "$TMP_SCRIPT"

echo ">> Başarıyla derlendi: $TARGET_PATH"
