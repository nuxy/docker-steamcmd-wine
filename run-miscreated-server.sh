#!/bin/bash
# Read in the configured variables
while read eachLine; do export "${eachLine}"; done<$(dirname ${0})/userVariables.env
docker stop ${docker_name} 2>/dev/null && docker rm ${docker_name}
localServerDir=$server_local_dir

# Determine if the games user and group doesn't match that of the container
gamesUidCount=$(id games|grep -c "uid=5")
gamesGidCount=$(id games|grep -c "gid=60")
if [[ "${gamesUidCount}" == "0" ]] || [[ "${gamesGidCount}" == "0" ]]; then
	noGamesMatch=1
else
	noGamesMatch=0
fi

# Create the whitelisted run value
if [[ "$whitelisted" == "1" ]];then
	whitelisted=" -mis_whitelist"
else
	whitelisted=""
fi

# Create the local directories - FIXME: Let's put some logic here to better handle this
sudo mkdir -p ${localServerDir} ${localServerDir}/DatabaseBackups ${localServerDir}/logbackups ${localServerDir}/logs
if [ $noGamesMatch -eq 1 ]; then sudo find ${localServerDir} -type d -exec chmod 777 {} \; ; fi

# Touch and/or create required files - this will update the file timestamps, and create the files if missing, but no other changes will occur.
sudo touch ${localServerDir}/blacklist.xml
if [ -f ${localServerDir}/hosting.cfg ]; then
	sudo touch ${localServerDir}/hosting.cfg
else
	randomPassword=$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 8)
	echo http_password=$randomPassword|sudo tee ${localServerDir}/hosting.cfg
	echo log_Verbosity=0|sudo tee -a ${localServerDir}/hosting.cfg
	echo log_WriteToFileVerbosity=0|sudo tee -a ${localServerDir}/hosting.cfg
	echo max_uptime=12|sudo tee -a ${localServerDir}/hosting.cfg
fi
sudo touch ${localServerDir}/miscreated.db
sudo touch ${localServerDir}/reservations.xml
sudo touch ${localServerDir}/whitelist.xml

# Create the .game-server file
gameServerFile=${localServerDir}/.game-server
sudo touch ${gameServerFile}
sudo chmod 666 ${gameServerFile}
echo HEADLESS=yes > ${gameServerFile}
runString="Bin64_dedicated/MiscreatedServer.exe -sv_port=${sv_port} -mis_gameserverid=${mis_gameserverid} +sv_maxplayers ${maxplayers} +sv_servername $sv_servername +http_startserver +map ${map}${whitelisted}"
runString=$(echo $runString|sed 's/"/\\"/g')
echo RUNCMD=\"$runString\" >> ${gameServerFile}

# Update file permisssions
if [ $noGamesMatch -eq 1 ]; then
	# Yes, I know these file permissions are wide open. Don't let anyone you don't trust SSH into your system - they could bork your Miscreated server.
	# Create a "games" user and group with UID=5 and GID=60 if you wish to have tigher permissions.
	sudo find ${localServerDir} -type d -exec chmod 777 {} \;
	sudo find ${localServerDir} -type f -exec chmod 666 {} \;
else
	# These are much more reasonable permissions. Add your user to the "games" group if you want read/write permissions on the files, otherwise you'll just have read only.
	sudo find ${localServerDir} -type d -exec chmod 775 {} \;
	sudo find ${localServerDir} -type f -exec chmod 664 {} \;
	sudo chown games: -R ${localServerDir}
fi

# Fire up the Docker instance
dockerGameServerDir=/usr/games/Steam/steamapps/common/MiscreatedServer
docker run -d --restart=always --network=host --name=${container_name} \
	-v ${localServerDir}/blacklist.xml:${dockerGameServerDir}/blacklist.xml \
	-v ${localServerDir}/DatabaseBackups:${dockerGameServerDir}/DatabaseBackups \
	-v ${localServerDir}/.game-server:/usr/games/.game-server \
	-v ${localServerDir}/hosting.cfg:${dockerGameServerDir}/hosting.cfg \
	-v ${localServerDir}/logbackups:${dockerGameServerDir}/logbackups \
	-v ${localServerDir}/logs:${dockerGameServerDir}/logs \
	-v ${localServerDir}/miscreated.db:${dockerGameServerDir}/miscreated.db \
	-v ${localServerDir}/reservations.xml:${dockerGameServerDir}/reservations.xml \
	-v ${localServerDir}/whitelist.xml:${dockerGameServerDir}/whitelist.xml \
	current_miscreated_server:latest 
