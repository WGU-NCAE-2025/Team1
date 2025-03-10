#!/bin/bash

####
# This is for hosts NOT aggregating logs.
# It configures rsyslog to send ALL logs
# to an aggregating server ($AGG_SRV)
# - reg1z
####

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Target IP for log aggregating
AGG_SRV="192.168.56.2"

# rsyslog configuration directory/files
#   - NOTE: the main config is "/etc/rsyslog.conf".
#           this config will just be tacked onto the
#           main config, whatever it's set to.
CONF_DIR="/etc/rsyslog.d"
CONF_FILE="$CONF_DIR/logSend.conf"

# Create the config directory + file if not already existing
mkdir -p $CONF_DIR
touch $CONF_FILE

# Fill the file with the config lines
cat << EOF > $CONF_FILE
*.* @@$AGG_SRV:514 # Forward ALL logs via TCP
EOF

# Restart rsyslog
systemctl restart rsyslog

if [ $? -eq 0 ]; then
  echo "Log forwarding is now enabled to $AGG_SRV on port 514 using TCP."
else
  echo "Failed to restart rsyslog. Check the configuration."
fi
