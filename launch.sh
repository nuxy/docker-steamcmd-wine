#!/bin/sh

# Start services
service game-server start

if [ "$RDP_SERVER" = "yes" ]; then
  service xrdp start
fi

# Keep-alive
sleep infinity
