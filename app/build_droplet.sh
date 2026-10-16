#!/bin/zsh
set -e

# ==============================================================================
# EasyWhisper Droplet Derleyici
# ==============================================================================

APP_NAME="${1:-EasyWhisper.app}"
TARGET_DIR="${2:-$HOME/Desktop}"
TARGET_PATH="$TARGET_DIR/$APP_NAME"

echo ">> Droplet derleniyor: $TARGET_PATH"

osacompile -o "$TARGET_PATH" -e 'on open droppedFiles
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
    display dialog "Altyazı üretmek istediğiniz videoları bu uygulamanın simgesi üzerine sürükleyip bırakın." with title "EasyWhisper" buttons {"Tamam"} default button "Tamam" with icon note
end run'

echo ">> Başarıyla derlendi: $TARGET_PATH"
