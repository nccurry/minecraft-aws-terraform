[Unit]
Description=PaperMC Minecraft Server
Documentation=https://github.com/mtoensing/Docker-Minecraft-PaperMC-Server
Wants=network-online.target
After=network-online.target
RequiresMountsFor=%t/containers
Requires=var-opt-mcserver.mount
After=download-papermc-plugins.service

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Restart=on-failure
TimeoutStopSec=70

ExecStartPre=/usr/bin/podman pull \
        ${papermc_container_image}:${papermc_container_tag}

ExecStart=/usr/bin/podman run \
        --cidfile=%t/%n.ctr-id \
        --cgroups=no-conmon \
        --rm \
        --sdnotify=conmon \
        --replace \
        --detach \
        --name mcserver \
        --env PUID=1000 \
        --env PGID=1000 \
        --env MEMORYSIZE=${papermc_server_memorysize} \
        --env TZ="America/Chicago" \
        --volume ${mcserver_data_dir}:/data:Z \
        --publish 25565:25565/tcp \
        --publish 19132:19132/udp \
        --publish 8804:8804/tcp \
        --publish 8100:8100/tcp \
        ${papermc_container_image}:${papermc_container_tag}

ExecStop=/usr/bin/podman stop \
        --ignore -t 10 \
        --cidfile=%t/%n.ctr-id
ExecStopPost=/usr/bin/podman rm \
        -f \
        --ignore -t 10 \
        --cidfile=%t/%n.ctr-id

Type=notify
NotifyAccess=all

[Install]
WantedBy=default.target

