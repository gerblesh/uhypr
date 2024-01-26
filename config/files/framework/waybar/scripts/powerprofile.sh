#!/usr/bin/env bash

PROFILE=$(/usr/bin/powerprofilesctl get)

case "$PROFILE" in
power-saver)
    echo '{"text": "󰾆", "tooltip": "Power Saver", "class": "power-saver"}'
    ;;
balanced)
    echo '{"text": "󰾅", "tooltip": "Balanced", "class": "balanced"}'
    ;;
performance) 
    echo '{"text": "󰓅", "tooltip": "Performance", "class": "performance"}'
    ;;
*)
    echo '{"text": "?", "tooltip": "unable to get power profile", "class": "balanced"}'
    ;;
esac
