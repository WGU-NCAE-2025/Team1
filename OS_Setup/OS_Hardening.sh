#!/bin/bash

################################################################################
# Script Name: Linux System Configuration Hardening
# Author: Damian J. Yates
# Institution: Western Governors University
# Degree: Master of Science, Cybersecurity and Information Assurance
# Description: This script applies system configuration hardening to improve security
# by setting kernel parameters, limiting process capabilities, preventing core dumps,
# and enabling security-focused settings.
#
# Usage: Run this script as root to apply security configurations.
################################################################################

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Backup function before making changes.
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        cp "$file" "${file}.bak-$(date +%F-%T)"
        echo "Backup created for $file"
    fi
}

# Apply kernel security settings
backup_file /etc/sysctl.conf
cat <<EOF > /etc/sysctl.conf
# Disable IP forwarding
net.ipv4.ip_forward = 0

# Disable ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0

# Enable Reverse Path Filtering
net.ipv4.conf.all.rp_filter = 1

# Prevent SYN flood attacks
net.ipv4.tcp_syncookies = 1

# Enable Address Space Layout Randomization (ASLR)
kernel.randomize_va_space = 2
EOF
sysctl -p

echo "Kernel security settings applied."

# Prevent core dumps to avoid information leaks.
backup_file /etc/security/limits.conf
echo '* hard core 0' >> /etc/security/limits.conf
echo "Core dumps disabled."

# Limit process capabilities to enhance security.
backup_file /etc/systemd/system.conf
backup_file /etc/systemd/user.conf
sed -i 's/^#DefaultLimitNOFILE=/DefaultLimitNOFILE=65535/' /etc/systemd/system.conf
sed -i 's/^#DefaultLimitNPROC=/DefaultLimitNPROC=65535/' /etc/systemd/system.conf
sed -i 's/^#DefaultLimitCORE=/DefaultLimitCORE=0/' /etc/systemd/system.conf
sed -i 's/^#DefaultLimitNOFILE=/DefaultLimitNOFILE=65535/' /etc/systemd/user.conf
sed -i 's/^#DefaultLimitNPROC=/DefaultLimitNPROC=65535/' /etc/systemd/user.conf
sed -i 's/^#DefaultLimitCORE=/DefaultLimitCORE=0/' /etc/systemd/user.conf
systemctl daemon-reexec
echo "Process limits configured."

# Disable Ctrl-Alt-Del reboot to prevent unauthorized reboots.
backup_file /etc/systemd/system/ctrl-alt-del.target
systemctl mask ctrl-alt-del.target
echo "Ctrl-Alt-Del reboot disabled."

echo "System Configuration Hardening Completed."
