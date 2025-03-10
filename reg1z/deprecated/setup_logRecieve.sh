
#!/bin/bash

####
# This is for the log-aggregating server.
# It will configure the server to recieve
# logs on TCP port 514.
# - reg1z
####

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi





#### GAME-DAY IPs to receive logs from: ###################
#
# IP_ROUTER="192.168.$TEAM_NUM.1"        # router
#
# # external hosts
# IP_EXT_KALI="172.18.15.$TEAM_NUM"      # external kali
# IP_EXT_SHELLFTP="172.18.14.$TEAM_NUM"  # FTP/Shell server (jump host?)
#
# # internal hosts
# IP_INT_WWW="192.168.$TEAM_NUM.5"       # web server
# IP_INT_DB="192.168.$TEAM_NUM.7"        # sql server
# IP_INT_KALI="192.168.$TEAM_NUM.10"     # internal kali
# IP_INT_DNS="192.168.$TEAM_NUM.12"      # dns server
# IP_INT_BACKUP="192.168.$TEAM_NUM.15"   # backup server
###########################################################


# "imtcp" = use tcp
# "imudp" = use udp
MODULE="imtcp"

LOG_LOC="/var/log"
LISTEN_PORT="514"

# Test IPs to receive logs from:
LISTEN_IPS=("172.20.56.2" "192.168.56.1" "192.168.56.3")


# rsyslog configuration directory/files
#   - NOTE: the main config is "/etc/rsyslog.conf".
#           this config will just be tacked onto the
#           main config, whatever it's set to.
CONF_DIR="/etc/rsyslog.d"
CONF_FILE="$CONF_DIR/logReceive.conf"

# Create the config directory + file if not already existing
mkdir -p $CONF_DIR
#touch $CONF_FILE

# Fill the file with the config lines
cat << EOF > $CONF_FILE
# Enable TCP reception
module(load="$MODULE") # Load TCP module
input(type="$MODULE" port="514")

# BOTH
input(type="$MODULE" port="$LISTEN_PORT" address="$IP_ROUTER")       # router

# EXTERNAL HOSTS
input(type="$MODULE" port="$LISTEN_PORT" address="$IP_EXT_KALI")     # external kali
input(type="$MODULE" port="$LISTEN_PORT" address="$IP_EXT_SHELLFTP") # FTP/Shell server (jump host?)

# INTERNAL HOSTS
input(type="$MODULE" port="$LISTEN_PORT" address="$IP_INT_WWW")      # web server
input(type="$MODULE" port="$LISTEN_PORT" address="$IP_INT_DB")       # database server
input(type="$MODULE" port="$LISTEN_PORT" address="$IP_INT_KALI")     # internal kali
input(type="$MODULE" port="$LISTEN_PORT" address="$IP_INT_DNS")      # dns server
input(type="$MODULE" port="$LISTEN_PORT" address="$IP_INT_BACKUP")   # backup server

EOF


for IP in "${LISTEN_IPS[@]}"; do
  echo "Configuring rsyslog to listen using $MODULE on $IP..."
  cat << EOF >> "$CONF_FILE"
input(type="$MODULE" port="$LISTEN_PORT" address="$IP")
EOF
done

# Restart rsyslog
echo -e "\nRestarting syslog service...\n\n"
systemctl restart rsyslog

# Check if rsyslog restarted successfully
if [ $? -eq 0 ]; then
  echo "Log aggregator is now listening with $MODULE on the following IPs for logs on port $LISTEN_PORT:"
  for IP in "${LISTEN_IPS[@]}"; do
    echo "- $IP"
  done
else
  echo "Failed to restart rsyslog. Check the configuration."
fi

# Make sure logs go to the correct locations
echo "Configuring log storage by hostname..."
cat << EOF >> "$CONF_FILE"
$template RemoteLogs,"/var/log/remote/%FROMHOST-IP%/%syslogtag%.log"
*.* ?RemoteLogs
EOF


