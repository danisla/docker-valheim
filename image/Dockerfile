FROM steamcmd/steamcmd:latest

RUN apt-get update && \
	apt-get -y install --no-install-recommends libsdl2-2.0-0:i386 curl unzip cron && \
	rm -rf /var/lib/apt/lists/*

# Install rclone and GCS config
RUN cd /tmp && \
    curl -s -L https://github.com/rclone/rclone/releases/download/v1.54.0/rclone-v1.54.0-linux-amd64.zip > rclone.zip && \
    unzip -p rclone.zip rclone-v1.54.0-linux-amd64/rclone > /usr/bin/rclone && \
    chmod +x /usr/bin/rclone && \
    rm -f rclone.zip
COPY rclone.conf /root/.config/rclone/rclone.conf

RUN mkdir -p /home/valheim/data/ && mkdir -p /home/valheim/scripts/ && ulimit -n 2048

WORKDIR /home/valheim

ADD entrypoint.sh /home/valheim/entrypoint.sh
ADD start-server.sh /home/valheim/start-server.sh
RUN chmod +x /home/valheim/entrypoint.sh && chmod +x /home/valheim/start-server.sh

# Install backup scripts and cronjob.
ADD gcs-backup.sh gcs-restore.sh install-cronjob.sh /home/valheim/
RUN chmod +x /home/valheim/gcs-backup.sh && \
    chmod +x /home/valheim/gcs-restore.sh && \
    chmod +x /home/valheim/install-cronjob.sh

EXPOSE 2456/udp
EXPOSE 2456/tcp
EXPOSE 2457/udp
EXPOSE 2457/tcp
EXPOSE 2458/udp
EXPOSE 2458/tcp

ENV SERVER_NAME="Valheim Server"
ENV SERVER_PASSWORD=""
ENV SERVER_WORLD="World"
ENV SERVER_PORT=2456
ENV SAVEDIR=/home/valheim/savedata
ENV BACKUPDIR=/home/valheim/backupdata
ENV GCS_BUCKET=YOUR_PROJECT-valheim

ENTRYPOINT  ["/bin/sh", "entrypoint.sh"]

CMD ["/bin/bash", "start-server.sh", "-n"]
