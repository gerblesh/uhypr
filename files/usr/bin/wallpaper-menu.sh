#!/usr/bin/env fish

#wezterm start --class "floatterm" --cwd ~/Pictures/Wallpapers/Mocha/ fish -ic 'wallpaper (pwd)/(fzf)'
foot -w 1000x1000 --app-id "floatterm" -D ~/Pictures/Wallpapers/Mocha/ fish -ic 'wallpaper (pwd)/(fzf)'

wallpaper init
