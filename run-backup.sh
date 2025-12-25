#!/bin/bash

################################################################################
# Backup Wrapper Script
# This script loads environment variables and runs the database backup
################################################################################

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to script directory
cd "$SCRIPT_DIR" || exit 1

# Load environment variables from .env
if [ ! -f ".env" ]; then
    echo "Error: .env file not found in $SCRIPT_DIR"
    echo "Please copy .env.example to .env and configure it"
    exit 1
fi

set -a  # Automatically export all variables
source ".env"
set +a  # Stop auto-exporting

# Run the backup script
./backup.sh
