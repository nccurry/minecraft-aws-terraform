#!/usr/bin/env bash
# Script to backup and shutdown the server when there are no users

waitTimeSeconds=1800 # 30 minutes

logMessage() {
    systemd-cat -t "shutdown-when-inactive.sh" <<< "$(date +"%Y-%m-%d %H:%M:%S") $1"
}

apiEndpoint="http://localhost:4567/v1/server"
onlinePlayers=$(curl -s "$apiEndpoint" | jq '.onlinePlayers')

if [[ "$onlinePlayers" -eq 0 ]]; then
    logMessage "Current player count is 0."

    # Check if server was already marked for shutdown
    if [[ -f "/tmp/server_shutdown" ]]; then
        timeLeftSeconds=$(($(date +%s) - $(stat -c %Y /tmp/server_shutdown)))

        # Check if shutdown duration exceeds 10 minutes
        if [[ "$timeLeftSeconds" -ge $waitTimeSeconds ]]; then
            logMessage "Current player count has been 0 for more than $waitTimeSeconds seconds. Initiating server shutdown."
            systemctl stop mcserver.service
            # TODO: Implement automatic backup here
            shutdown -h now
        else
          logMessage "Current player is 0. Shutting down in $timeLeftSeconds seconds."
        fi
    else
        logMessage "Marking server for shutdown in $waitTimeSeconds seconds."
        echo "Server marked for shutdown" > /tmp/server_shutdown
    fi
else
    logMessage "Current player count is $onlinePlayers. Clearing shutdown status."
    rm -f /tmp/server_shutdown
fi