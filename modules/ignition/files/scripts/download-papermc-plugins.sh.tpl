#!/usr/bin/env bash
# Script to download PaperMC plugins to the ${mcserver_data_dir}/plugins directory

pluginDir="${mcserver_data_dir}/plugins"
mkdir -p $pluginDir

declare -A files=(
    ["Geyser-Spigot.jar"]="https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot"
    ["floodgate-bukkit.jar"]="https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot"
    ["Plan-5.5-build-2391.jar"]="https://github.com/plan-player-analytics/Plan/releases/download/5.5.2391/Plan-5.5-build-2391.jar"
    ["BlueMap-3.13-spigot.jar"]="https://github.com/BlueMap-Minecraft/BlueMap/releases/download/v3.13/BlueMap-3.13-spigot.jar"
)

for file in "$${!files[@]}"; do
    url=$${files[$file]}
    # If the file doesn't exist, download it
    if [[ ! -f $file ]]; then
        curl -o "$file" "$url"
    fi
done

chown -R core:core $pluginDir
chmod -R 774 $pluginDir