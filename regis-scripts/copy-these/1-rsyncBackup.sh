mkdir -p /home/logging/backups
rsync -a -v /etc/ /home/logging/backups/etc/
rsync -a -v --exclude='logging/backups' /home/ /home/logging/backups/home/
rsync -a -v /var/ /home/logging/backups/var/