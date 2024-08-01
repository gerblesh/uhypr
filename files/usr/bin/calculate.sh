#!/bin/bash



HISTORY_FILE="$HOME"/.local/share/calc.hist

touch "$HISTORY_FILE"

EQUATION="$(fuzzel --dmenu -l 0 --prompt '󰪚 ')"

echo $EQUATION
if [[ "$EQUATION" == "" ]]; then
    echo "Not wow"
    exit 1
fi

RESULT="$(/home/linuxbrew/.linuxbrew/bin/qalc "$EQUATION")" 
RETURNCODE="$?"
if [[ "$RETURNCODE" != 0 ]]; then
    echo "qalc returned bad"
    exit $RETURNCODE
fi

notify-send --app-name "Qalculate" "Calculation Complete" "$RESULT"
echo "$RESULT" >> "$HISTORY_FILE"

echo "$RESULT" | cat "$HISTORY_FILE" | fuzzel --dmenu --prompt="󱝩󰪚 " | wl-copy
