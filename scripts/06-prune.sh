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

log "This will permanently delete:"
log "1. The 'osm' schema in database '$DB_NAME'"
log "2. All downloaded data in ./data"
log "3. All configuration and sync state in ./config"
log "4. All log files in ./logs"
log "5. All crontab entries related to this project"
read -p "Are you absolutely sure you want to proceed? (y/N): " confirm

if [[ $confirm != "y" && $confirm != "Y" ]]; then
    log "Prune aborted"
    exit 0
fi

log "Starting prune"

# 1. Remove Cron Jobs
# We look for the main.py or any update scripts in the crontab and remove them
if crontab -l 2>/dev/null | grep -v "$(pwd)" | crontab -; then
    log "Cron jobs removed (any lines containing this directory)"
else
    log "No matching cron jobs found"
fi

# 2. Drop the Database Schema
# CASCADE is vital here: it drops all tables, indexes, and triggers inside 'osm'
log "Dropping database schema"
PGPASSWORD=$DB_PASSWORD psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" \
    -c "DROP SCHEMA IF EXISTS osm CASCADE;"
log "Schema 'osm' dropped from $DB_NAME"

# 3. Delete Local Files
log "Cleaning up local files"
rm -rf ./data
rm -rf ./config
rm -f ./logs/*.log
log "./data, ./config, and ./logs directories removed"

log "Prune complete"
log "The environment is clean. Database '$DB_NAME' and user '$DB_USER' remain untouched"
