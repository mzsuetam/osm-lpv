try:
    import argparse
    import logging
    from crontab import CronTab
    import os
    from pathlib import Path
    import subprocess
    import sys
except ImportError as exc:
    print(f"Error importing module: {exc}")
    print("Please ensure all dependencies are installed.")
    print("You can use uv to manage dependencies and run the script:")
    print("  uv sync")
    print("  uv run python osm-lpv.py --help")
    sys.exit(1)


def setup_logging() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )


logger = logging.getLogger(__name__)

SCRIPT_DIR = Path('.') / "scripts"


def parse_args():
    parser = argparse.ArgumentParser(
        description="OSM LPV - Local PostgreSQL Versioning for OpenStreetMap data"
    )

    # Create the top-level command switcher
    subparsers = parser.add_subparsers(dest="command", required=True)

    # --- INIT COMMAND ---
    subparsers.add_parser("init", help="Initialize database and download data")

    # --- UPDATE COMMAND ---
    subparsers.add_parser("update", help="Run daily update and vacuum")

    # --- EDIT COMMAND ---
    edit_parser = subparsers.add_parser(
        "edit", help="Modify configuration settings")

    # Add a sub-sub-parser for 'edit' to handle 'cron'
    edit_subparsers = edit_parser.add_subparsers(
        dest="subcommand", required=True)

    # --- EDIT CRON ---
    cron_parser = edit_subparsers.add_parser(
        "cron", help="Manage crontab automation")
    cron_parser.add_argument(
        "action", choices=["on", "off"], help="Turn cron on or off")

    # --- PRUNE COMMAND ---
    subparsers.add_parser("prune", help="Prune database and local files")

    return parser.parse_args()


def manage_cron(action):

    assert action in ["on", "off"], "Action must be 'on' or 'off'"

    logger.info("Setting cron to: %s", action)

    # Get absolute paths to ensure cron works from any directory
    # Points to your uv virtualenv python
    python_executable = sys.executable
    # Points to your current script (main.py)
    script_path = os.path.abspath(__file__)

    # Define the command to run every night at 4 AM
    job_command = f"mkdir -p {os.getcwd()}/logs && {python_executable} {script_path} update >> {os.getcwd()}/logs/cron-`date +%y%m%d`.log 2>&1"

    # Access the crontab for the current user
    cron = CronTab(user=True)

    # Check if the job already exists (by searching for the script path)
    existing_jobs = list(cron.find_command(script_path))

    if action == "on":
        if not existing_jobs:
            job = cron.new(command=job_command, comment="OSM LPV Daily Update")
            job.setall('0 4 * * *')  # Runs at 04:00 daily
            cron.write()
            logger.info("Cron job enabled: runs daily at 04:00")
        else:
            logger.info("Cron job is already active")

    elif action == "off":
        if existing_jobs:
            cron.remove_all(command=script_path)
            cron.write()
            logger.info("Cron job disabled")
        else:
            logger.info("No active cron job found to disable")


def _run_script(script_name: str) -> None:
    script_path = SCRIPT_DIR / script_name
    if not script_path.exists():
        raise FileNotFoundError(f"Script not found: {script_path}")

    logger.info("Running script: %s", script_path)
    try:
        subprocess.run(["bash", str(script_path)], check=True)
    except subprocess.CalledProcessError as exc:
        logger.error("Script failed (%s) with exit code %s",
                     script_path, exc.returncode)
        raise

    logger.info("Completed script: %s", script_path)


def init_logic():
    logger.info("Initializing database and downloading data...")
    init_scripts = [
        "00-get-data.sh",
        "01-init-db.sh",
        "02-create-schema.sh",
        "03-populate.sh",
        "04-configure-auto-update.sh",
    ]

    for script_name in init_scripts:
        _run_script(script_name)

    logger.info("Init flow completed successfully")


def update_logic():
    logger.info("Running daily update and vacuum...")
    _run_script("05-update.sh")
    logger.info("Update flow completed successfully")
    logger.info("Removing old log files...")
    _run_script("07-clean-logs.sh")
    logger.info("Old log files removed successfully")


def prune_logic():
    logger.info("Pruning database and local files...")
    _run_script("06-prune.sh")
    logger.info("Prune flow completed successfully")


if __name__ == "__main__":
    setup_logging()
    args = parse_args()

    if args.command == "init":
        init_logic()

    elif args.command == "update":
        update_logic()

    elif args.command == "edit":
        if args.subcommand == "cron":
            manage_cron(args.action)

    elif args.command == "prune":
        prune_logic()
