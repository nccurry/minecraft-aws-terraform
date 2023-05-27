#!/bin/bash

# Update the system
sudo apt update -y
sudo apt upgrade -y

# Install necessary software
sudo apt install -y \
	wget \
	screen \
	openjdk-11-jre-headless \
	jq

# Create a directory for the Minecraft server
mkdir ~/minecraft
cd ~/minecraft

# Fetch the latest version of the Minecraft server
VERSION=$(curl https://launchermeta.mojang.com/mc/game/version_manifest.json | jq -r '.latest.release')
SERVER_URL=$(curl https://launchermeta.mojang.com/mc/game/version_manifest.json | jq --arg VERSION "$VERSION" -r '.versions[] | select(.id==$VERSION) | .url')
SERVER_JAR_URL=$(curl $SERVER_URL | jq -r '.downloads.server.url')

# Download the server jar
wget $SERVER_JAR_URL -O minecraft_server.jar

# Create the eula.txt file to agree to the terms
echo "eula=true" > eula.txt

# Create a start script for the Minecraft server
echo '#!/bin/bash
java -Xmx1024M -Xms1024M -jar minecraft_server.jar nogui' > start.sh
chmod +x start.sh

# Create a screen session for the Minecraft server
echo '#!/bin/bash
screen -dmS minecraft ~/minecraft/start.sh' > minecraft.service
chmod +x minecraft.service

# Run the Minecraft server
~/minecraft/minecraft.service