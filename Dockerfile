FROM scottyhardy/docker-wine

ARG USERNAME=anonymous
ARG PASSWORD=
ARG GUARDCODE=
ARG APPID=
ARG RUNCMD=
ENV steam_login "$USERNAME $PASSWORD $GUARDCODE"
ENV steam_appid $APPID
ENV wine_prog $RUNCMD

# Suppress non-blocking warnings.
ENV DBUS_FATAL_WARNINGS 0

# Override base image variables.
ENV RUN_AS_ROOT yes

WORKDIR /usr/games/steamcmd

RUN apt -y update && apt -y install curl
RUN curl https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz -s | tar xfz - -C /usr/games/steamcmd
RUN ./steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir steamapp +login ${steam_login} +app_update ${steam_appid} +quit

COPY init.d/game-server /etc/init.d/game-server
COPY files/* /usr/games/steamcmd/steamapp/
COPY launch.sh /usr/games/launch.sh

# Limit permissions to games group.
RUN chown -R games:games /usr/games

# Install LSB init and RC scripts.
RUN update-rc.d game-server defaults && echo "${wine_prog}" > .runcmdrc

CMD /usr/games/launch.sh
