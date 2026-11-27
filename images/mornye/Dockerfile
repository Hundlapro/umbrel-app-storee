# Mornye (Flutter desktop music player) streamed to the browser via Selkies,
# the same base Umbrel's own Obsidian app uses.
FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie@sha256:793fc3628ad6e089aecfd9f862de3ad5d9df05f1db783363c812f77d6541ccc3

ARG MORNYE_VERSION=v5.4.5

ENV TITLE=Mornye \
    NO_GAMEPAD=true \
    NO_DECOR=true \
    PIXELFLUX_WAYLAND=true

RUN set -eux; \
  apt-get update; \
  cd /tmp; \
  DEB="Mornye-${MORNYE_VERSION}-linux-amd64.deb"; \
  BASE="https://github.com/mornyeapp/Mornye-Desktop/releases/download/${MORNYE_VERSION}"; \
  curl -fsSL -o "$DEB" "$BASE/$DEB"; \
  curl -fsSL -o SHA256SUMS.txt "$BASE/SHA256SUMS.txt"; \
  if grep -q "$DEB" SHA256SUMS.txt; then grep "$DEB" SHA256SUMS.txt | sha256sum -c -; \
  else echo "WARNING: $DEB not listed in SHA256SUMS.txt"; fi; \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    "./$DEB" \
    libgl1-mesa-dri libegl1 libgles2 \
    libasound2-plugins pulseaudio-utils \
    xdg-desktop-portal-gtk zenity; \
  # Find the program the package's .desktop entry launches.
  PKG="$(dpkg-deb -f "$DEB" Package)"; \
  DESKTOP="$(dpkg -L "$PKG" | grep -E '/applications/.*\.desktop$' | head -1)"; \
  EXEC="$(grep -m1 '^Exec=' "$DESKTOP" | sed -e 's/^Exec=//' -e 's/ %[a-zA-Z]//g')"; \
  test -n "$EXEC"; \
  printf '#!/bin/bash\nexec %s "$@"\n' "$EXEC" > /usr/local/bin/mornye-app; \
  chmod +x /usr/local/bin/mornye-app; \
  echo "Mornye launcher: $EXEC"; \
  ICON="$(dpkg -L "$PKG" | grep -E '\.png$' | sort | tail -1 || true)"; \
  if [ -n "$ICON" ]; then cp "$ICON" /usr/share/selkies/www/icon.png || true; fi; \
  # ALSA apps -> PulseAudio, which Selkies streams to the browser.
  if [ ! -f /etc/asound.conf ]; then \
    printf 'pcm.!default { type pulse }\nctl.!default { type pulse }\n' > /etc/asound.conf; fi; \
  apt-get autoclean; \
  rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

COPY /root /

EXPOSE 3000
VOLUME /config
