FROM scottyhardy/docker-wine

ARG USERNAME=anonymous
ARG PASSWORD=
ARG APPID=
ARG RUNCMD=
ENV steam_login "$USERNAME $PASSWORD"
ENV steam_appid $APPID
ENV wine_prog $RUNCMD

# Suppress non-blocking warnings.
ENV DBUS_FATAL_WARNINGS 0
ENV WINEDEBUG -all

WORKDIR /usr/games/steamcmd

RUN apt -y update && apt -y install curl
RUN curl https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz -s | tar xfz - -C /usr/games/steamcmd
RUN ./steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir steamapp +login ${steam_login} +app_update ${steam_appid} +quit

# Limit permissions to games group.
RUN chown -R games:games /usr/games

CMD "sudo -u games wineconsole steamapp/${wine_prog}"
