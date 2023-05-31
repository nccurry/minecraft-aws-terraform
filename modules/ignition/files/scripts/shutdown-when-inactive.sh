#!/usr/bin/env bash

log_message() {
    systemd-cat -t "shutdown-when-inactive.sh" <<< "$(date +"%Y-%m-%d %H:%M:%S") $1"
}

api_endpoint="http://localhost:4567/v1/server"
onlinePlayers=$(curl -s "$api_endpoint" | jq '.onlinePlayers')

if [[ "$onlinePlayers" -eq 0 ]]; then
    log_message "Current player count is 0."

    # Check if server was already marked for shutdown
    if [[ -f "/tmp/server_shutdown" ]]; then
        shutdown_duration=$(($(date +%s) - $(stat -c %Y /tmp/server_shutdown)))

        # Check if shutdown duration exceeds 10 minutes
        if [[ "$shutdown_duration" -ge 600 ]]; then
            log_message "Current player count has been 0 for more than 10 minutes. Initiating server shutdown."
            # Uncomment the line below to initiate the server shutdown command
            # shutdown -h now
        fi
    else
        log_message "Marking server for shutdown."
        touch /tmp/server_shutdown
    fi
else
    log_message "Current player count is $onlinePlayers, not 0. Clearing shutdown status."
    rm -f /tmp/server_shutdown
fi