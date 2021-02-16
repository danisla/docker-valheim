# docker-valheim
Docker server for Valheim

[https://store.steampowered.com/app/892970/Valheim/](https://store.steampowered.com/app/892970/Valheim/)

Docker image available at [https://hub.docker.com/r/nopor/valheim-server](https://hub.docker.com/r/nopor/valheim-server)

## Google Cloud Tutorial

- Run minimum spec machine, `e2-medium` at about $30/mo.
- Backup world data automatically to Google Cloud Storage.

```bash
export PROJECT_ID=YOUR_PROJECT
```

Build the image:

```bash
(cd image && gcloud builds submit -t gcr.io/${PROJECT_ID?}/valheim-server:latest)
```

Create service account for instance:

```bash
gcloud --project ${PROJECT_ID?} iam service-accounts create valheim-server --display-name="Valheim Dedicated Server"
```

```bash
export SA_EMAIL="valheim-server@${PROJECT_ID?}.iam.gserviceaccount.com"
```

Create bucket to save backups to:

```bash
gsutil mb -p ${PROJECT_ID?} gs://${PROJECT_ID?}-valheim
```

Grant service account permission on the bucket:

```bash
gsutil iam ch "serviceAccount:${SA_EMAIL?}:roles/storage.objectAdmin" gs://${PROJECT_ID?}-valheim
```

Grant service account permission to pull container images:

```bash
gsutil iam ch "serviceAccount:${SA_EMAIL?}:roles/storage.objectViewer" gs://artifacts.${PROJECT_ID?}.appspot.com
```

Create firewall rule:

```bash
export NETWORK="default"
```

```bash
gcloud --project ${PROJECT_ID?} compute firewall-rules create allow-valheim-server --network=${NETWORK?} --target-tags=allow-valheim-server --allow tcp=tcp:2456-2458,udp:2456-2458
```

Set server container vars:

```bash
export INSTANCE_NAME="valheim-server"
export ZONE="us-west2-b"
export MACHINE_TYPE="e2-medium"
export GCS_BUCKET=${PROJECT_ID?}-valheim

export CONTAINER_IMAGE=gcr.io/${PROJECT_ID?}/valheim-server:latest
export SERVER_NAME="your server name"
export SERVER_PASSWORD="your password"
export SERVER_WORLD="Some World Name"
```

Create instance:

```bash
gcloud beta compute --project=${PROJECT_ID?} instances create-with-container ${INSTANCE_NAME?} \
    --zone=${ZONE?} \
    --machine-type=${MACHINE_TYPE?} \
    --subnet=${NETWORK?} \
    --network-tier=PREMIUM \
    --metadata=google-logging-enabled=true \
    --maintenance-policy=MIGRATE \
    --service-account=${SA_EMAIL?} \
    --scopes=https://www.googleapis.com/auth/devstorage.read_write,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --tags=allow-valheim-server \
    --image-family=cos-stable \
    --image-project=cos-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-standard \
    --boot-disk-device-name=${INSTANCE_NAME?} \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --container-image=${CONTAINER_IMAGE?} \
    --container-restart-policy=always \
    --container-env="GCS_BUCKET=${GCS_BUCKET?},SERVER_NAME=${SERVER_NAME?},SERVER_PASSWORD=${SERVER_PASSWORD?},SERVER_WORLD=${SERVER_WORLD?}" \
    --container-mount-host-path=mount-path=/home/valheim/savedata,host-path=/var/lib/docker/valheim,mode=rw
```