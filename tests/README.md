# Testing Directory

This directory contains all test-related files for the auto_bucket backup system.

## Files

- **[docker-compose.test.yml](file:///d:/Pekerjaan/auto_bucket/tests/docker-compose.test.yml)** - Docker Compose configuration for test environment
- **[init-mysql.sql](file:///d:/Pekerjaan/auto_bucket/tests/init-mysql.sql)** - MySQL initialization with 3 test databases
- **[test-docker.sh](file:///d:/Pekerjaan/auto_bucket/tests/test-docker.sh)** - Automated test runner script
- **[TESTING.md](file:///d:/Pekerjaan/auto_bucket/tests/TESTING.md)** - Detailed testing instructions

## Quick Start

```bash
cd tests
chmod +x test-docker.sh
./test-docker.sh
```

Or manually:

```bash
cd tests

# Start MySQL
docker-compose up -d mysql

# Wait for initialization
sleep 15

# Run backup
docker-compose up backup

# Cleanup
docker-compose down
```

## Prerequisites

- Docker and Docker Compose installed
- `.env.backup` configured in parent directory with R2 credentials
- Port 3307 available (or modify docker-compose.test.yml)
