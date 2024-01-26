#!/usr/bin/env bash


FILE="$(grimshot save $1)"

if [[ -f "$FILE" ]]; then
    cat $FILE | wl-copy
    notify-send "Screenshot" "Screenshot taken, copied to clipboard and saved in Pictures folder" --icon "$FILE" --app-name "screenshot.sh"
fi
