#!/bin/sh

# First start generates .wine sources which result
# in a broken DBUS connection (winsock failure)
service game-server start

# .. so we restart the service and game server.
service dbus restart
service game-server restart

# Keep-alive
sleep infinity
