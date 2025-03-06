#!/bin/bash

################################################################################
# Script Name: Linux SSH Hardening
# Author: Damian J. Yates
# Institution: Western Governors University
# Degree: Master of Science, Cybersecurity and Information Assurance
# Description: This script hardens SSH security by disabling password authentication,
# enforcing key-based authentication, restricting root login, and securing the SSH key store.
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

# Generate SSH Key Pair for a User
generate_ssh_key() {
    local username="$1"
    local user_home="/home/$username"
    local ssh_dir="$user_home/.ssh"

    if id "$username" &>/dev/null; then
        if [[ ! -d "$ssh_dir" ]]; then
            mkdir -p "$ssh_dir"
            chown "$username":"$username" "$ssh_dir"
            chmod 700 "$ssh_dir"
            echo "SSH directory created for $username."
        fi
        
        ssh-keygen -t rsa -b 4096 -f "$ssh_dir/id_rsa" -N ""
        chown "$username":"$username" "$ssh_dir/id_rsa" "$ssh_dir/id_rsa.pub"
        chmod 600 "$ssh_dir/id_rsa"
        chmod 644 "$ssh_dir/id_rsa.pub"
        echo "SSH key pair generated for $username."
    else
        echo "User $username does not exist. Skipping SSH key generation."
    fi
}

# Disable password authentication and root login over SSH
backup_file /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

echo "SSH hardening applied. Password authentication disabled, root login restricted, and key-based authentication enforced."

# Secure SSH Key Store by setting proper permissions on .ssh directories and key files.
echo "Securing SSH key storage..."
find /home -type d -name ".ssh" -exec chmod 700 {} \;
find /home -type f -name "authorized_keys" -exec chmod 600 {} \;
find /home -type f -name "id_rsa" -exec chmod 600 {} \;
find /home -type f -name "id_rsa.pub" -exec chmod 644 {} \;
echo "SSH key store secured."

# Prompt user to generate SSH key for specific user
echo "Enter the username to generate an SSH key pair for (or press Enter to skip):"
read -r ssh_user
if [[ -n "$ssh_user" ]]; then
    generate_ssh_key "$ssh_user"
fi

echo "SSH Hardening Completed."
