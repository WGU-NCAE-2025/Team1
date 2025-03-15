#!/bin/bash
# Ensure the script is run using sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run with sudo."
    exit 1
fi

# Check if IP address is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <YOUR CURRENT HOST'S IP_ADDRESS. YOUR IP. SERIOUSLY - YOUR IP, NOT ANY OTHER IP>"
    exit 1
fi

# Set IP address from command-line argument
IP_ADDRESS=$1

# Prompt for the Central Logging Server IP address
read -p "Enter the Central Logging Server IP: " LOGGING_SERVER_IP

# Create directory for public keys if needed
mkdir -p /home/logging/.ssh/pub_keys
chown logging:logging /home/logging/.ssh/pub_keys
chmod 700 /home/logging/.ssh/pub_keys

# Define IP variables
IP_INTERNAL_KALI_1="192.168.16.41"
IP_INTERNAL_KALI_2="192.168.16.42"
IP_INTERNAL_KALI_3="192.168.16.43"
IP_INTERNAL_KALI_4="192.168.16.44"
IP_INTERNAL_KALI_5="192.168.16.45"
IP_INTERNAL_KALI_6="192.168.16.46"

# Determine the key file based on the provided IP
if [ "$IP_ADDRESS" == "$IP_INTERNAL_KALI_1" ]; then
    KEY_FILE_1="key_internal-kali-1_1.pub"
    KEY_FILE_2="key_internal-kali-1_2.pub"
elif [ "$IP_ADDRESS" == "$IP_INTERNAL_KALI_2" ]; then
    KEY_FILE_1="key_internal-kali-2_1.pub"
    KEY_FILE_2="key_internal-kali-2_2.pub"
elif [ "$IP_ADDRESS" == "$IP_INTERNAL_KALI_3" ]; then
    KEY_FILE_1="key_internal-kali-3_1.pub"
    KEY_FILE_2="key_internal-kali-3_2.pub"
elif [ "$IP_ADDRESS" == "$IP_INTERNAL_KALI_4" ]; then
    KEY_FILE_1="key_internal-kali-4_1.pub"
    KEY_FILE_2="key_internal-kali-4_2.pub"
elif [ "$IP_ADDRESS" == "$IP_INTERNAL_KALI_5" ]; then
    KEY_FILE_1="key_internal-kali-5_1.pub"
    KEY_FILE_2="key_internal-kali-5_2.pub"
elif [ "$IP_ADDRESS" == "$IP_INTERNAL_KALI_6" ]; then
    KEY_FILE_1="key_internal-kali-6_1.pub"
    KEY_FILE_2="key_internal-kali-6_2.pub"
else
    echo "Error: IP address does not match any known internal-kali IPs."
    exit 1
fi

# Download the public key files for the specified internal-kali
curl http://$LOGGING_SERVER_IP:8000/$KEY_FILE_1 -o /home/logging/.ssh/pub_keys/$KEY_FILE_1
curl http://$LOGGING_SERVER_IP:8000/$KEY_FILE_2 -o /home/logging/.ssh/pub_keys/$KEY_FILE_2
curl http://$LOGGING_SERVER_IP:8000/scripts.tar.gz -o /home/logging/scripts.tar.gz
chown logging:logging /home/logging/.ssh/pub_keys/$KEY_FILE_1 /home/logging/.ssh/pub_keys/$KEY_FILE_2
chmod 600 /home/logging/.ssh/pub_keys/$KEY_FILE_1 /home/logging/.ssh/pub_keys/$KEY_FILE_2

echo "Downloaded public keys for internal-kali."


extract_to_folder() {
    local file="$1"
    local folder=$(basename "$file" .tar.gz)
    
    if [ ! -f "$file" ]; then
        echo "Error: File $file not found"
        return 1
    fi
    
    mkdir -p "$folder"
    tar -xzf "$file" -C "$folder"
    echo "Extracted $file to $folder/"
}

echo "Extracting scripts.tar.gz..."
extract_to_folder /home/logging/scripts.tar.gz


rm -f /home/logging/.ssh/authorized_keys

# Ensure authorized_keys exists and update it with downloaded keys
mkdir -p /home/logging/.ssh
touch /home/logging/.ssh/authorized_keys
chown logging:logging /home/logging/.ssh /home/logging/.ssh/authorized_keys
chmod 700 /home/logging/.ssh
chmod 600 /home/logging/.ssh/authorized_keys

for key in /home/logging/.ssh/pub_keys/*.pub; do
    if ! grep -q -F -x -f "$key" /home/logging/.ssh/authorized_keys; then
         cat "$key" >> /home/logging/.ssh/authorized_keys
    fi
done

echo "Updated /home/logging/.ssh/authorized_keys with downloaded keys."

# Restart SSH service
echo "Restarting sshd service..."
if command -v systemctl >/dev/null; then
    systemctl restart sshd && echo "sshd restarted successfully."
else
    service ssh restart && echo "sshd restarted successfully."
fi
