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
    PLAN_URL="https://github.com/plan-player-analytics/Plan/releases/download/5.5.2391/Plan-5.5-build-2391.jar"; \
    BLUEMAP_URL="https://github.com/BlueMap-Minecraft/BlueMap/releases/download/v3.13/BlueMap-3.13-spigot.jar"; \
    mkdir -p $PLUGIN_DIR; \
    curl -L -o $PLUGIN_DIR/Geyser-Spigot.jar "$GEYSER_URL"; \
    curl -L -o $PLUGIN_DIR/floodgate-bukkit.jar "$FLOODGATE_URL"; \
    curl -L -o $PLUGIN_DIR/Plan-5.5-build-2391.jar "$PLAN_URL"; \
    curl -L -o $PLUGIN_DIR/BlueMap-3.13-spigot.jar "$BLUEMAP_URL"; \
    chown -R core:core $PLUGIN_DIR; \
    chmod -R 770 $PLUGIN_DIR;'

[Install]
WantedBy=multi-user.target