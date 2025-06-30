# Joomla Docker Automation Project

## 1. Project Members
* Elay Barlev, Shani, Elin

## 2. Project Goal
This project's goal was to deploy a complete Joomla website environment using Docker containers for the application and a MySQL database. The entire lifecycle of the environment—setup, backup, restore, and cleanup—is automated via Bash shell scripts.

## 3. Implementation Details
The environment consists of two Docker containers: one for Joomla (`joomla:latest`) and one for its database (`mysql:8.0`). These are connected via a custom Docker bridge network.

Four scripts automate all operations:
* `setup.sh`: Builds and starts the entire environment from scratch.
* `backup.sh`: Creates timestamped, compressed backups of the database and the Joomla filesystem volume.
* `restore.sh`: Destroys the current environment and restores the site from the most recent backup files.
* `cleanup.sh`: Stops and deletes all containers, images, volumes, and networks associated with the project.

## 4. Technologies Used
* Linux
* Docker Engine
* Joomla
* MySQL 8.0
* Bash Scripting

## 5. Step-by-Step User Guide

### Prerequisites
* A Linux system with Docker and Git installed.
* To test the restore, you must have the backup files (`.sql.gz` and `.tar.gz`) in the same directory as the scripts.

### To Set Up the Environment from Scratch:
1.  Clone this repository: `git clone https://github.com/elinfelikman/SEE3`
2.  Navigate into the project directory: `cd SEE3`
3.  Make all scripts executable: `chmod +x *.sh`
4.  Run the setup script with sudo: `sudo ./setup.sh`
5.  The site will be available at `http://localhost:8080`.

### To Restore From a Backup:
1.  Place the `joomla-database-backup-....sql.gz` and `joomla-files-backup-....tar.gz` files in the project directory.
2.  Run the restore script with sudo: `sudo ./restore.sh`

### To Clean Up the Entire Environment:
1.  Run the cleanup script with sudo: `sudo ./cleanup.sh`