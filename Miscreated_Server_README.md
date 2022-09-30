# Docker Miscreated Server
This is the initial release of the Docker containerized Miscreated server. This release is in no way polished, and rapid changes to it will likely occur in the future. This is essentially a wrappers for Nuxy's excellent [docker-steamcmd-wine](https://github.com/nuxy/docker-steamcmd-wine) project of which this *Miscreated-centric* version is a fork; I will try to keep this repository in sync with Nuxy's project.

This wrapper allows the running of a Miscreated server in a Docker container. The main differences from using the parent project is that the user doesn't need to be completely familiar with Docker, and the most important files and directories from the Miscreated server installation, such as most logs, the database, and database backups, will all be stored outside of the container for ease of backup and review. The exception to this is `server.log` files which will still reside within the container itself.

## Requirements
* Docker running on a Linux server
* Your user must be a member of the Docker group and be able to perform Docker commands
* Your user must be able to execute `sudo`

### NOTICES
* Currently, this wrapper script will prompt for your Linux user password in order to create the requisite directories and to set necessary file permissions. I plan on making this a bit more intelligent in the future.
* This wrapper has only been tested on Linux. Your mileage may vary.

## Configurable settings
These are currently the only modifiable options and their defaults for setting up the Docker container for the Miscreated server; you may change them in `userVariables.env`, and it is important that you do not delete any of these variables. Only change the values to the right of the equals sign within this file. You should also not change any other files.

### Default variable settings
```ini
container_name=miscreated_server
map=islands
maxplayers=36
mis_gameserverid=100
server_local_dir=/opt/miscreated_servers/miscreated-server
sv_port=69040
sv_servername="Docker Miscreated Server"
whitelisted=0
```

### Variables and what they mean
* `container_name` is the name of the Docker container. You'll want to change this only if you are running multiple Miscreated servers.
* `map` is the map which will be run by the Miscreated server. The two built-in maps, and only valid options without modding, are `islands` and `canyonlands`.
* `maxplayers` is the most players which may join the server. The higher the number, to a max of 100, will increase both the number of players as well as the amount of resources (CPU+RAM) used by the server. Setting this value to less than 36 will not reduce server resources, but may be desirable should you want only a small number of players to be able to join.
* `mis_gameserverid` is the id of the Miscreated server. This value should be left at `100`. Only change this value if you are importing a server from a hosting provider which previously specified this value.
* `server_local_dir` is the local directory where files such as the Miscreated database, logs, whitelist, and blacklist files will be stored. If this directory does not exist, the script will attempt to create the directory; you will be prompted for your system password upon execution of the sudo commands needed to create the directory and set directory permissions. You will only want to change this directory path if you are running multiple Miscreated servers.
* `sv_port` is the base port on which the Miscreated server will run. This port, and the next four ports, will all be used by the server. For example, if you use the default value of `69040`, UDP ports `64090`, `64091`, `64092`, `64093`, and TCP port `64094` will all be used by the server. Following that example, if you were to run a second Miscreated server, you would need to offset the port by at least five for the second server (e.g. you would want to use `sv_port=64095` for the second server if your first server is using `sv_port=64090`).
* `sv_servername` is the name of the server as it will appear in the Steam and Miscreated server browsers. This value should be encapsulated in double-quotes.
* `whitelisted` enables or disables server whitelisting. A value of `0` will disable whitelisting (default), and a value of `1` will enable whitelisting.

## How to run a server
Make sure the requirements listed above have been met. After that:
1. Execute the `build-miscreated-image.sh` script. This will build the Miscreated server Docker image. You only need to run this once regardless of how many servers you wish to run. This script should be run whenever there are any Miscreated server updates published by Entrada.
2. Edit the `userVariables.env` file to reflect the values you wish to have for your server. If you're only running a single server, I suggest you only edit the `sv_servername` variable. Refer to the variable definitions above as needed.
3. Execute the `run-miscreated-server.sh` script.

Other than port forwarding, if needed (see below), that's all you need to do. The Miscreated server should continuously run, restarting normally, even in the event of a restart of the host system. You may also wish to edit your `hosting.cfg` file to configure `sv_motd` and `sv_url`, configure non-default settings, or to add mods. On the initial run of the wrapper, a randomized password will be configured for RCON; you can find and/or change this password in the `hosting.cfg` file. Log verbosity will also be set to `0` by default. Other than that, the server will run with completely default settings. If you change any settings in `hosting.cfg`, for changes to take effect you will need to restart the Docker container by executing `docker restart <container_name>`; e.g. `docker restart miscreated_server`.

If you wish to run multiple servers, copy this wrapper directory and its contents, then in the copy edit the `userVariables.env` as needed and execute the `run-miscreated-server.sh` script in that cloned directory.

## Port forwarding
If your Docker server does not have a public IP address then you will need to forward the required ports from your router to your Docker server's internal network IP address. Up to five ports may be forwarded, but only the first four ports are required. Using the default base port (`sv_port`) number of `64090`, you will need to forward the following ports:
| Protocol | Port | Optional |
| -------- | ---- | -------- |
| UDP | 64090 | no |
| UDP | 64091 | no |
| UDP | 64092 | no |
| UDP | 64093 | no |
| TCP | 64094 | yes |

Adjust the port numbers relative to the base port number you choose. The fifth port, the TCP port, is only used for RCON. You won't need to forward that unless you want to access RCON from outside of your LAN.
