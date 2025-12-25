#!/bin/bash

################################################################################
# Backup Wrapper Script
# This script loads environment variables and runs the database backup
################################################################################

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to script directory
cd "$SCRIPT_DIR" || exit 1

# Load environment variables from .env.backup
if [ -f ".env.backup" ]; then
    source .env.backup
else
    echo "Error: .env.backup file not found in $SCRIPT_DIR"
    exit 1
fi

# Run the backup script
./backup.sh
