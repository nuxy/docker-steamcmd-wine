# docker-steamcmd-wine

Run a [Steam](https://store.steampowered.com) powered Windows game server in Docker.

## Dependencies

- [Visual Studio Code](https://code.visualstudio.com/download) (optional)
- [Docker](https://docs.docker.com/get-docker)

### VS Code extensions

- [Remote-Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## Manually starting the container

Unless the game you are attempting to run was purchased on the [Steam](https://store.steampowered.com) marketplace **authentication should not be necessary** so you can omit the [Game configuration arguments](#game-configuration-arguments) in the `docker build` command below.  In cases you do need to authenticate, on first build attempt a [Steam Guard](https://help.steampowered.com/en/faqs/view/06B0-26E6-2CF8-254C) code is generated which is _sent to you by either e-mail or SMS_.  Due to this, you must update the command below to include the `GUARDCODE` value and re-run the build process _within 30 seconds_ of receiving the message.

    $ docker build -t steamcmd . --build-arg USERNAME=<steam-username> --build-arg PASSWORD=<steam-password> --build-arg GUARDCODE=<steam-guard-code> --build-arg APPID=<steam-appid> --build-arg RUNCMD=<command>
    $ docker run -d --network host steamcmd

### Accessing the container

    $ docker exec -it <container-id> /bin/bash

### Game configuration arguments

| `--build-arg` | Description             |
|---------------|-------------------------|
| USERNAME      | Steam account Username (optional) |
| PASSWORD      | Steam account Password (optional) |
| GUARDCODE     | [Steam Guard](https://help.steampowered.com/en/faqs/view/06B0-26E6-2CF8-254C) code (optional) |
| APPID         | Steam application ID    |
| RUNCMD        | Commands to run in the app directory. |
| HEADLESS      | yes &#124; no (default: yes) |
| RDP_SERVER    | yes &#124; no (default: no)  |
| RDP_PASSWD    | System account Password (default: `games`) |

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
2. Your game server binds to the server _internal IP_ vs router _external (public)_ address.  To resolve this you must add an IP alias to your server network device (see below).  Once complete, you _*may need to configure the game_ to launch using that same address thereby ensuring the correct IP is broadcasted to the game network.

(*) Entirely dependent on your network set-up (e.g. corporate vs home) and in most cases is not required.

### Adding an IP alias (spoofing your external address)

    $ ip a add <ip-address>/24 dev <interface-name>

## Connecting with an RDP client

If the container was started with `RDP_SERVER=yes` you can make a remote desktop connection using a client-side application supported by your operating system.

| Application | Operating System |
|-------------|------------------|
| [Microsoft Remote Desktop](https://play.google.com/store/apps/details?id=com.microsoft.rdc.androidx) | Android |
| [Microsoft Remote Desktop](https://apps.apple.com/us/app/microsoft-remote-desktop/id1295203466) | OSX, iOS |
| [Microsoft Remote Desktop](https://apps.microsoft.com/store/detail/microsoft-remote-desktop/9WZDNCRFJ3PS) | Windows |
| [Reminna Remote Desktop Client](https://remmina.org/remmina-rdp) | Linux |

### Login credentials

Unless `RDP_PASSWD` has been defined, you can login to the server using the following account information:

```txt
Username: games
Password: games
```

## References

- [Database of everything on Steam](https://steamdb.info)
- [Runtime options with Memory, CPUs, and GPUs](https://docs.docker.com/config/containers/resource_constraints)
- [Required Ports for Steam](https://help.steampowered.com/en/faqs/view/2EA8-4D75-DA21-31EB)

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
