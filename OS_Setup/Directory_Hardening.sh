#!/bin/bash

################################################################################
# Script Name: Linux File and Directory Permissions Hardening
# Author: Damian J. Yates
# Institution: Western Governors University
# Degree: Master of Science, Cybersecurity and Information Assurance
# Description: This script enforces strict file and directory permissions
# on a Linux system, securing critical files and directories, restricting
# world-writable permissions, and disabling unused filesystems.
#
# Usage: Run this script as root to apply security configurations.
################################################################################

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Backup function (all modified files before making changes.)
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        cp "$file" "${file}.bak-$(date +%F-%T)"
        echo "Backup created for $file"
    fi
}

# Restrict home directory access to 750 (owner and group only).
for dir in /home/*; do
    if [[ -d "$dir" ]]; then
        chmod 750 "$dir"
        echo "Permissions set for $dir"
    fi
done

echo "Home directory permissions restricted."

# Secure critical system files
CRITICAL_FILES=(
    "/etc/passwd"
    "/etc/shadow"
    "/etc/group"
    "/etc/gshadow"
)

for file in "${CRITICAL_FILES[@]}"; do
    backup_file "$file"
    chmod 640 "$file"
    echo "Permissions set for $file"
done

echo "Critical system file permissions secured."

# Remove world-writable permissions from files and directories.
find / -type f -perm -002 -exec chmod o-w {} \;
find / -type d -perm -002 -exec chmod o-w {} \;
echo "World-writable files and directories secured."

# Set immutable flags on critical files to prevent unauthorized modifications.
for file in "${CRITICAL_FILES[@]}"; do
    chattr +i "$file"
    echo "Immutable flag set for $file"
done

echo "Immutable flags set on critical system files."

# Disable unused filesystems to reduce attack surfaces.
backup_file /etc/modprobe.d/disable-modules.conf
cat <<EOF > /etc/modprobe.d/disable-modules.conf
install cramfs /bin/true
install freevxfs /bin/true
install jffs2 /bin/true
install hfs /bin/true
install hfsplus /bin/true
install squashfs /bin/true
install udf /bin/true
EOF

echo "Unused filesystems disabled."

echo "File and Directory Permissions Hardening Completed."
