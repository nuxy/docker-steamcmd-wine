#!/bin/sh

. /var/run/docker-env

# Start services
service game-server start

if [ "$RDP_SERVER" = "yes" ]; then
  usermod --password $(openssl passwd -1 "$RDP_PASSWD") --shell /bin/bash games

  service xrdp start
fi

# Keep-alive
sleep infinity
