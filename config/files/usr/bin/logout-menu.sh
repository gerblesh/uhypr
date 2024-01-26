#!/usr/bin/env bash


playerctl -a pause

options=" Screen Lock\n󰍃 Logout\n󰤄 Sleep\n⏻ Shutdown\n Restart\n BIOS"

choice=$(printf "$options" | fuzzel --dmenu --index --prompt=" Goodbye!  ")

echo $choice

case $choice in
    0)
        echo "Screenlock"
        /usr/bin/lock.sh 
        ;;
    1)
        echo "Logout"
        swaymsg exit
        ;;
    2)
        echo "Suspend"
        systemctl suspend
        ;;
    3)
        echo "Shutting down.."
        systemctl poweroff 
        ;;
    4)
        echo "Restarting"
        systemctl reboot 
        ;;
    5)
        echo "entering UEFI firmware interface"
        systemctl reboot --firmware-setup
        ;;
esac

