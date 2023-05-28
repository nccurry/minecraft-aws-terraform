[Unit]
Description=Download PaperMC Plugins
After=var-opt-mcserver.mount
Requires=var-opt-mcserver.mount

[Service]
Type=oneshot
ExecStart=/bin/bash -c '\
    PLUGIN_DIR="${mcserver_data_dir}/plugins"; \
    GEYSER_URL="https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot"; \
    FLOODGATE_URL="https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot"; \
    mkdir -p $PLUGIN_DIR; \
    curl -L -o $PLUGIN_DIR/Geyser-Spigot.jar "$GEYSER_URL"; \
    curl -L -o $PLUGIN_DIR/floodgate-bukkit.jar "$FLOODGATE_URL"; \
    chown -R core:core $PLUGIN_DIR; \
    chmod -R 770 $PLUGIN_DIR;'



[Install]
WantedBy=multi-user.target