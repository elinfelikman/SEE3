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
echo "### Starting Joomla Environment Setup ###"

# 1. Create Docker Network
echo "--> Creating Docker network: $NETWORK_NAME..."
docker network create $NETWORK_NAME || echo "Network $NETWORK_NAME already exists."

# 2. Start MySQL Container
echo "--> Starting MySQL container: $DB_CONTAINER_NAME..."
docker run --name $DB_CONTAINER_NAME \
    --network $NETWORK_NAME \
    -p 3306:3306 \
    -v $DB_VOLUME_NAME:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASS \
    -e MYSQL_DATABASE=$JOOMLA_DB \
    -e MYSQL_USER=$JOOMLA_USER \
    -e MYSQL_PASSWORD=$JOOMLA_PASS \
    -d mysql:8.0

# 3. Wait for Database to be ready
echo "--> Waiting 20 seconds for database to initialize..."
sleep 20

# 4. Start Joomla Container
echo "--> Starting Joomla container: $APP_CONTAINER_NAME..."
docker run --name $APP_CONTAINER_NAME \
    --network $NETWORK_NAME \
    -p 8080:80 \
    -v $APP_VOLUME_NAME:/var/www/html \
    -e JOOMLA_DB_HOST=$DB_CONTAINER_NAME \
    -e JOOMLA_DB_USER=$JOOMLA_USER \
    -e JOOMLA_DB_PASSWORD=$JOOMLA_PASS \
    -e JOOMLA_DB_NAME=$JOOMLA_DB \
    -d joomla:latest

# 5. Final Verification
echo "--> Verifying running containers..."
docker ps

echo "### Setup Complete! ###"
echo "Joomla should be available at http://localhost:8080 shortly."