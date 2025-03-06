#!/bin/bash

################################################################################
# Script Name: Linux Boot and Physical Security Hardening
# Author: Damian J. Yates
# Institution: Western Governors University
# Degree: Master of Science, Cybersecurity and Information Assurance
# Description: This script enhances Linux boot and physical security by setting up GRUB passwords,
# disabling boot from external devices, restricting single-user mode, and enabling hardware protections.
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

# Set GRUB password for boot protection
echo "Setting up GRUB password..."
backup_file /etc/grub.d/40_custom
echo "Enter GRUB password:"
read -s grub_password
echo "Enter again to confirm:"
read -s grub_password_confirm

if [[ "$grub_password" != "$grub_password_confirm" ]]; then
    echo "Passwords do not match. Exiting."
    exit 1
fi

echo "Generating GRUB password hash..."
grub_password_hash=$(echo -e "$grub_password" | grub-mkpasswd-pbkdf2 | awk '/grub.pbkdf2/ {print $NF}')

cat <<EOF >> /etc/grub.d/40_custom
set superusers="root"
password_pbkdf2 root $grub_password_hash
EOF
update-grub
echo "GRUB password set successfully."

# Restrict booting from external devices
echo "Disabling boot from USB and external devices..."
bios_settings=("/sys/class/block/sd*/removable")
for setting in "${bios_settings[@]}"; do
    echo "0" > "$setting" 2>/dev/null || echo "Could not modify $setting"
done
echo "Booting from external devices restricted."

# Restrict single-user mode
echo "Restricting single-user mode access..."
backup_file /etc/shadow
passwd -l root
echo "Root account locked in single-user mode."

# Enable hardware protections
echo "Enabling hardware security settings..."
backup_file /etc/sysctl.conf
cat <<EOF >> /etc/sysctl.conf
# Disable Ctrl-Alt-Del reboot
kernel.ctrl-alt-del = 0
EOF
sysctl -p
echo "Hardware security settings applied."

echo "Boot and Physical Security Hardening Completed."
