#!/bin/bash

set -euo pipefail

log() {
        printf '%s [INFO] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

error() {
        printf '%s [ERROR] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

trap 'error "Failed at line $LINENO while running: $BASH_COMMAND"' ERR

# load password from .env file
log "Loading environment from .env"
source .env

RAM_JAVA_LIMIT="2G"

export JAVACMD_OPTIONS="-Xmx$RAM_JAVA_LIMIT"

log "Importing OSM data into PostgreSQL database"
log "Using Java RAM limit: $RAM_JAVA_LIMIT"
log "This step can take several minutes"

# NOTE: password should be moved to ~/.pgpass for security reasons, but for simplicity we use env vars here
osmosis --read-pbf file="./data/malopolskie-latest.osm.pbf" \
        --write-pgsql host="$DB_HOST" \
        database="$DB_NAME" \
        user="$DB_USER" \
        password="$DB_PASSWORD"

log "Data import completed successfully"
        