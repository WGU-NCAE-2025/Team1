#!/bin/bash
mkdir -p /home/logging/backups

rsync -a -v /etc/ /home/logging/backups/etc/
cd /home/logging/backups
tar -czvf etc.tar.gz etc/

rsync -a -v --exclude='logging/backups' /home/ /home/logging/backups/home/
cd /home/logging/backups
tar -czvf home.tar.gz home/

rsync -a -v /var/ /home/logging/backups/var/
cd /home/logging/backups
tar -czvf var.tar.gz var/