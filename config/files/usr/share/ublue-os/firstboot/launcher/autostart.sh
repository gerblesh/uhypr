#!/usr/bin/env bash

# Ensure target file exists and is a symlink (not a regular file or dir).
if [ ! -f "$HOME"/.config/ublue-firstboot ]; then

    # add file to prevent firstboot from running again

    touch "$HOME"/.config/ublue-firstboot

    # sed -i " 1 d" "$HOME"/.config/sway/config

    #mkdir -p "$HOME"/.config/just
    #cp -r /usr/share/ublue-os/just/custom.just "$HOME"/.config/just/justfile

    cp -r /usr/etc/homedir/.* "$HOME"/
    cp -r /usr/etc/homedir/* "$HOME"/

    /usr/bin/yafti /usr/share/ublue-os/firstboot/yafti.yml
fi
