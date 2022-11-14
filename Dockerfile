FROM scottyhardy/docker-wine

ARG USERNAME=anonymous
ARG PASSWORD=
ARG GUARDCODE=
ARG APPID=
ARG RUNCMD=

# Enable console (headless mode)
ARG HEADLESS=yes

# Enable remote desktop access.
ARG RDP_SERVER=no
ARG RDP_PASSWD=games
ENV RDP_SERVER "$RDP_SERVER"

# Suppress non-blocking warnings.
ENV DBUS_FATAL_WARNINGS 0
ENV WINEDEBUG -all

# Override base image variables.
ENV WINEPREFIX /usr/games/.wine
ENV RUN_AS_ROOT yes

ENV PROGRAM_FILES "$WINEPREFIX"/drive_c/Program\ Files\ \(x86\)

WORKDIR /usr/games

RUN mkdir -p "$PROGRAM_FILES"

# Install the Steam application.
RUN wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip && unzip steamcmd.zip -d "$PROGRAM_FILES"/Steam && rm steamcmd.zip
RUN wine "$PROGRAM_FILES"/Steam/steamcmd.exe +login "$USERNAME" "$PASSWORD" "$GUARDCODE" +app_update "$APPID" +quit 2> /dev/null ; exit 0

COPY files /usr/games/files
RUN cp -rf files/* "$PROGRAM_FILES"/Steam/steamapps/common/*/ && rm -rf files
RUN chown -R games:games /usr/games

COPY init.d/game-server /etc/init.d/game-server
COPY launch.sh /usr/games/launch.sh

# Install LSB init and RC scripts.
RUN update-rc.d game-server defaults && echo "HEADLESS=$HEADLESS\nRUNCMD=\$(cat <<EOL\n$RUNCMD\nEOL\n)" > .game-server

# Configure RDP dependencies.
RUN [ "$RDP_SERVER" = "yes" ] && usermod --password "$(openssl passwd -1 -salt $(openssl rand -base64 6) $RDP_PASSWD)" --shell /bin/bash games

COPY config /usr/games/.config
RUN sed -i 's/allow_channels=true/allow_channels=false/g' /etc/xrdp/xrdp.ini
RUN mv /usr/games/.config/user-dirs.conf /etc/xdg/user-dirs.defaults

ENTRYPOINT /usr/games/launch.sh
