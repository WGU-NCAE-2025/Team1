#!/bin/bash

################################################################################
# Script Name: Linux Network Hardening
# Author: Damian J. Yates
# Institution: Western Governors University
# Degree: Master of Science, Cybersecurity and Information Assurance
# Description: This script applies network hardening measures, including
# disabling unnecessary services, securing the IP stack, configuring DHCP
# or static IP settings, setting up DNS servers, and configuring a firewall.
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

# Prompt user for IP configuration (DHCP or Static)
echo "Select network configuration:"
echo "1) DHCP"
echo "2) Static IP"
read -r net_choice

NIC=$(ip link show | awk -F': ' '/^[0-9]+: [a-z]/ {print $2}' | grep -v 'lo' | head -n 1)

if [[ $net_choice -eq 2 ]]; then
    echo "Enter Static IP Address (e.g., 192.168.1.100/24):"
    read -r static_ip
    echo "Enter Default Gateway (e.g., 192.168.1.1):"
    read -r gateway
    backup_file /etc/network/interfaces
    cat <<EOF > /etc/network/interfaces
# Static IP Configuration
auto $NIC
iface $NIC inet static
    address $static_ip
    gateway $gateway
EOF
    systemctl restart networking
    echo "Static IP configured."
else
    echo "Using DHCP for network configuration."
    backup_file /etc/network/interfaces
    cat <<EOF > /etc/network/interfaces
auto $NIC
iface $NIC inet dhcp
EOF
    systemctl restart networking
fi

# Configure DNS settings
echo "Enter Preferred DNS Server (e.g., 8.8.8.8):"
read -r dns1
echo "Enter Alternate DNS Server (e.g., 8.8.4.4 or leave blank):"
read -r dns2
backup_file /etc/resolv.conf
cat <<EOF > /etc/resolv.conf
nameserver $dns1
EOF
if [[ -n "$dns2" ]]; then
    echo "nameserver $dns2" >> /etc/resolv.conf
fi
echo "DNS settings applied."

# Apply network security settings
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
EOF
sysctl -p

echo "Network hardening settings applied."

# Disable unnecessary network services
SERVICES=("xinetd" "cups" "avahi-daemon" "nfs-kernel-server" "rpcbind")
for service in "${SERVICES[@]}"; do
    systemctl disable --now "$service" 2>/dev/null && echo "$service disabled." || echo "$service not found."
done
echo "Unnecessary network services disabled."

# Configure firewall
echo "Configuring firewall rules..."
apt install -y ufw 2>/dev/null || yum install -y firewalld

if command -v ufw &>/dev/null; then
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw enable
    echo "UFW firewall configured."
elif command -v firewall-cmd &>/dev/null; then
    systemctl enable --now firewalld
    firewall-cmd --permanent --set-default-zone=public
    firewall-cmd --permanent --add-service=ssh
    firewall-cmd --reload
    echo "Firewalld configured."
else
    echo "No recognized firewall tool found. Please configure manually." fi

echo "Network Hardening Completed."
