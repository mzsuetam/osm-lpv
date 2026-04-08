#!/bin/bash

set -euo pipefail

log() {
        printf '%s [INFO] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

error() {
        printf '%s [ERROR] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

trap 'error "Failed at line $LINENO while running: $BASH_COMMAND"' ERR

log "Loading environment from .env"
source .env

log "Applying replication changes to PostgreSQL"
# NOTE: password should be moved to ~/.pgpass for security reasons, but for simplicity we use env vars here
$OSMOSIS_BIN --read-replication-interval workingDirectory="./config" \
        --simplify-change \
        --write-pgsql-change host="$DB_HOST" \
        database="$DB_NAME" \
        user="$DB_USER" \
        password="$DB_PASSWORD"

log "Running VACUUM ANALYZE on OSM tables"
PGPASSWORD=$DB_PASSWORD psql \
    -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" \
    -c "VACUUM ANALYZE osm.nodes, osm.ways, osm.way_nodes, osm.relations, osm.users;"

log "Update script completed successfully"
