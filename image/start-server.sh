#!/bin/bash

export temp_ldpath=$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/home/valheim/data/linux64:$LD_LIBRARY_PATH
export SteamAppId=892970

cp /home/valheim/data/linux64/steamclient.so /home/valheim/data

export LD_LIBRARY_PATH=$temp_ldpath

if [[ ! -d "${SAVEDIR}/worlds" ]]; then
    echo "### No world data found, looking for backup data ###"
    /home/valheim/gcs-restore.sh
fi

# Install and run cron daemon to backup worlds
/home/valheim/install-cronjob.sh
cron

echo "### Starting Valheim server ###"
while true; do
./data/valheim_server.x86_64 \
  -name "${SERVER_NAME}" \
  -port ${SERVER_PORT} \
  -world "${SERVER_WORLD}" \
  -password "${SERVER_PASSWORD}" \
  -savedir "${SAVEDIR}" \
  -public 1
done
