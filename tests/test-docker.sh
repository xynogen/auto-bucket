#!/bin/bash

################################################################################
# Docker Test Script for Multi-Database Backup
# This script spins up MySQL containers and tests the backup functionality
################################################################################

set -e

echo "========================================="
echo "Starting Docker Backup Test"
echo "========================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if .env.backup exists in parent directory
if [ ! -f "../.env.backup" ]; then
    echo -e "${YELLOW}Warning: .env.backup not found in parent directory.${NC}"
    echo -e "${RED}Please create ../.env.backup with your R2 credentials and run again.${NC}"
    exit 1
fi

# Create logs directory in parent
mkdir -p ../logs

echo -e "${GREEN}Step 1: Starting MySQL container...${NC}"
docker-compose up -d mysql

echo -e "${GREEN}Step 2: Waiting for MySQL to be ready...${NC}"
sleep 10

echo -e "${GREEN}Step 3: Verifying databases were created...${NC}"
docker exec test_mysql mysql -uroot -ptest_root_password -e "SHOW DATABASES;" | grep test_db

echo -e "${GREEN}Step 4: Running backup script...${NC}"
docker-compose up backup

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Test Results:${NC}"
echo -e "${GREEN}=========================================${NC}"

# Check logs
if [ -f ../logs/database-backup.log ]; then
    echo -e "${YELLOW}Backup Log:${NC}"
    cat ../logs/database-backup.log
else
    echo -e "${RED}No log file found at ../logs/database-backup.log${NC}"
fi

echo ""
echo -e "${GREEN}Cleaning up containers...${NC}"
docker-compose down

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Test completed!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Check your R2 bucket for the backup files:"
echo "   - backup_test_db1.sql"
echo "   - backup_test_db2.sql"
echo "   - backup_test_db3.sql"
echo ""
echo "2. To verify backups manually:"
echo "   aws s3 ls s3://your-bucket --endpoint-url https://your-endpoint"
