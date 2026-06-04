#
# Copyright 2022-2026, Marc S. Brooks (https://mbrooks.info)
# Licensed under the MIT license:
# http://www.opensource.org/licenses/mit-license.php

FROM scottyhardy/docker-wine

# Enable console (headless mode)
ARG HEADLESS=yes

# Enable remote desktop access.
ARG RDP_SERVER=no
ENV RDP_SERVER="$RDP_SERVER"

# Suppress non-blocking warnings.
ENV DBUS_FATAL="WARNINGS 0"
ENV WINEDEBUG=-all

# Setup Windows "Program Files"
ENV WINEPREFIX=/usr/games/.wine
ENV PROGRAM_FILES="$WINEPREFIX/drive_c/Program Files (x86)"
RUN mkdir -p "$PROGRAM_FILES"

COPY files /usr/games/files

RUN usermod --shell /bin/bash games && chown -R games:games /usr/games

USER games

WORKDIR /usr/games

# Install the Steam application.
RUN wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip && unzip steamcmd.zip -d "$PROGRAM_FILES"/Steam && rm steamcmd.zip

# Install Steam app dependencies.
RUN ln -s "$PROGRAM_FILES"/Steam /usr/games/Steam && mkdir -p /usr/games/Steam/steamapps/common && \
    find /usr/games/Steam/steamapps/common -maxdepth 0 -not -name "Steamworks Shared" | xargs -I{} cp -rf files/* {} && rm -rf files

USER root

COPY init.d/game-server /etc/init.d/game-server

# Install LSB init and RC scripts.
RUN update-rc.d game-server defaults

COPY config /usr/games/.config
RUN sed -i 's/allow_channels=true/allow_channels=false/g' /etc/xrdp/xrdp.ini
RUN mv /usr/games/.config/user-dirs.conf /etc/xdg/user-dirs.defaults

COPY launch.sh /usr/games/launch.sh

ENTRYPOINT ["/usr/games/launch.sh"]
