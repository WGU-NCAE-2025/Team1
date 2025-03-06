#!/bin/bash

################################################################################
# Script Name: Linux User Hardening
# Author: Damian J. Yates
# Institution: Western Governors University
# Degree: Master of Science, Cybersecurity and Information Assurance
# Description: This script performs user management and access control hardening
# on a Linux system, including disabling root SSH login, enforcing password policies,
# setting account restrictions, and enhancing security with fail2ban.
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

# Disable root login over SSH
backup_file /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd

echo "Root login disabled over SSH."

# Enforce password complexity
apt install -y libpam-pwquality 2>/dev/null || yum install -y libpam-pwquality
backup_file /etc/security/pwquality.conf
cat <<EOF > /etc/security/pwquality.conf
minlen = 12
dcredit = -1
ucredit = -1
ocredit = -1
lcredit = -1
EOF
echo "Password complexity rules applied."

# Set password expiration policies
backup_file /etc/login.defs
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 90/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 7/' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE 14/' /etc/login.defs
echo "Password expiration policies configured."

# Lock out failed SSH login attempts (fail2ban)
apt install -y fail2ban 2>/dev/null || yum install -y fail2ban
systemctl enable --now fail2ban
echo "Fail2ban installed and enabled."

# Remove or disable unnecessary user accounts
for user in lp sync shutdown halt news uucp operator games gopher; do
    userdel -r "$user" 2>/dev/null || echo "$user already removed."
done
echo "Unnecessary users removed."

# Restrict sudo access
backup_file /etc/sudoers
sed -i 's/^%wheel.*/# %wheel/' /etc/sudoers

echo "Sudo access restricted."

# Optional: Enforce MFA for SSH (commented out for manual setup)
# apt install -y libpam-google-authenticator
# echo "Google Authenticator installed. Configure manually with 'google-authenticator' command."

echo "User Management and Access Control Hardening Completed."
