#!/usr/bin/env bash

image=$(cat ~/.config/wallpaper)

playerctl -a pause
swaylock -f --image "$image"
