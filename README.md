# OSM LPV – OpenStreetMap Lesser Poland Voivodeship

OSM LPV is a Python script designed to automate the process of downloading, processing, and updating OpenStreetMap (OSM) data for the Lesser Poland Voivodeship region. The script performs a series of tasks including data retrieval, database management, and scheduled updates.

**Author**: Mateusz Mazur

## Requirements

### Database

The script asserts the existence of the database and its user.
Please fill in the credentials in the `.env` file (see `.env.example`).

### Technical

- postgresql
- postgis
- osmosis

```bash
sudo apt install postgresql osmosis postgresql-16-postgis-3
```

## Usage

### First Run

On the first run, execute the script with the `init` command to set up the database and import the initial data:

```bash
uv sync # Install dependencies
uv run osm-lpv init
```

This will create the database, set up the necessary tables, and import the initial OSM data for the Lesser Poland Voivodeship region.

### Manual Updates

To manually trigger an update of the OSM data, run the script with the `update` command:

```bash
uv run osm-lpv update
```

### Scheduled Updates

To enable automatic updates, use the `cron` command to set up a cron job that runs the update process every night at 4 AM:

```bash
uv run osm-lpv cron on
```

To disable the cron job, run:

```bash
uv run osm-lpv cron off
```

The script generates log files for each update run, stored in the `logs` directory. Each log file is named with the date of the update (e.g., `cron-240601.log`). Old log files (older than 30 days) are automatically removed during the update process.

### Pruning Data

To prune the database and local files, run the script with the `prune` command:

```bash
uv run osm-lpv prune
```

## Future work

- Extend the script to accept a region as an argument, allowing users to specify which OSM data to process.
- Extend the script to accept multiple regions, enabling batch processing of OSM data for various areas.
