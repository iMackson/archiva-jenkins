#!/bin/bash
# Production backup script for Jenkins and Archiva
# Run this script periodically (e.g., via cron) to backup critical data

set -e

BACKUP_DIR="/opt/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="jenkins_archiva_backup_$TIMESTAMP"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "Starting backup: $BACKUP_NAME"

# Stop services temporarily for consistent backup (optional, but safer)
# docker-compose stop jenkins archiva

# Create backup archive
cd /opt/docker/jenkins-archiva  # Adjust path to your compose file location

tar -czf "$BACKUP_DIR/$BACKUP_NAME.tar.gz" \
    --exclude='*.log' \
    --exclude='*.tmp' \
    --exclude='workspaces/*/workspace' \
    -C /var/lib/docker/volumes/ \
    $(docker volume ls -q | grep -E "(jenkins_home|archiva_data|archiva_conf)")

# Restart services if they were stopped
# docker-compose start jenkins archiva

# Cleanup old backups (keep last 7 days)
find "$BACKUP_DIR" -name "jenkins_archiva_backup_*.tar.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR/$BACKUP_NAME.tar.gz"
echo "Backup size: $(du -h "$BACKUP_DIR/$BACKUP_NAME.tar.gz" | cut -f1)"

# Optional: Copy to remote storage (uncomment and configure)
# scp "$BACKUP_DIR/$BACKUP_NAME.tar.gz" user@backup-server:/remote/path/

# Optional: Send notification
# echo "Backup completed successfully" | mail -s "Jenkins/Archiva Backup" admin@yourdomain.com