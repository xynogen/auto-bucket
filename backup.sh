#!/bin/bash

################################################################################
# Database Backup Script with S3-Compatible Storage
# This script backs up a SQL database and uploads it to S3-compatible storage
################################################################################

set -e  # Exit on error

# ==============================================================================
# Configuration - Modify these values or set them as environment variables
# ==============================================================================

# Database Configuration
DB_TYPE="${DB_TYPE:-mysql}"              # mysql or postgresql
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-3306}"               # 3306 for MySQL, 5432 for PostgreSQL
DB_NAMES="${DB_NAMES:-${DB_NAME:-your_database_name}}"  # Comma-separated for multiple DBs
DB_USER="${DB_USER:-your_db_user}"
DB_PASSWORD="${DB_PASSWORD:-your_db_password}"

# S3 Configuration
S3_ENDPOINT="${S3_ENDPOINT:-}"           # e.g., https://s3.amazonaws.com or https://minio.example.com
S3_BUCKET="${S3_BUCKET:-your-backup-bucket}"
S3_ACCESS_KEY="${S3_ACCESS_KEY:-}"
S3_SECRET_KEY="${S3_SECRET_KEY:-}"
S3_REGION="${S3_REGION:-us-east-1}"

# Backup Configuration
BACKUP_DIR="${BACKUP_DIR:-/tmp}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILES=()  # Array to store backup file paths

# Logging
LOG_FILE="${LOG_FILE:-/var/log/database-backup.log}"

# ==============================================================================
# Functions
# ==============================================================================

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

check_dependencies() {
    log "Checking dependencies..."
    
    # Check database client
    if [ "$DB_TYPE" = "mysql" ]; then
        command -v mysqldump >/dev/null 2>&1 || error_exit "mysqldump is not installed"
    elif [ "$DB_TYPE" = "postgresql" ]; then
        command -v pg_dump >/dev/null 2>&1 || error_exit "pg_dump is not installed"
    else
        error_exit "Unsupported database type: $DB_TYPE"
    fi
    
    # Check AWS CLI
    command -v aws >/dev/null 2>&1 || error_exit "AWS CLI is not installed"
    
    log "All dependencies are installed"
}

backup_database() {
    local db_name="$1"
    local backup_file="${BACKUP_DIR}/backup_${db_name}_${TIMESTAMP}.sql"
    
    log "Starting database backup for $db_name..."
    
    if [ "$DB_TYPE" = "mysql" ]; then
        mysqldump \
            --host="$DB_HOST" \
            --port="$DB_PORT" \
            --user="$DB_USER" \
            --password="$DB_PASSWORD" \
            --single-transaction \
            --quick \
            --lock-tables=false \
            "$db_name" > "$backup_file" 2>> "$LOG_FILE" || error_exit "MySQL backup failed for $db_name"
    
    elif [ "$DB_TYPE" = "postgresql" ]; then
        PGPASSWORD="$DB_PASSWORD" pg_dump \
            --host="$DB_HOST" \
            --port="$DB_PORT" \
            --username="$DB_USER" \
            --dbname="$db_name" \
            --format=plain \
            --no-owner \
            --no-acl \
            --file="$backup_file" 2>> "$LOG_FILE" || error_exit "PostgreSQL backup failed for $db_name"
    fi
    
    # Check if backup file was created and has content
    if [ ! -s "$backup_file" ]; then
        error_exit "Backup file is empty or was not created for $db_name"
    fi
    
    local file_size=$(du -h "$backup_file" | cut -f1)
    log "Backup completed successfully for $db_name. File size: $file_size"
    
    # Add to array of backup files
    BACKUP_FILES+=("$backup_file")
}

upload_to_s3() {
    log "Uploading backups to S3-compatible storage..."
    
    # Configure AWS CLI for S3-compatible endpoint
    export AWS_ACCESS_KEY_ID="$S3_ACCESS_KEY"
    export AWS_SECRET_ACCESS_KEY="$S3_SECRET_KEY"
    
    local endpoint_arg=""
    if [ -n "$S3_ENDPOINT" ]; then
        endpoint_arg="--endpoint-url $S3_ENDPOINT"
    fi
    
    # Upload each backup file
    for backup_file in "${BACKUP_FILES[@]}"; do
        local db_name=$(basename "$backup_file" | sed "s/backup_\(.*\)_${TIMESTAMP}.sql/\1/")
        local s3_key="backup_${db_name}.sql"
        
        log "Uploading $db_name backup..."
        aws s3 cp "$backup_file" \
            "s3://${S3_BUCKET}/${s3_key}" \
            $endpoint_arg \
            --region "$S3_REGION" \
            2>> "$LOG_FILE" || error_exit "S3 upload failed for $db_name"
        
        log "Backup uploaded successfully to s3://${S3_BUCKET}/${s3_key}"
    done
}

cleanup() {
    log "Cleaning up local backup files..."
    
    # Remove current backup files
    for backup_file in "${BACKUP_FILES[@]}"; do
        if [ -f "$backup_file" ]; then
            rm -f "$backup_file" || log "WARNING: Failed to remove backup file $backup_file"
            log "Local backup file removed: $backup_file"
        fi
    done
    
    # Optional: Clean up old backup files in /tmp (older than 1 day)
    find "$BACKUP_DIR" -name "backup_*_*.sql" -type f -mtime +1 -delete 2>/dev/null || true
    
    log "Cleanup completed"
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    log "========================================="
    log "Starting database backup process"
    log "========================================="
    
    # Create log directory if it doesn't exist
    mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
    
    # Validate configuration
    if [ -z "$S3_ACCESS_KEY" ] || [ -z "$S3_SECRET_KEY" ]; then
        error_exit "S3 credentials not set. Please set S3_ACCESS_KEY and S3_SECRET_KEY"
    fi
    
    # Execute backup workflow
    check_dependencies
    
    # Parse and backup each database
    IFS=',' read -ra DBS <<< "$DB_NAMES"
    for db in "${DBS[@]}"; do
        # Trim whitespace
        db=$(echo "$db" | xargs)
        backup_database "$db"
    done
    
    upload_to_s3
    cleanup
    
    log "========================================="
    log "Backup process completed successfully"
    log "========================================="
}

# Run main function
main
