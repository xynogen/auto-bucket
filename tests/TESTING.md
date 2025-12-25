# Docker Testing Guide

## Current Status
✅ MySQL container running with 3 test databases
✅ Test data loaded successfully  
❌ Backup script needs R2 credentials

## Next Steps

### 1. Configure R2 Credentials

Edit your `.env.backup` file and add your R2 credentials:

```bash
# Get these from: https://dash.cloudflare.com/?to=/:account/r2/overview/api-tokens
S3_ENDPOINT=https://YOUR_ACCOUNT_ID.r2.cloudflarestorage.com
S3_BUCKET=your-backup-bucket
S3_ACCESS_KEY=your_actual_r2_access_key_id
S3_SECRET_KEY=your_actual_r2_secret_access_key
```

### 2. Database Configuration

Your `.env.backup` should have these database settings for the Docker test:

```bash
DB_TYPE=mysql
DB_HOST=mysql                    # Docker service name
DB_PORT=3306
DB_NAMES=test_db1,test_db2,test_db3
DB_USER=root
DB_PASSWORD=test_root_password
```

### 3. Run the Test

Once credentials are configured:

```powershell
# Run backup container
docker-compose -f docker-compose.test.yml up backup

# Check the logs
cat logs/database-backup.log

# Verify backups in R2
aws s3 ls s3://your-bucket --endpoint-url https://your-endpoint
```

### 4. Cleanup

```powershell
# Stop containers
docker-compose -f docker-compose.test.yml down

# Remove volumes (optional - to start fresh next time)
docker-compose -f docker-compose.test.yml down -v
```

## What to Expect

When successful, you should see:
```
[2025-12-26 00:29:00] Starting database backup for test_db1...
[2025-12-26 00:29:01] Backup completed successfully for test_db1. File size: 2.1K
[2025-12-26 00:29:01] Starting database backup for test_db2...
[2025-12-26 00:29:02] Backup completed successfully for test_db2. File size: 2.0K
[2025-12-26 00:29:02] Starting database backup for test_db3...
[2025-12-26 00:29:03] Backup completed successfully for test_db3. File size: 2.0K
[2025-12-26 00:29:03] Uploading backups to S3-compatible storage...
[2025-12-26 00:29:03] Uploading test_db1 backup...
[2025-12-26 00:29:05] Backup uploaded successfully to s3://bucket/backup_test_db1.sql
[2025-12-26 00:29:05] Uploading test_db2 backup...
[2025-12-26 00:29:07] Backup uploaded successfully to s3://bucket/backup_test_db2.sql
[2025-12-26 00:29:07] Uploading test_db3 backup...
[2025-12-26 00:29:09] Backup uploaded successfully to s3://bucket/backup_test_db3.sql
```

And in R2, you'll find:
- `backup_test_db1.sql`
- `backup_test_db2.sql`
- `backup_test_db3.sql`
