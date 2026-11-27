# Mornye (Flutter desktop music player) streamed to the browser via Selkies,
# the same base Umbrel's own Obsidian app uses.
FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie@sha256:793fc3628ad6e089aecfd9f862de3ad5d9df05f1db783363c812f77d6541ccc3

ARG MORNYE_VERSION=v5.4.5

ENV TITLE=Mornye \
    NO_GAMEPAD=true \
    NO_DECOR=true \
    PIXELFLUX_WAYLAND=true

COPY install-mornye.sh /tmp/install-mornye.sh
RUN bash /tmp/install-mornye.sh "${MORNYE_VERSION}"

COPY /root /

EXPOSE 3000
VOLUME /config
