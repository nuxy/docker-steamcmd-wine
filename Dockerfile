FROM scottyhardy/docker-wine

ARG USERNAME=anonymous
ARG PASSWORD=
ARG APPID=
ARG RUNCMD=
ENV steam_login "$USERNAME $PASSWORD"
ENV steam_appid $APPID
ENV wine_prog $RUNCMD

ENV WINEDEBUG -all

WORKDIR /steamcmd

RUN apt -y update && apt -y install apt-utils curl
RUN curl https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz -s | tar xfz - -C /steamcmd
RUN ./steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir steamapp +login ${steam_login} +app_update ${steam_appid} +quit

CMD "wineconsole steamapp/${wine_prog}"
