#!/bin/bash

set -e

BACKUP_FILE="${BACKUPDIR?}/valheim-server-backup-$(date +%Y%m%dT%H%M%S).tgz"

echo "Archiving ${SAVEDIR?} to ${BACKUP_FILE}"

mkdir -p $(dirname "${BACKUP_FILE}")
tar -P -zcf "${BACKUP_FILE}" "${SAVEDIR?}"

echo "Syncing archives to GCS"
rclone sync --max-delete=0 "${BACKUPDIR}" gcs:${GCS_BUCKET?}/backups/
rm -f "${BACKUP_FILE}"
