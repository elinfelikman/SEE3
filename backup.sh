#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
DB_CONTAINER_NAME="SEE3-db"
APP_VOLUME_NAME="joomla-data"

JOOMLA_DB="joomla_db"
JOOMLA_USER="joomla_user"
JOOMLA_PASS="joomla_password"

# Generate a timestamp for unique backup filenames
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
DB_BACKUP_FILE="joomla-database-backup-${TIMESTAMP}.sql.gz"
FILES_BACKUP_FILE="joomla-files-backup-${TIMESTAMP}.tar.gz"


# --- Script Start ---
echo "### Starting Full Joomla Backup ###"

# 1. Back up the Database
echo "--> Backing up MySQL database: $JOOMLA_DB..."
docker exec $DB_CONTAINER_NAME sh -c 'exec mysqldump '"$JOOMLA_DB"' -u"'"$JOOMLA_USER"'" -p"'"$JOOMLA_PASS"'"' | gzip > $DB_BACKUP_FILE

# 2. Back up the Filesystem Volume
echo "--> Backing up Joomla files volume: $APP_VOLUME_NAME..."
docker run --rm -v $APP_VOLUME_NAME:/volume -v $(pwd):/backup alpine tar czf /backup/$FILES_BACKUP_FILE -C /volume ./

# 3. Final Report
echo ""
echo "### Backup Complete! ###"
echo "Created backup files:"
echo "- Database: $DB_BACKUP_FILE"
echo "- Files:    $FILES_BACKUP_FILE"