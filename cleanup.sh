#!/bin/bash

# --- Configuration ---
NETWORK_NAME="SEE3"
DB_CONTAINER_NAME="SEE3-db"
APP_CONTAINER_NAME="joomla-app"

DB_VOLUME_NAME="mysql-data"
APP_VOLUME_NAME="joomla-data"

DB_IMAGE="mysql:8.0"
APP_IMAGE="joomla:latest"


# --- Script Start ---
echo "### Starting Full Environment Cleanup ###"

# 1. Stop and remove containers
echo "--> Stopping and removing containers..."
docker stop $APP_CONTAINER_NAME $DB_CONTAINER_NAME &>/dev/null || true
docker rm $APP_CONTAINER_NAME $DB_CONTAINER_NAME &>/dev/null || true

# 2. Remove volumes (THIS DELETES ALL DATA)
echo "--> WARNING: Deleting volumes (all site and database data)..."
docker volume rm $APP_VOLUME_NAME $DB_VOLUME_NAME &>/dev/null || true

# 3. Remove network
echo "--> Removing Docker network..."
docker network rm $NETWORK_NAME &>/dev/null || true

# 4. Remove images
echo "--> Removing Docker images..."
docker rmi $APP_IMAGE $DB_IMAGE &>/dev/null || true

# 5. Remove local backup files
# echo "--> Removing local backup files..."
# rm -f joomla-database-backup-*.sql.gz joomla-files-backup-*.tar.gz

echo ""
echo "### Cleanup Complete! ###"