#!/bin/bash

set -euo pipefail

log() {
    printf '%s [INFO] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

error() {
    printf '%s [ERROR] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

trap 'error "Failed at line $LINENO while running: $BASH_COMMAND"' ERR

CONFIG_FILE="./config/configuration.txt"
STATE_FILE="./config/state.txt"

log "Resetting previous replication configuration files"
rm -f "$CONFIG_FILE"
rm -f "$STATE_FILE"

log "Ensuring config directory exists"
mkdir -p ./config
log "Generating replication config template via osmosis"
$OSMOSIS_BIN --rrii workingDirectory="./config"

# # This points daily updates to Małopolskie instead of the whole planet
if [ -f "$CONFIG_FILE" ]; then
    log "Patching replication source and interval in $CONFIG_FILE"
    sed -i 's|baseUrl=.*|baseUrl=http://download.geofabrik.de/europe/poland/malopolskie-updates|' "$CONFIG_FILE"
    sed -i 's|maxInterval =.*|maxInterval = 0|' "$CONFIG_FILE"
    log "Successfully patched $CONFIG_FILE for Małopolskie updates"
else
    error "Expected configuration file not found: $CONFIG_FILE"
    exit 1
fi

log "Downloading latest replication state file"
curl -L https://download.geofabrik.de/europe/poland/malopolskie-updates/state.txt \
    -o "$STATE_FILE"

log "Auto-update configuration script completed successfully"
