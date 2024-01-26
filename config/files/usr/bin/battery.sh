#!/usr/bin/env bash
# Low battery notifier

# Kill already running processes
already_running="$(ps -fC 'grep' -N | grep 'battery.sh' | wc -l)"
if [[ $already_running -gt 1 ]]; then
        pkill -f --older 1 'battery.sh'
fi

while [[ 0 -eq 0 ]]; do
        battery_status="$(cat /sys/class/power_supply/BAT1/status)"
        battery_charge="$(cat /sys/class/power_supply/BAT1/capacity)"

        if [[ $battery_status == 'Discharging' ]]; then
                if   [[ $battery_charge -le 10 ]]; then
                        notify-send "Battery Critical!" "Battery is at ${battery_charge}%" --app-name "Power Alerts" --urgency "critical" --icon "battery-000"
                        pw-cat -p /usr/share/sounds/speech-dispatcher/prompt.wav
                        powerprofilesctl set power-saver
                        sleep 180
                elif [[ $battery_charge -le 25 ]]; then
                        notify-send "Battery Low!" "Battery is at ${battery_charge}%" --app-name "Power Alerts" --urgency "critical" --icon "battery-010"
                        pw-cat -p /usr/share/sounds/freedesktop/stereo/dialog-warning.oga
                        powerprofilesctl set power-saver
                        sleep 240
                fi
        else
                sleep 600
        fi
done
