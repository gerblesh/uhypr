#!/usr/bin/env fish

# wezterm start --always-new-process --class "floatterm" --cwd ~/Pictures/Wallpapers/Mocha/ fish -ic 'wallpaper (pwd)/(fzf)'

ghostty --title="floatterm" --working-directory="~/Pictures/Wallpapers/Mocha" -e "/bin/fish '-ic cd ~/Pictures/Wallpapers/Mocha && yazi --chooser-file $HOME/.config/wallpaper'"

wallpaper init
