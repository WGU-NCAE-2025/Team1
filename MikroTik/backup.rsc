# ===================================================
# Script Name: backup.rsc
# Description: Create Encrypted Backup of MikroTik Configuration
# Author: Paul DuHamel Jr - Team 1
# Created: 3/12/2025
# Last Modified: 3/12/2025
# Version: 1.0
# ===================================================

## Create Backup

## command to create an encrypted backup stored locally on the machine. name format should be ([identity]-[date]-[time].backup) IE: test-030925-1700.backup

system backup save name= password= encryption=aes-sha256

## loading a backup from local storage

system backup load name=

## Send Backup to another device (check each entry for appropriate infromation)
tool fetch address=[destination ip] src-path=backup-file-name.backup user=backup-server-username mode=sftp password=backup-server-users-password dst-path=location-to-store-backup-file upload=yes
