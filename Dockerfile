FROM scottyhardy/docker-wine

ARG USERNAME=anonymous
ARG PASSWORD=
ARG GUARDCODE=
ARG APPID=
ARG RUNCMD=

# Enable console (headless mode)
ARG HEADLESS=yes

# Suppress non-blocking warnings.
ENV DBUS_FATAL_WARNINGS 0
ENV WINEDEBUG -all

# Override base image variables.
ENV RUN_AS_ROOT yes

ENV PROGRAM_FILES /usr/games/.wine/drive_c/Program\ Files\ \(x86\)

WORKDIR /usr/games

RUN chown games:games /usr/games

USER games

RUN wineboot --update

# Install the Steam application.
RUN wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip && unzip steamcmd.zip -d "$PROGRAM_FILES/Steam" && rm steamcmd.zip
RUN wine "$PROGRAM_FILES/Steam/steamcmd.exe" +login "$USERNAME" "$PASSWORD" "$GUARDCODE" +app_update "$APPID" +quit

USER root

COPY files /usr/games/files
RUN sudo -u games cp -rf files/* "$PROGRAM_FILES/Steam/steamapps/common/*/" && rm -rf files

COPY init.d/game-server /etc/init.d/game-server
COPY launch.sh /usr/games/launch.sh

# Install LSB init and RC scripts.
RUN update-rc.d game-server defaults && echo "HEADLESS=$HEADLESS\nRUNCMD=\$(cat <<EOL\n$RUNCMD\nEOL\n)" > .game-server

CMD /usr/games/launch.sh
