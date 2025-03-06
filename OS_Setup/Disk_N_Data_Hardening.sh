#!/bin/bash

################################################################################
# Script Name: Linux Disk and Data Protection Hardening
# Author: Damian J. Yates
# Institution: Western Governors University
# Degree: Master of Science, Cybersecurity and Information Assurance
# Description: This script enhances disk and data protection by encrypting disks,
# enabling swap encryption, and securely wiping sensitive data.
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

# Prompt for disk encryption
echo "Would you like to enable full disk encryption with LUKS? (yes/no)"
read -r luks_choice
if [[ "$luks_choice" == "yes" ]]; then
    echo "Enter the disk to encrypt (e.g., /dev/sdb):"
    read -r luks_disk
    if [[ -b "$luks_disk" ]]; then
        echo "Encrypting $luks_disk with LUKS..."
        cryptsetup luksFormat "$luks_disk"
        echo "LUKS encryption configured for $luks_disk. Use cryptsetup open to unlock."
    else
        echo "Invalid disk selected. Skipping encryption."
    fi
else
    echo "Skipping disk encryption."
fi

# Prompt for swap encryption
echo "Would you like to enable swap encryption? (yes/no)"
read -r swap_choice
if [[ "$swap_choice" == "yes" ]]; then
    backup_file /etc/fstab
    swapoff -a
    dd if=/dev/urandom of=/swapfile bs=1M count=1024
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo "/swapfile none swap sw 0 0" >> /etc/fstab
    echo "Swap encryption enabled."
else
    echo "Skipping swap encryption."
fi

# Prompt for secure file deletion
echo "Would you like to install secure file deletion tools (shred, wipe)? (yes/no)"
read -r secure_del_choice
if [[ "$secure_del_choice" == "yes" ]]; then
    apt install -y secure-delete 2>/dev/null || yum install -y secure-delete
    echo "Secure delete tools installed. Use 'srm' and 'shred' to securely remove files."
else
    echo "Skipping secure file deletion tools."
fi

echo "Disk and Data Protection Hardening Completed."
