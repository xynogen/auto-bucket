#!/bin/bash

################################################################################
# Backup Wrapper Script
# This script loads environment variables and runs the database backup
################################################################################

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to script directory
cd "$SCRIPT_DIR" || exit 1

# Load environment variables from .env.backup or .env
if [ -f ".env.backup" ]; then
    ENV_FILE=".env.backup"
    echo "Loading configuration from .env.backup"
elif [ -f ".env" ]; then
    ENV_FILE=".env"
    echo "Loading configuration from .env"
else
    echo "Error: Neither .env.backup nor .env file found in $SCRIPT_DIR"
    exit 1
fi

set -a  # Automatically export all variables
source "$ENV_FILE"
set +a  # Stop auto-exporting

# Run the backup script
./backup.sh
