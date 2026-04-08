#!/bin/bash

set -euo pipefail

log() {
	printf '%s [INFO] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

error() {
	printf '%s [ERROR] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

trap 'error "Failed at line $LINENO while running: $BASH_COMMAND"' ERR

log "Starting data download script"

log "Ensuring data directory exists"
mkdir -p data

log "Downloading PBF extract: data/malopolskie-latest.osm.pbf"
curl -L https://download.geofabrik.de/europe/poland/malopolskie-latest.osm.pbf \
    -o data/malopolskie-latest.osm.pbf

log "Downloading polygon file: data/malopolskie.poly"
curl -L https://download.geofabrik.de/europe/poland/malopolskie.poly \
    -o data/malopolskie.poly

log "Data download script completed successfully"