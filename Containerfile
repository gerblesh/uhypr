# This stage is responsible for holding onto
# your config without copying it directly into
# the final image
FROM scratch as stage-config
COPY ./config /config

# Copy modules
# The default modules are inside blue-build/modules
# Custom modules overwrite defaults
FROM scratch as stage-modules
COPY --from=ghcr.io/blue-build/modules:latest /modules /modules
COPY ./modules /modules

# Bins to install
# These are basic tools that are added to all images.
# Generally used for the build process. We use a multi
# stage process so that adding the bins into the image
# can be added to the ostree commits.
FROM scratch as stage-bins

COPY --from=gcr.io/projectsigstore/cosign /ko-app/cosign /bins/cosign
COPY --from=docker.io/mikefarah/yq /usr/bin/yq /bins/yq
COPY --from=ghcr.io/blue-build/cli:latest-installer /out/bluebuild /bins/bluebuild

# Keys for pre-verified images
# Used to copy the keys into the final image
# and perform an ostree commit.
#
# Currently only holds the current image's
# public key.
FROM scratch as stage-keys
COPY cosign.pub /keys/uhypr.pub

FROM ghcr.io/ublue-os/base-main:latest

ARG RECIPE=recipes/framework_recipe.yml
ARG IMAGE_REGISTRY=localhost
ARG CONFIG_DIRECTORY="/tmp/config"
ARG MODULE_DIRECTORY="/tmp/modules"
ARG IMAGE_NAME="uhypr"
ARG BASE_IMAGE="ghcr.io/ublue-os/base-main"

# Key RUN
RUN --mount=type=bind,from=stage-keys,src=/keys,dst=/tmp/keys \
  mkdir -p /usr/etc/pki/containers/ \
  && cp /tmp/keys/* /usr/etc/pki/containers/ \
  && ostree container commit

# Bin RUN
RUN --mount=type=bind,from=stage-bins,src=/bins,dst=/tmp/bins \
  mkdir -p /usr/bin/ \
  && cp /tmp/bins/* /usr/bin/ \
  && ostree container commit

# Module RUNs
RUN \
  --mount=type=bind,from=stage-config,src=/config,dst=/tmp/config,rw \
  --mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
  --mount=type=bind,from=ghcr.io/blue-build/cli:-exports,src=/exports.sh,dst=/tmp/exports.sh \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-uhypr-latest,sharing=locked \
  echo "========== Start Files module ==========" \
  && chmod +x /tmp/modules/files/files.sh \
  && source /tmp/exports.sh \
  && /tmp/modules/files/files.sh '{"type":"files","files":[{"usr":"/usr"}]}' \
  && echo "========== End Files module ==========" \
  && ostree container commit
RUN \
  --mount=type=bind,from=stage-config,src=/config,dst=/tmp/config,rw \
  --mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
  --mount=type=bind,from=ghcr.io/blue-build/cli:-exports,src=/exports.sh,dst=/tmp/exports.sh \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-uhypr-latest,sharing=locked \
  echo "========== Start Rpm-ostree module ==========" \
  && chmod +x /tmp/modules/rpm-ostree/rpm-ostree.sh \
  && source /tmp/exports.sh \
  && /tmp/modules/rpm-ostree/rpm-ostree.sh '{"type":"rpm-ostree","repos":["https://copr.fedorainfracloud.org/coprs/wezfurlong/wezterm-nightly/repo/fedora-%OS_VERSION%/wezfurlong-wezterm-nightly-fedora-%OS_VERSION%.repo","https://repository.mullvad.net/rpm/stable/mullvad.repo"],"install":["gcc-c++","gcc","make","mesa-libGLU","podman-compose","podman-tui","podmansh","hyprland","xdg-desktop-portal-hyprland","waybar","xorg-x11-server-Xwayland","xdg-user-dirs","wezterm","sway","android-tools","android-file-transfer","swaybg","swayidle","swaylock","tuned","tuned-utils","tuned-switcher","polkit-gnome","libseat","network-manager-applet","system-config-printer","firewall-config","blueman","thunar","thunar-archive-plugin","imv","kvantum","eza","gnome-disk-utility","mako","xarchiver","pavucontrol","swappy","docker-compose","sddm","qt5ct","qt6ct","qt6-qtwayland","qt5-qtwayland","qt5-qtgraphicaleffects","qt5-qtquickcontrols2","qt5-qtsvg","fuzzel","foot","grimshot","wdisplays","gnome-keyring","overpass-fonts","overpass-mono-fonts","google-noto-emoji-fonts","google-noto-fonts-common","google-roboto-fonts","google-noto-sans-fonts","light","fish","wtype","pipewire","wireplumber","pipewire-alsa","pipewire-jack-audio-connection-kit","pipewire-pulseaudio","ksshaskpass","mullvad-vpn"],"remove":["firefox","firefox-langpacks","toolbox"],"optfix":["Mullvad VPN"]}' \
  && echo "========== End Rpm-ostree module ==========" \
  && ostree container commit
RUN \
  --mount=type=bind,from=stage-config,src=/config,dst=/tmp/config,rw \
  --mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
  --mount=type=bind,from=ghcr.io/blue-build/cli:-exports,src=/exports.sh,dst=/tmp/exports.sh \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-uhypr-latest,sharing=locked \
  echo "========== Start Bling module ==========" \
  && chmod +x /tmp/modules/bling/bling.sh \
  && source /tmp/exports.sh \
  && /tmp/modules/bling/bling.sh '{"type":"bling","install":["ublue-update"]}' \
  && echo "========== End Bling module ==========" \
  && ostree container commit
RUN \
  --mount=type=bind,from=stage-config,src=/config,dst=/tmp/config,rw \
  --mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
  --mount=type=bind,from=ghcr.io/blue-build/cli:-exports,src=/exports.sh,dst=/tmp/exports.sh \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-uhypr-latest,sharing=locked \
  echo "========== Start Script module ==========" \
  && chmod +x /tmp/modules/script/script.sh \
  && source /tmp/exports.sh \
  && /tmp/modules/script/script.sh '{"type":"script","scripts":["starship.sh"]}' \
  && echo "========== End Script module ==========" \
  && ostree container commit
RUN \
  --mount=type=bind,from=stage-config,src=/config,dst=/tmp/config,rw \
  --mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
  --mount=type=bind,from=ghcr.io/blue-build/cli:-exports,src=/exports.sh,dst=/tmp/exports.sh \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-uhypr-latest,sharing=locked \
  echo "========== Start Systemd module ==========" \
  && chmod +x /tmp/modules/systemd/systemd.sh \
  && source /tmp/exports.sh \
  && /tmp/modules/systemd/systemd.sh '{"type":"systemd","system":{"enabled":["mullvad-daemon","sddm.service"],"disabled":["rpm-ostree-countme.timer"]}}' \
  && echo "========== End Systemd module ==========" \
  && ostree container commit
RUN \
  --mount=type=bind,from=stage-config,src=/config,dst=/tmp/config,rw \
  --mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
  --mount=type=bind,from=ghcr.io/blue-build/cli:-exports,src=/exports.sh,dst=/tmp/exports.sh \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-uhypr-latest,sharing=locked \
  echo "========== Start Signing module ==========" \
  && chmod +x /tmp/modules/signing/signing.sh \
  && source /tmp/exports.sh \
  && /tmp/modules/signing/signing.sh '{"type":"signing"}' \
  && echo "========== End Signing module ==========" \
  && ostree container commit
RUN \
  --mount=type=bind,from=stage-config,src=/config,dst=/tmp/config,rw \
  --mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
  --mount=type=bind,from=ghcr.io/blue-build/cli:-exports,src=/exports.sh,dst=/tmp/exports.sh \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-uhypr-latest,sharing=locked \
  echo "========== Start Files module ==========" \
  && chmod +x /tmp/modules/files/files.sh \
  && source /tmp/exports.sh \
  && /tmp/modules/files/files.sh '{"type":"files","files":[{"framework/foot":"/usr/etc/xdg/foot"},{"framework/fuzzel":"/usr/etc/xdg/fuzzel"},{"framework/sway":"/usr/etc/sway"},{"framework/mako":"/usr/etc/homedir/.config/mako"},{"framework/sddm":"/usr/share/sddm"},{"framework/waybar":"/usr/etc/xdg/waybar"},{"framework/wezterm":"/usr/etc/homedir/.config/wezterm"}]}' \
  && echo "========== End Files module ==========" \
  && ostree container commit



# Labels are added last since they cause cache misses with buildah
LABEL org.blue-build.build-id="51b75711-3ffb-43bc-a64b-5ef50e20f322"
LABEL org.opencontainers.image.title="uhypr"
LABEL org.opencontainers.image.description="custom sway image for framework laptop."
LABEL io.artifacthub.package.readme-url=https://raw.githubusercontent.com/blue-build/cli/main/README.md