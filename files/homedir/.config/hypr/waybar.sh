PID=$(pidof waybar)
kill $PID
waybar --config ~/.config/waybar/config.hypr --style ~/.config/waybar/style.css.hypr
