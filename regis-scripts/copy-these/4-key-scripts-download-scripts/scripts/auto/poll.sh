#!/bin/bash
set -euo pipefail

# Check that exactly three arguments are provided: team number, endpoint IP, and SSH key path.
if [ "$#" -ne 3 ]; then
    echo "Error: Team number, endpoint IP, and SSH key path must be provided."
    echo "Usage: $0 <TEAM_NUMBER> <ENDPOINT_IP> <SSH_KEY_PATH>"
    exit 1
fi

# Assign the input parameters to variables.
TEAM="$1"
IP="$2"
SSH_KEY="$3"

# Define IP variables (same as in sshConfigSetup.sh)
IP_MICROTIK="192.168.${TEAM}.1"
IP_EXTERNAL_KALI_1="172.18.15.161"
IP_EXTERNAL_KALI_2="172.18.15.162"
IP_EXTERNAL_KALI_3="172.18.15.163"
IP_EXTERNAL_KALI_4="172.18.15.164"
IP_EXTERNAL_KALI_5="172.18.15.165"
IP_EXTERNAL_KALI_6="172.18.15.166"
IP_SHELL_FTP="172.18.14.${TEAM}"
IP_INTERNAL_KALI_1="192.168.16.41"
IP_INTERNAL_KALI_2="192.168.16.42"
IP_INTERNAL_KALI_3="192.168.16.43"
IP_INTERNAL_KALI_4="192.168.16.44"
IP_INTERNAL_KALI_5="192.168.16.45"
IP_INTERNAL_KALI_6="192.168.16.46"
IP_WEB_SERVER="192.168.${TEAM}.5"
IP_DATABASE_SERVER="192.168.${TEAM}.7"
IP_DNS_SERVER="192.168.${TEAM}.12"
IP_BACKUP_SERVER="192.168.${TEAM}.15"

# Determine the host alias based on the provided IP
if [ "$IP" == "$IP_MICROTIK" ]; then
    HOST="microtik"
elif [ "$IP" == "$IP_EXTERNAL_KALI_1" ]; then
    HOST="external-kali-1"
elif [ "$IP" == "$IP_EXTERNAL_KALI_2" ]; then
    HOST="external-kali-2"
elif [ "$IP" == "$IP_EXTERNAL_KALI_3" ]; then
    HOST="external-kali-3"
elif [ "$IP" == "$IP_EXTERNAL_KALI_4" ]; then
    HOST="external-kali-4"
elif [ "$IP" == "$IP_EXTERNAL_KALI_5" ]; then
    HOST="external-kali-5"
elif [ "$IP" == "$IP_EXTERNAL_KALI_6" ]; then
    HOST="external-kali-6"
elif [ "$IP" == "$IP_SHELL_FTP" ]; then
    HOST="shell-ftp"
elif [ "$IP" == "$IP_INTERNAL_KALI_1" ]; then
    HOST="internal-kali-1"
elif [ "$IP" == "$IP_INTERNAL_KALI_2" ]; then
    HOST="internal-kali-2"
elif [ "$IP" == "$IP_INTERNAL_KALI_3" ]; then
    HOST="internal-kali-3"
elif [ "$IP" == "$IP_INTERNAL_KALI_4" ]; then
    HOST="internal-kali-4"
elif [ "$IP" == "$IP_INTERNAL_KALI_5" ]; then
    HOST="internal-kali-5"
elif [ "$IP" == "$IP_INTERNAL_KALI_6" ]; then
    HOST="internal-kali-6"
elif [ "$IP" == "$IP_WEB_SERVER" ]; then
    HOST="web-server"
elif [ "$IP" == "$IP_DATABASE_SERVER" ]; then
    HOST="database-server"
elif [ "$IP" == "$IP_DNS_SERVER" ]; then
    HOST="dns-server"
elif [ "$IP" == "$IP_BACKUP_SERVER" ]; then
    HOST="backup-server"
else
    # Default host alias if IP does not match any predefined IPs
    HOST="host-${IP}"
fi

# Remote log directory (must match the endpoint configuration)
REMOTE_LOG_DIR="/var/log/aggregated"

# Local base directory on the central logging server where logs will be stored
LOCAL_BASE="/var/log/aggregated"
LOCAL_DIR="${LOCAL_BASE}/${HOST}"
LOCAL_BACKUP_BASE="/home/logging/backups"
LOCAL_BACKUP_DIR="${LOCAL_BACKUP_BASE}/${HOST}"

#LOCAL_DIR="${LOCAL_BASE}"

echo "Polling logs from endpoint ${HOST} at IP ${IP} for team ${TEAM}..."

# Create the local directory if it doesn't exist.
mkdir -p "${LOCAL_BASE}"
mkdir -p "${LOCAL_DIR}"
mkdir -p "${LOCAL_BACKUP_BASE}"
mkdir -p "${LOCAL_BACKUP_DIR}"

if [ "$IP" == "$IP_MICROTIK" ]; then
    echo -e "\n\nIt's a microtik! Do something else!\n\n"
    sftp -i "$SSH_KEY" -o ConnectTimeout=5 admin@"${IP}" <<EOF
    lcd ${LOCAL_DIR}
    cd /file
    get *.txt
    lcd ${LOCAL_BACKUP_DIR}
    get *.backup
    bye
EOF
else
    # Use SFTP in batch mode to download all files from the remote log directory.
    sftp -i "$SSH_KEY" -o ConnectTimeout=5 logging@"${IP}" <<EOF
    lcd ${LOCAL_DIR}
    cd ${REMOTE_LOG_DIR}
    get *
    lcd ${LOCAL_BACKUP_DIR}
    cd /home/logging/backups
    get *.tar.gz
    bye
EOF
    SFTP_EXIT_CODE=$?

    if [ ${SFTP_EXIT_CODE} -eq 0 ]; then
            echo "Successfully polled logs from ${HOST} (${IP})."
    else
            echo "Error polling logs from ${HOST} (${IP}). SFTP exit code: ${SFTP_EXIT_CODE}"
    fi

fi

echo "Log polling complete."
