FROM scottyhardy/docker-wine

ARG USERNAME=anonymous
ARG PASSWORD=
ARG GUARDCODE=
ARG APPID=
ARG RUNCMD=

# Enable console (headless mode)
ARG HEADLESS=yes
ENV HEADLESS $HEADLESS

# Suppress non-blocking warnings.
ENV DBUS_FATAL_WARNINGS 0

# Override base image variables.
ENV RUN_AS_ROOT yes

WORKDIR /usr/games

RUN chown games:games /usr/games

USER games

# Install the Steam application.
RUN wget -qO- https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar xvz
RUN ./steamcmd.sh +@sSteamCmdForcePlatformType windows +login "$USERNAME" "$PASSWORD" "$GUARDCODE" +app_update "$APPID" +quit

USER root

COPY files /usr/games/files
RUN sudo -u games cp -rf files/* /usr/games/Steam/steamapps/common/*/ && rm -rf files

COPY init.d/game-server /etc/init.d/game-server
COPY launch.sh /usr/games/launch.sh

# Install LSB init and RC scripts.
RUN update-rc.d game-server defaults && echo "$RUNCMD" > .runcmdrc

CMD /usr/games/launch.sh
