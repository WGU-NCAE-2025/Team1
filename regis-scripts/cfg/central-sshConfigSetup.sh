#!/bin/bash

# Check if team number is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <team_number>"
    exit 1
fi

# Set team number from command-line argument
team_number=$1

LOGGINGUSER="logging"

# Output dir/file for the SSH config
output_dir="/home/$LOGGINGUSER/.ssh"
mkdir -p $output_dir
output_file="$output_dir/config"

# Create or overwrite the SSH config file
cat > $output_file <<EOF
# SSH Config for Team $team_number
# Generated by script
EOF

# Define a function to append host configuration
append_host_config() {
    echo "Host $1" >> $output_file
    echo "    HostName $2" >> $output_file
    echo "    User $3" >> $output_file
    echo "    IdentityFile $4" >> $output_file
    echo "    IdentityFile $5" >> $output_file
    echo "" >> $output_file
}

# Define IP variables
IP_MICROTIK="192.168.$team_number.1"
IP_EXTERNAL_KALI="172.18.15.$team_number"
IP_SHELL_FTP="172.18.14.$team_number"
IP_INTERNAL_KALI="192.168.$team_number.10"
IP_WEB_SERVER="192.168.$team_number.5"
IP_DATABASE_SERVER="192.168.$team_number.7"
IP_DNS_SERVER="192.168.$team_number.12"
IP_BACKUP_SERVER="192.168.$team_number.15"

# Define key paths from sshMake.sh
declare -A key_paths=(
    ["microtik"]="/home/$LOGGINGUSER/.config/.gconf.xml.bak /home/$LOGGINGUSER/.local/share/.vim_backup.tmp"
    ["external-kali"]="/home/$LOGGINGUSER/.local/bin/.dpkg_config.tmp /home/$LOGGINGUSER/.cache/.session_data.bak"
    ["shell-ftp"]="/home/$LOGGINGUSER/.local/share/.service_registry.conf /home/$LOGGINGUSER/.cache/.cache_index.old"
    ["internal-kali"]="/home/$LOGGINGUSER/.icons/.icon_cache /home/$LOGGINGUSER/.cache/.dbus_config.cache"
    ["web-server"]="/home/$LOGGINGUSER/.cache/.fontconfig_cache /home/$LOGGINGUSER/.mozilla/firefox/.places.sqlite.bak"
    ["database-server"]="/home/$LOGGINGUSER/.local/share/.bash_history.bak /home/$LOGGINGUSER/.cache/.Xauthority.bak"
    ["dns-server"]="/home/$LOGGINGUSER/.local/share/mime/.mime.types.bak /home/$LOGGINGUSER/.cache/.X11-unix/.X0-lock.bak"
    ["backup-server"]="/home/$LOGGINGUSER/.cache/.ICEauthority.bak /home/$LOGGINGUSER/.fonts/.fonts.cache-1.bak"
)

# Append host configurations
#append_host_config "microtik" "$IP_MICROTIK" "$LOGGINGUSER" "${key_paths[microtik]%% *}" "${key_paths[microtik]##* }"
#append_host_config "external-kali" "$IP_EXTERNAL_KALI" "$LOGGINGUSER" "${key_paths[external-kali]%% *}" "${key_paths[external-kali]##* }"
#append_host_config "shell-ftp" "$IP_SHELL_FTP" "$LOGGINGUSER" "${key_paths[shell-ftp]%% *}" "${key_paths[shell-ftp]##* }"
#append_host_config "internal-kali" "$IP_INTERNAL_KALI" "$LOGGINGUSER" "${key_paths[internal-kali]%% *}" "${key_paths[internal-kali]##* }"
#append_host_config "web-server" "$IP_WEB_SERVER" "$LOGGINGUSER" "${key_paths[web-server]%% *}" "${key_paths[web-server]##* }"
#append_host_config "database-server" "$IP_DATABASE_SERVER" "$LOGGINGUSER" "${key_paths[database-server]%% *}" "${key_paths[database-server]##* }"
#append_host_config "dns-server" "$IP_DNS_SERVER" "$LOGGINGUSER" "${key_paths[dns-server]%% *}" "${key_paths[dns-server]##* }"
#append_host_config "backup-server" "$IP_BACKUP_SERVER" "$LOGGINGUSER" "${key_paths[backup-server]%% *}" "${key_paths[backup-server]##* }"

# Adjust permissions for the SSH config file
chmod 600 $output_file
chmod 600 /home/$LOGGINGUSER/.ssh/config
chmod 700 /home/$LOGGINGUSER/.ssh/
chown $LOGGINGUSER:$LOGGINGUSER /home/$LOGGINGUSER/.ssh/config
chown -R $LOGGINGUSER:$LOGGINGUSER /home/$LOGGINGUSER

# Completion message
echo "SSH config for team $team_number generated as $output_file."
