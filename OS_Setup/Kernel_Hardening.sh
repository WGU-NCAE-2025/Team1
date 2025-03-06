#!/bin/bash

################################################################################
# Script Name: Linux Kernel Security Hardening
# Author: Damian J. Yates
# Institution: Western Governors University
# Degree: Master of Science, Cybersecurity and Information Assurance
# Description: This script applies kernel security enhancements to mitigate threats,
# enforce memory protections, and restrict unsafe system calls.
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

# Prompt for kernel security enhancements
echo "Would you like to enable kernel security enhancements? (yes/no)"
read -r kernel_choice
if [[ "$kernel_choice" != "yes" ]]; then
    echo "Skipping kernel security enhancements."
    exit 0
fi

# Apply kernel security settings
backup_file /etc/sysctl.conf
cat <<EOF >> /etc/sysctl.conf
# Enable address space layout randomization (ASLR)
kernel.randomize_va_space = 2

# Disable core dumps to prevent data leakage
fs.suid_dumpable = 0

# Restrict loading of kernel modules
kernel.modules_disabled = 1

# Restrict access to kernel logs
kernel.dmesg_restrict = 1
EOF
sysctl -p
echo "Kernel security settings applied."

# Restrict unprivileged user namespaces (mitigates privilege escalation)
echo "Would you like to disable unprivileged user namespaces? (yes/no)"
read -r userns_choice
if [[ "$userns_choice" == "yes" ]]; then
    backup_file /etc/sysctl.d/99-disable-userns.conf
    echo "kernel.unprivileged_userns_clone = 0" > /etc/sysctl.d/99-disable-userns.conf
    sysctl --system
    echo "Unprivileged user namespaces disabled."
else
    echo "Skipping user namespace restriction."
fi

# Restrict ptrace to prevent process snooping
echo "Would you like to restrict ptrace debugging? (yes/no)"
read -r ptrace_choice
if [[ "$ptrace_choice" == "yes" ]]; then
    backup_file /etc/sysctl.d/10-ptrace.conf
    echo "kernel.yama.ptrace_scope = 2" > /etc/sysctl.d/10-ptrace.conf
    sysctl --system
    echo "Ptrace debugging restrictions applied."
else
    echo "Skipping ptrace restriction."
fi

echo "Kernel Security Enhancements Completed."
