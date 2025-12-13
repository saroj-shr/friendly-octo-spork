#!/bin/bash

# WordPress Backup Restore Script
# This script helps restore large WordPress backups directly to the server

echo "WordPress Large Backup Restore Helper"
echo "======================================"
echo ""

# Check if backup file is provided
if [ -z "$1" ]; then
    echo "Usage: ./restore-backup.sh <backup-file.zip|backup-file.tar.gz>"
    echo ""
    echo "Options:"
    echo "  1. Copy your backup file to this directory"
    echo "  2. Run: ./restore-backup.sh your-backup-file.zip"
    echo ""
    echo "Alternative methods:"
    echo "  - Use FTP/SFTP to upload directly to the server"
    echo "  - Use cloud storage (Dropbox, Google Drive) and import from there"
    echo "  - Split the backup into smaller chunks"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file '$BACKUP_FILE' not found!"
    exit 1
fi

echo "Found backup file: $BACKUP_FILE"
echo "File size: $(du -h "$BACKUP_FILE" | cut -f1)"
echo ""

# Detect backup type
if [[ $BACKUP_FILE == *.zip ]]; then
    echo "Detected ZIP backup"
    EXTRACT_CMD="unzip -q"
elif [[ $BACKUP_FILE == *.tar.gz ]] || [[ $BACKUP_FILE == *.tgz ]]; then
    echo "Detected TAR.GZ backup"
    EXTRACT_CMD="tar -xzf"
else
    echo "Error: Unsupported backup format. Please use .zip or .tar.gz"
    exit 1
fi

echo ""
read -p "This will restore the backup. Continue? (y/N): " confirm

if [[ $confirm != [yY] ]]; then
    echo "Cancelled."
    exit 0
fi

# Create temporary extraction directory
TEMP_DIR="./backup_extract_$(date +%s)"
mkdir -p "$TEMP_DIR"

echo ""
echo "Extracting backup to $TEMP_DIR..."
$EXTRACT_CMD "$BACKUP_FILE" -d "$TEMP_DIR"

echo ""
echo "Backup extracted successfully!"
echo ""
echo "Next steps:"
echo "1. Stop WordPress container: docker compose stop wordpress"
echo "2. The extracted files are in: $TEMP_DIR"
echo "3. Copy WordPress files to volume: docker cp $TEMP_DIR/wordpress/. wordpress_site:/var/www/html/"
echo "4. Import database (if included)"
echo "5. Start WordPress: docker compose start wordpress"
echo ""
echo "Would you like this script to do this automatically? (y/N): "
read auto_restore

if [[ $auto_restore == [yY] ]]; then
    echo "Stopping WordPress..."
    docker compose stop wordpress
    
    echo "Copying files to WordPress container..."
    # Adjust path based on your backup structure
    if [ -d "$TEMP_DIR/wordpress" ]; then
        docker cp "$TEMP_DIR/wordpress/." wordpress_site:/var/www/html/
    else
        docker cp "$TEMP_DIR/." wordpress_site:/var/www/html/
    fi
    
    echo "Starting WordPress..."
    docker compose start wordpress
    
    echo ""
    echo "Restore complete! Check your site."
    echo "Don't forget to import the database if needed."
fi

echo ""
echo "Cleanup: rm -rf $TEMP_DIR"
