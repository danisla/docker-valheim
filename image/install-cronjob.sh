#!/bin/bash

if [[ ! -f /etc/cron.d/backup-cron ]]; then
    echo "Installing cronjob"

    echo "SAVEDIR=${SAVEDIR?}" >> /etc/environment
    echo "BACKUPDIR=${BACKUPDIR?}" >> /etc/environment
    echo "GCS_BUCKET=${GCS_BUCKET?}" >> /etc/environment

    cat - > /etc/cron.d/backup-cron <<EOF
0 */8 * * * /home/valheim/gcs-backup.sh >> /var/log/cron.log 2>&1
EOF
    chmod 0644 /etc/cron.d/backup-cron
    crontab /etc/cron.d/backup-cron
else
    echo "Cronjob already installed"
fi