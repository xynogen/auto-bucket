# Database Backup to Cloudflare R2

Automated cron job that backs up your SQL database to Cloudflare R2 storage.

## Quick Setup

### 1. Install Dependencies

```bash
# MySQL
sudo apt-get install mysql-client awscli

# OR PostgreSQL
sudo apt-get install postgresql-client awscli
```

### 2. Configure R2 Credentials

Get your R2 API tokens from: https://dash.cloudflare.com/?to=/:account/r2/overview/api-tokens

```bash
cp .env.backup.example .env.backup
nano .env.backup
```

Update these values:
- `S3_ENDPOINT`: Your R2 endpoint (format: `https://YOUR_ACCOUNT_ID.r2.cloudflarestorage.com`)
- `S3_BUCKET`: Your R2 bucket name
- `S3_ACCESS_KEY` & `S3_SECRET_KEY`: From R2 API tokens
- `DB_NAMES`: Single database name or comma-separated list for multiple databases
- Database credentials

### 3. Test the Backup

```bash
chmod +x backup.sh run-backup.sh
./run-backup.sh
```

Check the log:
```bash
tail -f /var/log/database-backup.log
```

### 4. Setup Cron

Add to crontab:
```bash
crontab -e
```

**Daily at 2 AM:**
```
0 2 * * * /path/to/auto_bucket/run-backup.sh
```

Replace `/path/to/auto_bucket` with your actual path (e.g., `/home/user/auto_bucket`).

**Other schedules:**
```bash
# Every 6 hours
0 */6 * * * /path/to/auto_bucket/run-backup.sh

# Every hour  
0 * * * * /path/to/auto_bucket/run-backup.sh

# Every day at 3 AM
0 3 * * * /path/to/auto_bucket/run-backup.sh
```

## How It Works

1. ✅ Dumps database(s) to `/tmp/backup_[dbname]_[timestamp].sql`
2. ✅ Uploads to R2 as `backup_[dbname].sql` (overwrites previous backup - no bucket bloat)
3. ✅ Cleans up local files

### Multiple Database Support

Backup multiple databases by specifying a comma-separated list:

```bash
# In .env.backup
DB_NAMES=database1,database2,database3
```

Each database will be:
- Backed up separately
- Uploaded as `backup_database1.sql`, `backup_database2.sql`, etc.
- Maintained independently in R2

## R2 Bucket Setup

1. Create bucket at: https://dash.cloudflare.com/?to=/:account/r2
2. Generate API token with "Edit" permissions
3. Copy Account ID from R2 dashboard for the endpoint URL

## Troubleshooting

**Database connection test:**
```bash
# MySQL
mysql -h localhost -u user -ppassword -e "SELECT 1"

# PostgreSQL
PGPASSWORD=password psql -h localhost -U user -d dbname -c "SELECT 1"
```

**R2 connection test:**
```bash
source .env.backup
aws s3 ls s3://$S3_BUCKET --endpoint-url $S3_ENDPOINT
```

**View logs:**
```bash
tail -f /var/log/database-backup.log
```

## Security

```bash
# Protect credentials
chmod 600 .env.backup

# Add to .gitignore
echo ".env.backup" >> .gitignore
```
