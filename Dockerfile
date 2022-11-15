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
ENV WINEPREFIX /usr/games/.wine

ENV PROGRAM_FILES "$WINEPREFIX"/drive_c/Program\ Files\ \(x86\)
RUN mkdir -p "$PROGRAM_FILES"

WORKDIR /usr/games

# Install the Steam application.
RUN wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip && unzip steamcmd.zip -d "$PROGRAM_FILES"/Steam && rm steamcmd.zip
RUN wine "$PROGRAM_FILES"/Steam/steamcmd.exe +login "$USERNAME" "$PASSWORD" "$GUARDCODE" +app_update "$APPID" +quit 2> /dev/null ; exit 0
RUN ln -s "$PROGRAM_FILES"/Steam /usr/games/Steam

COPY files /usr/games/files
RUN find /usr/games/Steam/steamapps/common/* -maxdepth 0 -not -name "Steamworks Shared" | xargs -I{} cp -rf files/* {} && rm -rf files
RUN chown -R games:games /usr/games

COPY init.d/game-server /etc/init.d/game-server

# Install LSB init and RC scripts.
RUN update-rc.d game-server defaults && echo "HEADLESS=$HEADLESS\nRUNCMD=\$(cat <<EOL\n$RUNCMD\nEOL\n)" > .game-server

# Configure RDP dependencies.
RUN [ "$RDP_SERVER" = "yes" ] & usermod --password "$(openssl passwd -1 -salt $(openssl rand -base64 6) $RDP_PASSWD)" --shell /bin/bash games

COPY config /usr/games/.config
RUN sed -i 's/allow_channels=true/allow_channels=false/g' /etc/xrdp/xrdp.ini
RUN mv /usr/games/.config/user-dirs.conf /etc/xdg/user-dirs.defaults

COPY launch.sh /usr/games/launch.sh
ENTRYPOINT /usr/games/launch.sh
