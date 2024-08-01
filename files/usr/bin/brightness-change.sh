#!/usr/bin/env bash

brightness_percent=$(light | LC_ALL=C xargs /usr/bin/printf "%.*f\n" "$p")

notify-send \
    --app-name sway \
    --expire-time 800 \
    --hint string:x-canonical-private-synchronous:volume \
    --hint "int:value:$brightness_percent" \
    --hint "string:category:backlight" \
    --transient \
    "Brightness" "$brightness_percent"
