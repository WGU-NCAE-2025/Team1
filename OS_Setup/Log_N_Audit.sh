#!/bin/bash

################################################################################
# Script Name: Linux Logging & Auditing Hardening
# Author: Damian J. Yates
# Institution: Western Governors University
# Degree: Master of Science, Cybersecurity and Information Assurance
# Description: This script sets up logging, auditing, and file integrity monitoring
# on a Linux system using auditd, AIDE, logrotate, and rsyslog. It also provides
# an option for SIEM integration via remote logging.
#
# Usage: Run this script as root to apply security configurations.
################################################################################

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Backup function
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        cp "$file" "${file}.bak-$(date +%F-%T)"
        echo "Backup created for $file"
    fi
}

# Install required packages
apt install -y auditd audispd-plugins aide logrotate rsyslog 2>/dev/null || yum install -y audit audit-libs aide logrotate rsyslog

echo "Logging and auditing packages installed."

# Configure auditd
backup_file /etc/audit/audit.rules
cat <<EOF > /etc/audit/rules.d/audit.rules
# Monitor file access and modification
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/sudoers -p wa -k identity

# Monitor system calls
-a always,exit -F arch=b64 -S execve -k execution
-a always,exit -F arch=b32 -S execve -k execution
EOF
systemctl restart auditd
echo "Auditd configured and restarted."

# Configure AIDE for file integrity monitoring
backup_file /etc/aide.conf
aide --init
mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
echo "AIDE initialized. Run 'aide --check' to verify file integrity."

# Configure logrotate for log management
backup_file /etc/logrotate.conf
cat <<EOF > /etc/logrotate.conf
/var/log/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 root utmp
    sharedscripts
    postrotate
        /usr/bin/systemctl reload rsyslog.service > /dev/null 2>/dev/null || true
    endscript
}
EOF
echo "Logrotate configured to prevent excessive log growth."

# Configure rsyslog for remote logging (SIEM integration)
echo "Would you like to configure remote logging for SIEM integration? (yes/no)"
read -r siem_choice
if [[ "$siem_choice" == "yes" ]]; then
    echo "Enter SIEM syslog server IP or hostname:"
    read -r siem_server
    backup_file /etc/rsyslog.conf
    echo "*.* @@$siem_server:514" >> /etc/rsyslog.conf
    systemctl restart rsyslog
    echo "Remote logging enabled to SIEM at $siem_server."
else
    echo "Skipping SIEM integration. You can configure it later in /etc/rsyslog.conf."
fi

echo "Logging and Auditing Hardening Completed."
