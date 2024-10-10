#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail
url="$(curl -s https://api.github.com/repos/sentriz/cliphist/releases/latest | yq ".assets[].browser_download_url" | grep amd64)"
curl -ssLO "$url" /usr/bin/cliphist.zip
unzip /usr/bin/cliphist.zip /usr/bin/cliphist
rm /usr/bin/cliphist.zip
