#!/usr/bin/env bash


FILE="$(grimshot save $1)"

if [[ -f "$FILE" ]]; then
    cat $FILE | wl-copy
fi
