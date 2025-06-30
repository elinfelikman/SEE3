#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
NETWORK_NAME="SEE3"
DB_CONTAINER_NAME="SEE3-db"
APP_CONTAINER_NAME="joomla-app"

DB_VOLUME_NAME="mysql-data"
APP_VOLUME_NAME="joomla-data"

MYSQL_ROOT_PASS="my-secret-pw"
JOOMLA_DB="joomla_db"
JOOMLA_USER="joomla_user"
JOOMLA_PASS="joomla_password"

# --- Script Start ---
echo "### Starting Joomla Site Restore ###"

# 1. Find the latest backup files
echo "--> Finding latest backup files..."
LATEST_DB_BACKUP=$(ls -t joomla-database-backup-*.sql.gz 2>/dev/null | head -n 1)
LATEST_FILES_BACKUP=$(ls -t joomla-files-backup-*.tar.gz 2>/dev/null | head -n 1)

if [[ -z "$LATEST_DB_BACKUP" || -z "$LATEST_FILES_BACKUP" ]]; then
    echo "!!! Error: Backup files not found. Make sure they are in the current directory."
    exit 1
fi

echo "--> Using Database Backup: $LATEST_DB_BACKUP"
echo "--> Using Files Backup:    $LATEST_FILES_BACKUP"


# 2. Clean up existing environment (if it exists)
echo "--> Removing old containers and volumes..."
docker rm -f $APP_CONTAINER_NAME $DB_CONTAINER_NAME &>/dev/null || true
docker volume rm $APP_VOLUME_NAME $DB_VOLUME_NAME &>/dev/null || true


# 3. Recreate infrastructure
echo "--> Recreating network and volumes..."
docker network create $NETWORK_NAME &>/dev/null || true
docker volume create $DB_VOLUME_NAME
docker volume create $APP_VOLUME_NAME


# 4. Restore Filesystem FIRST
echo "--> Restoring Joomla files..."
docker run --rm -v $APP_VOLUME_NAME:/volume -v $(pwd):/backup alpine sh -c "tar xzf /backup/$LATEST_FILES_BACKUP -C /volume"


# 5. Start a fresh MySQL container
echo "--> Starting a fresh MySQL container..."
docker run --name $DB_CONTAINER_NAME \
    --network $NETWORK_NAME \
    -p 3306:3306 \
    -v $DB_VOLUME_NAME:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASS \
    -e MYSQL_DATABASE=$JOOMLA_DB \
    -e MYSQL_USER=$JOOMLA_USER \
    -e MYSQL_PASSWORD=$JOOMLA_PASS \
    -d mysql:8.0

echo "--> Waiting 20 seconds for database to initialize..."
sleep 20


# 6. Restore Database
echo "--> Restoring database from $LATEST_DB_BACKUP..."
gunzip < $LATEST_DB_BACKUP | docker exec -i $DB_CONTAINER_NAME mysql -u"$JOOMLA_USER" -p"$JOOMLA_PASS" "$JOOMLA_DB"

# 7. Start Joomla Container
echo "--> Starting Joomla container with restored data..."
docker run --name $APP_CONTAINER_NAME \
    --network $NETWORK_NAME \
    -p 8080:80 \
    -v $APP_VOLUME_NAME:/var/www/html \
    -e JOOMLA_DB_HOST=$DB_CONTAINER_NAME \
    -e JOOMLA_DB_USER=$JOOMLA_USER \
    -e JOOMLA_DB_PASSWORD=$JOOMLA_PASS \
    -e JOOMLA_DB_NAME=$JOOMLA_DB \
    -d joomla:latest

# 8. Final Verification
echo "--> Verifying running containers..."
docker ps

echo "### Restore Complete! ###"
echo "Joomla should be available at http://localhost:8080 shortly."