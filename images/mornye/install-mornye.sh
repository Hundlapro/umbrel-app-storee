#!/bin/bash
set -euxo pipefail
VER="$1"
DEB="Mornye-${VER}-linux-amd64.deb"
BASE="https://github.com/mornyeapp/Mornye-Desktop/releases/download/${VER}"

apt-get update
cd /tmp
curl -fsSL -o "$DEB" "$BASE/$DEB"
curl -fsSL -o SHA256SUMS.txt "$BASE/SHA256SUMS.txt" || true
if grep -q "$DEB" SHA256SUMS.txt 2>/dev/null; then
  grep "$DEB" SHA256SUMS.txt | sha256sum -c -
else
  echo "WARNING: $DEB not listed in SHA256SUMS.txt"
fi

# The .deb pins libc6 (<< 2.36), an artefact of being built on Ubuntu 22.04.
# glibc is backwards compatible, so install the runtime libraries it lists
# (apt maps the pre-t64 names) and unpack the package directly.
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  libasound2 libatk1.0-0 libcairo-gobject2 libcairo2 libepoxy0 \
  libfontconfig1 libgdk-pixbuf-2.0-0 libglib2.0-0 \
  libgstreamer-plugins-base1.0-0 libgstreamer1.0-0 \
  gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-pulseaudio \
  libgtk-3-0 libharfbuzz0b libpango-1.0-0 libpangocairo-1.0-0 \
  libsecret-1-0 gnome-keyring libwayland-client0 libwayland-egl1 \
  libgl1-mesa-dri libegl1 libgles2 \
  libasound2-plugins pulseaudio-utils \
  xdg-utils xdg-desktop-portal-gtk zenity
dpkg-deb -x "$DEB" /
ldconfig

# The program the package's .desktop entry launches.
DESKTOP="$(dpkg-deb -c "$DEB" | awk '{print $NF}' | grep -E '/applications/.*\.desktop$' | head -1 | sed 's#^\.##')"
EXEC="$(grep -m1 '^Exec=' "$DESKTOP" | sed -e 's/^Exec=//' -e 's/ %[a-zA-Z]//g')"
test -n "$EXEC"
printf '#!/bin/bash\nexec %s "$@"\n' "$EXEC" > /usr/local/bin/mornye-app
chmod +x /usr/local/bin/mornye-app
echo "Mornye launcher: $EXEC"

ICON="$(dpkg-deb -c "$DEB" | awk '{print $NF}' | grep -E '/icons/.*\.png$' | sort -V | tail -1 | sed 's#^\.##' || true)"
if [ -n "$ICON" ] && [ -f "$ICON" ]; then cp "$ICON" /usr/share/selkies/www/icon.png || true; fi

# ALSA apps -> PulseAudio, which Selkies streams to the browser.
if [ ! -f /etc/asound.conf ]; then
  printf 'pcm.!default { type pulse }\nctl.!default { type pulse }\n' > /etc/asound.conf
fi

# Fail the build now, not at runtime, if the binary is missing a library.
BIN="$(echo "$EXEC" | awk '{print $1}')"
BIN="$(readlink -f "$(command -v "$BIN" || echo "$BIN")")"
if ldd "$BIN" | grep 'not found'; then exit 1; fi

apt-get autoclean
rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
