# docker-steamcmd-wine

Run a [Steam](https://store.steampowered.com) powered Windows game server in Docker.

## Dependencies

- [Visual Studio Code](https://code.visualstudio.com/download) (optional)
- [Docker](https://docs.docker.com/get-docker)

### VS Code extensions

- [Remote-Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## Manually starting the container

Unless the game you are attempting to run was purchased on [Steam](https://store.steampowered.com), authentication _should not be necessary_ so you can omit the `--build-arg` arguments in the command below.  In cases you do need to authenticate, on first build attempt a [Steam Guard](https://help.steampowered.com/en/faqs/view/06B0-26E6-2CF8-254C) code is generated which is _sent to you by either e-mail or SMS_.  Due to this, you must update the command below to include the `GUARDCODE` value and re-run the build process.

    $ docker build -t steamcmd . --build-arg USERNAME=<steam-username> --build-arg PASSWORD=<steam-password> --build-arg GUARDCODE=<steam-guard-code> --build-arg APPID=<steam-appid> --build-arg RUNCMD=<command>
    $ docker run -d --network host steamcmd

### Accessing the container

    $ docker exec -it <container-id> /bin/bash

## Launching in Remote-Containers

In the VS Code _Command Palette_ choose "Open Folder in Container" which will launch the server in a Docker container allowing for realtime development and testing.

By default, a [Miscreated Dedicated Server](https://steamdb.info/app/302200) will be launched.  To change the game edit the VS Code [`devcontainer.json`](https://github.com/nuxy/docker-steamcmd-wine/blob/develop/.devcontainer/devcontainer.json) and rebuild the Docker container.

## Managing the game server

The following command can be executed within the Docker container:

    $ service game-server {start|stop|restart}

## Overriding game sources

In cases where you have an existing game set-up (e.g. configuration, database, workshops) you can synchronize these items during the game installation process by adding them to the `/files` directory.  Mirroring that of the existing game directory, files that already exist will be overwritten.

## Networking workarounds

The most likely culprit to the "I cannot find my server.." issue is one of the following:

1. Your router NAT has limited support for [UPnP &#40;Universal Plug and Play&#41;](https://en.wikipedia.org/wiki/Universal_Plug_and_Play) which results in game loopback requests being denied.  To resolve this you must manually configure [port range forwarding](https://en.wikipedia.org/wiki/Port_forwarding) in your router to mirror the TCP/UDP ports exposed by the game server.  This will ensure routing to your game server occurs within the network.
2. Your game server binds to the server _internal IP_ vs router _external (public)_ address.  To resolve this you must add an IP alias to your server network device (see below).  Once complete, you must configure the game to launch using that same address thereby ensuring the correct IP is broadcasted to the game network.

### Adding an IP alias (spoofing your external address)

    $ ip a add <ip-address>/24 dev <interface-name>

## References

- [Database of everything on Steam](https://steamdb.info)
- [Runtime options with Memory, CPUs, and GPUs](https://docs.docker.com/config/containers/resource_constraints)

## Contributions

If you fix a bug, or have a code you want to contribute, please send a pull-request with your changes.

## Versioning

This package is maintained under the [Semantic Versioning](https://semver.org) guidelines.

## License and Warranty

This package is distributed in the hope that it will be useful, but without any warranty; without even the implied warranty of merchantability or fitness for a particular purpose.

_docker-steamcmd-wine_ is provided under the terms of the [MIT license](http://www.opensource.org/licenses/mit-license.php)

[Steam](https://store.steampowered.com) is a registered trademark of Valve Corporation.

## Author

[Marc S. Brooks](https://github.com/nuxy)
