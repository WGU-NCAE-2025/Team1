#!/bin/bash

################################################################################
# Script Name: Linux Application and Service Hardening
# Author: Damian J. Yates
# Institution: Western Governors University
# Degree: Master of Science, Cybersecurity and Information Assurance
# Description: This script secures applications and services by disabling unnecessary
# services, enforcing least privilege access, enabling AppArmor/SELinux, enforcing TLS,
# and ensuring automated patching for security updates.
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

# List active services
echo "Listing active services:"
systemctl list-units --type=service --state=running

echo "Disabling unnecessary services..."
UNNEEDED_SERVICES=("xinetd" "telnet" "ftp" "nfs-server" "rpcbind" "avahi-daemon" "cups")
for service in "${UNNEEDED_SERVICES[@]}"; do
    systemctl disable --now "$service" 2>/dev/null && echo "$service disabled." || echo "$service not found."
done

echo "Unnecessary services disabled."

# Enforce AppArmor or SELinux policies
if command -v apparmor_status &>/dev/null; then
    echo "Enforcing AppArmor policies..."
    systemctl enable --now apparmor
    echo "AppArmor enabled."
elif command -v sestatus &>/dev/null; then
    echo "Enforcing SELinux policies..."
    setenforce 1
    echo "SELinux enforcing mode enabled."\else
    echo "No application sandboxing system found. Consider enabling AppArmor or SELinux manually."i

# Secure web and database services
if systemctl is-active --quiet apache2; then
    echo "Hardening Apache..."
    backup_file /etc/apache2/apache2.conf
    sed -i 's/^ServerTokens.*/ServerTokens Prod/' /etc/apache2/apache2.conf
    sed -i 's/^ServerSignature.*/ServerSignature Off/' /etc/apache2/apache2.conf
    systemctl restart apache2
    echo "Apache hardened."i

if systemctl is-active --quiet nginx; then
    echo "Hardening Nginx..."
    backup_file /etc/nginx/nginx.conf
    sed -i 's/^server_tokens.*/server_tokens off;/' /etc/nginx/nginx.conf
    systemctl restart nginx
    echo "Nginx hardened."i

if systemctl is-active --quiet mysql; then
    echo "Hardening MySQL..."
    mysql_secure_installation
    echo "MySQL hardened."i

# Enforce TLS configurations
echo "Enforcing TLS settings for secure communications..."
backup_file /etc/ssl/openssl.cnf
cat <<EOF > /etc/ssl/openssl.cnf
[openssl_init]
ssl_conf = ssl_sect
[ssl_sect]
system_default = ssl_default_sect
[ssl_default_sect]
MinProtocol = TLSv1.2
CipherString = DEFAULT:@SECLEVEL=2
EOF
echo "TLS enforcement applied."

# Automate security updates
echo "Enabling automatic security updates..."
if command -v apt &>/dev/null; then
    apt install -y unattended-upgrades
    dpkg-reconfigure -plow unattended-upgrades
elif command -v yum &>/dev/null; then
    yum install -y dnf-automatic
    systemctl enable --now dnf-automatic.timer
fi
echo "Automatic security updates enabled."

echo "Application and Service Hardening Completed."
