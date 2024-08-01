#!/usr/bin/env bash



volume="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')"

volume_muted="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $3}')"
volume_percent=$(echo "$volume * 100" | bc | LC_ALL=C xargs /usr/bin/printf "%.*f\n" "$p")
volume_string="$volume_percent $volume_muted"
category="volume"

if [ -n "$volume_muted" ]; then
    category="volume-muted"
fi

notify-send \
    --app-name sway \
    --expire-time 800 \
    --hint string:x-canonical-private-synchronous:volume \
    --hint "int:value:$volume_percent" \
    --hint "string:category:$category" \
    --transient \
    "Volume" "$volume_string"
