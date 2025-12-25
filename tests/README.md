# Testing Directory

This directory contains all test-related files for the auto_bucket backup system.

## Files

- **[docker-compose.yml](file:///d:/Pekerjaan/auto_bucket/tests/docker-compose.yml)** - Docker Compose with MySQL + MinIO
- **[.env.test](file:///d:/Pekerjaan/auto_bucket/tests/.env.test)** - Test configuration with MinIO credentials  
- **[init-mysql.sql](file:///d:/Pekerjaan/auto_bucket/tests/init-mysql.sql)** - MySQL initialization with 3 test databases
- **[test-docker.sh](file:///d:/Pekerjaan/auto_bucket/tests/test-docker.sh)** - Automated test runner script

## Quick Start

No R2 credentials needed! The test environment includes MinIO (local S3-compatible storage).

```bash
cd tests
chmod +x test-docker.sh
./test-docker.sh
```

Or manually:

```bash
cd tests

# Start all services (MySQL + MinIO)
docker-compose up -d mysql minio

# Wait for initialization
sleep 15

# Run backup
docker-compose up backup

# Cleanup
docker-compose down
```

## What Gets Tested

- ✅ Multiple database backups (test_db1, test_db2, test_db3)
- ✅ S3-compatible storage upload (MinIO)
- ✅ Backup file overwrite functionality
- ✅ Automatic cleanup

## MinIO Console

Access MinIO web console at http://localhost:9001
- Username: `minioadmin`
- Password: `minioadmin123`

You can view uploaded backups in the `test-backups` bucket.

## Prerequisites

- Docker and Docker Compose installed
- Ports 3307, 9000, 9001 available (or modify docker-compose.yml)
