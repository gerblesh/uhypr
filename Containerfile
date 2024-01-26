FROM ghcr.io/ublue-os/sericea-main:39

LABEL org.opencontainers.image.title="usway"
LABEL org.opencontainers.image.version="39"
LABEL org.opencontainers.image.description="custom sericea image for framework laptop"
LABEL io.artifacthub.package.readme-url=https://raw.githubusercontent.com/ublue-os/startingpoint/main/README.md
LABEL io.artifacthub.package.logo-url=https://avatars.githubusercontent.com/u/120078124?s=200&v=4

ARG RECIPE=./config/recipe.yml

# Copy the bling from ublue-os/bling into tmp, to be installed later by the bling module
# Feel free to remove these lines if you want to speed up image builds and don't want any bling
COPY --from=ghcr.io/ublue-os/bling:latest /rpms /tmp/bling/rpms
COPY --from=ghcr.io/ublue-os/bling:latest /files /tmp/bling/files

COPY --from=docker.io/mikefarah/yq /usr/bin/yq /usr/bin/yq

COPY --from=gcr.io/projectsigstore/cosign /ko-app/cosign /usr/bin/cosign

COPY --from=registry.gitlab.com/wunker-bunker/blue-build:latest-installer /out/bb /usr/bin/bb

COPY config /tmp/config/

# Copy modules
# The default modules are inside ublue-os/bling
COPY --from=ghcr.io/ublue-os/bling:latest /modules /tmp/modules/
# Custom modules overwrite defaults
COPY modules /tmp/modules/

RUN printf "#!/usr/bin/env bash\n\nget_yaml_array() { \n  readarray \"\$1\" < <(echo \"\$3\" | yq -I=0 \"\$2\")\n} \n\nexport -f get_yaml_array\nexport OS_VERSION=\$(grep -Po '(?<=VERSION_ID=)\d+' /usr/lib/os-release)" >> /tmp/exports.sh && chmod +x /tmp/exports.sh

ARG CONFIG_DIRECTORY="/tmp/config"
ARG IMAGE_NAME="usway"
ARG BASE_IMAGE="ghcr.io/ublue-os/sericea-main"



RUN chmod +x /tmp/modules/files/files.sh && source /tmp/exports.sh && /tmp/modules/files/files.sh '{"type":"files","from-file":null,"files":[{"framework/foot":"/usr/etc/xdg/foot"},{"framework/fuzzel":"/usr/etc/xdg/fuzzel"},{"framework/sway":"/usr/etc/sway"},{"framework/mako":"/usr/etc/homedir/.config/mako"},{"framework/sddm":"/usr/share/sddm"}]}'


RUN chmod +x /tmp/modules/files/files.sh && source /tmp/exports.sh && /tmp/modules/files/files.sh '{"type":"files","from-file":null,"files":[{"homedir":"/usr/etc/homedir"},{"usr":"/usr"}]}'

RUN chmod +x /tmp/modules/rpm-ostree/rpm-ostree.sh && source /tmp/exports.sh && /tmp/modules/rpm-ostree/rpm-ostree.sh '{"type":"rpm-ostree","from-file":null,"repos":null,"install":["sway","xdg-desktop-portal-wlr","waybar","xorg-x11-server-Xwayland","xdg-user-dirs","android-tools","android-file-transfer","swaybg","swayidle","swaylock","power-profiles-daemon","polkit-gnome","libseat","network-manager-applet","system-config-printer","firewall-config","blueman","thunar","thunar-archive-plugin","imv","kvantum","eza","gnome-disk-utility","mako","xarchiver","pavucontrol","swappy","lite-xl","qt5ct","qt6ct","qt6-qtwayland","qt5-qtwayland","qt5-qtgraphicaleffects","qt5-qtquickcontrols2","qt5-qtsvg","fuzzel","foot","grimshot","wdisplays","gnome-keyring","overpass-fonts","overpass-mono-fonts","google-noto-emoji-fonts","google-noto-fonts-common","google-roboto-fonts","google-noto-sans-fonts","light","fish","wtype","papirus-icon-theme","pipewire","wireplumber","pipewire-alsa","pipewire-jack-audio-connection-kit","pipewire-pulseaudio","ksshaskpass"],"remove":["firefox","firefox-langpacks","toolbox","sway-config-fedora","dunst","rofi-wayland","jack-audio-connection-kit"],"optfix":["Mullvad VPN"]}'


RUN chmod +x /tmp/modules/bling/bling.sh && source /tmp/exports.sh && /tmp/modules/bling/bling.sh '{"type":"bling","from-file":null,"install":["justfiles","nix-installer","ublue-os-wallpapers","ublue-update"]}'


RUN chmod +x /tmp/modules/yafti/yafti.sh && source /tmp/exports.sh && /tmp/modules/yafti/yafti.sh '{"type":"yafti","from-file":null,"custom-flatpaks":[{"Mpv (Media Player)":"io.mpv.Mpv"},{"KWallet (Git Askpass)":"org.kde.kwalletmanager5"},{"adw-gtk3 (GTK Theme)":"org.gtk.Gtk3theme.adw-gtk3-dark"},{"Pika Backup":"org.gnome.World.PikaBackup"},{"Fedora Media Writer":"org.fedoraproject.MediaWriter"},{"Flatseal (Permission Manager)":"com.github.tchx84.Flatseal"},{"Gradience (GTK4 theming)":"com.github.GradienceTeam.Gradience/x86_64/stable"},{"Spot (GTK4 Spotify Client)":"dev.alextren.Spot"},{"G4Music (GTK4 Music Player)":"com.github.neithern.g4music"},{"Dolpin (Wii and Gamecube emulator)":"org.DolphinEmu.dolphin-emu"},{"Cemu (Wii U emulator)":"info.cemu.Cemu"},{"Yuzu (Switch emulator)":"org.yuzu_emu.yuzu"},{"GNOME Clocks":"org.gnome.clocks"},{"Easy Effects":"com.github.wwmm.easyeffects"},{"Shotcut (Video Editor)":"org.shotcut.Shotcut"},{"OTP Client (2FA auth)":"com.github.paolostivanin.OTPClient"},{"Joplin (Notes App)":"net.cozic.joplin_desktop"},{"FileZilla (FTP Client)":"org.filezillaproject.Filezilla"},{"Blender (3D editor)":"org.blender.Blender"},{"Inkscape (SVG editor)":"org.inkscape.Inkscape"},{"Signal (Messenger)":"org.signal.Signal"},{"Shotcut (Video Editor)":"org.shotcut.Shotcut"},{"Tagger (Audio Tagger)":"org.nickvision.tagger"},{"Syncthing (File Syncing)":"me.kozec.syncthingtk"},{"Pods (Graphical Podman Frontend)":"com.github.marhkb.Pods"},{"Bottles":"com.usebottles.bottles"},{"Discord":"com.discordapp.Discord"},{"Heroic Games Launcher":"com.heroicgameslauncher.hgl"},{"Steam":"com.valvesoftware.Steam"},{"Gamescope (Utility)":"org.freedesktop.Platform.VulkanLayer.gamescope"},{"MangoHUD (Utility)":"org.freedesktop.Platform.VulkanLayer.MangoHud//22.08"},{"SteamTinkerLaunch (Utility)":"com.valvesoftware.Steam.Utility.steamtinkerlaunch"},{"Prism MC (Minecraft Launcher)":"org.prismlauncher.PrismLauncher"},{"Proton GE (Custom Proton Version)":"com.valvesoftware.Steam.CompatibilityTool.Proton-GE"},{"Obsidian":"md.obsidian.Obsidian"},{"Brave":"com.brave.Browser"},{"OBS Studio":"com.obsproject.Studio"},{"VkCapture for OBS":"com.obsproject.Studio.OBSVkCapture"},{"Gstreamer for OBS":"com.obsproject.Studio.Plugin.Gstreamer"},{"Gstreamer VAAPI for OBS":"com.obsproject.Studio.Plugin.GStreamerVaapi"}]}'

RUN chmod +x /tmp/modules/script/script.sh && source /tmp/exports.sh && /tmp/modules/script/script.sh '{"type":"script","from-file":null,"scripts":["install-mullvad.sh","signing.sh"]}'

RUN chmod +x /tmp/modules/systemd/systemd.sh && source /tmp/exports.sh && /tmp/modules/systemd/systemd.sh '{"type":"systemd","from-file":null,"system":{"enabled":["power-profiles-daemon","mullvad-daemon"],"disabled":["rpm-ostree-countme.timer"]}}'




RUN rm -rf /tmp/* /var/* && ostree container commit