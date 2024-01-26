#!/usr/bin/env bash
NEW_WALLPAPER=$(/usr/bin/ls -1 "$HOME/Pictures/Wallpapers/Mocha" | fuzzel --dmenu --prompt " Select Wallpaper:  ")

/usr/bin/wallpaper "$HOME/Pictures/Wallpapers/Mocha/$NEW_WALLPAPER"
