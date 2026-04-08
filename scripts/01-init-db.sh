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

log "Installing PostgreSQL extensions as superuser"
# Note: We connect as user 'postgres', usually using peer authentication locally
sudo -u postgres psql -d "$DB_NAME" \
    -c "CREATE EXTENSION IF NOT EXISTS postgis; CREATE EXTENSION IF NOT EXISTS hstore;"

log "Initializing schema and roles as database user: $DB_USER"
# Now run your script as the regular user for the rest
PGPASSWORD=$DB_PASSWORD psql \
    -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" \
    -v db_user="$DB_USER" \
    -f ./scripts/01-init-db.sql

log "Database initialization script completed successfully"
