#!/bin/bash

mkdir -p "${BACKUPDIR?}"

echo "Fetching backups from GCS"
rclone sync --max-age 2d gcs:${GCS_BUCKET?}/backups/ "${BACKUPDIR?}"

for f in `/bin/ls -rt "${BACKUPDIR}"/*.tgz | tail -1`; do
    echo "Extracting backup: $f"
    DEPTH=$(tar ztvf "${f}" | awk '/^.*worlds\/$/ {print $6}' | sed s,^/,, | awk -F"/" '{print NF-2}')
    tar -C "${SAVEDIR}" --strip-components=${DEPTH} -zxvf "${f}"
done
