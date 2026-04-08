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

log "Applying base snapshot schema"
PGPASSWORD=$DB_PASSWORD psql \
    -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" \
    -f /usr/share/doc/osmosis/examples/pgsnapshot_schema_0.6.sql

log "Applying action schema"
PGPASSWORD=$DB_PASSWORD psql \
    -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" \
    -f /usr/share/doc/osmosis/examples/pgsnapshot_schema_0.6_action.sql

log "Applying bbox schema"
PGPASSWORD=$DB_PASSWORD psql \
    -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" \
    -f /usr/share/doc/osmosis/examples/pgsnapshot_schema_0.6_bbox.sql

log "Applying linestring schema"
PGPASSWORD=$DB_PASSWORD psql \
    -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" \
    -f /usr/share/doc/osmosis/examples/pgsnapshot_schema_0.6_linestring.sql

log "Schema creation script completed successfully"
