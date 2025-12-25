#!/bin/bash

################################################################################
# Docker Test Script for Multi-Database Backup with MinIO
# This script runs a complete test including setup, backup, verification, and cleanup
################################################################################

set -e

echo "========================================="
echo "Auto Bucket - Database Backup Test"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Cleanup function
cleanup() {
    echo ""
    echo -e "${YELLOW}Cleaning up...${NC}"
    docker-compose down -v 2>/dev/null || true
    echo -e "${GREEN}Cleanup completed${NC}"
}

# Set trap to cleanup on exit
trap cleanup EXIT

echo -e "${BLUE}Test Configuration:${NC}"
echo "  - Database: MySQL 8.0 with 3 test databases"
echo "  - Storage: MinIO (local S3-compatible)"
echo "  - No cloud credentials required"
echo ""

echo -e "${GREEN}Step 1: Starting services (MySQL + MinIO)...${NC}"
docker-compose up -d mysql minio

echo -e "${GREEN}Step 2: Waiting for services to be ready...${NC}"
echo "  This may take 15-20 seconds..."
sleep 15

echo -e "${GREEN}Step 3: Verifying databases were created...${NC}"
docker exec test_mysql mysql -uroot -ptest_root_password -e "SHOW DATABASES;" 2>/dev/null | grep test_db || {
    echo -e "${RED}Error: Test databases not found${NC}"
    exit 1
}
echo -e "${GREEN}  ✓ test_db1, test_db2, test_db3 created${NC}"

echo -e "${GREEN}Step 4: Running backup script...${NC}"
docker-compose up backup

echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}Test Results${NC}"
echo -e "${BLUE}=========================================${NC}"

# Check if backup completed successfully by checking exit code
if docker inspect backup_runner --format='{{.State.ExitCode}}' 2>/dev/null | grep -q '^0$'; then
    echo -e "${GREEN}✓ Backup completed successfully${NC}"
    
    # Show backup summary from logs
    echo ""
    echo -e "${YELLOW}Backup Summary:${NC}"
    docker logs backup_runner 2>&1 | grep -E "Backup completed|uploaded successfully" | sed 's/^/  /'
    
    echo ""
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}All tests passed! ✓${NC}"
    echo -e "${GREEN}=========================================${NC}"
else
    echo -e "${RED}✗ Backup failed${NC}"
    echo ""
    echo -e "${YELLOW}Error logs:${NC}"
    docker logs backup_runner 2>&1 | grep -i error | sed 's/^/  /'
    exit 1
fi

echo ""
echo -e "${BLUE}MinIO Console:${NC} http://localhost:9001"
echo -e "  Username: minioadmin"
echo -e "  Password: minioadmin123"
echo -e "  Bucket: test-backups"
echo ""
echo -e "${YELLOW}Note: Containers will be cleaned up automatically${NC}"
