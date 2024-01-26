#!/usr/bin/env bash

CHOICE=$(printf "󰾆 Power Saver\n󰾅 Balanced\n󰓅 Performance" | fuzzel --dmenu --index --prompt " Select Power Profile:  ")

case "$CHOICE" in
    0)
        powerprofilesctl set power-saver
        ;;
    1)
        powerprofilesctl set balanced
        ;;
    2)
        powerprofilesctl set performance
        ;;
esac


