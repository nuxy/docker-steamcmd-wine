# docker-steamcmd-wine

Run a [Steam](https://store.steampowered.com) powered Windows game server in Docker.

## Dependencies

- [Visual Studio Code](https://code.visualstudio.com/download) (optional)
- [Docker](https://docs.docker.com/get-docker)

### VS Code extensions

- [Remote-Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## Manually starting the container

    $ docker build -t steamcmd . --build-arg USERNAME=<steam-username> --build-arg PASSWORD=<steam-password> --build-arg APPID=<steam-appid> --build-arg RUNCMD=<command>
    $ docker run -d -p 27015:27050 -p 27015:27050/udp steamcmd

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
