# ===================================================
# Script Name: Base_Config.rsc
# Description: Initial setup of Mikrotik router for the NCAE Cyber Games 2025 event
# Author: Paul DuHamel Jr - Team 1
# Created: 3/12/2025
# Last Modified: 3/12/2025
# Version: 1.0
# ===================================================

# MikroTik RouterOS Configuration Script 

  

#reset config 

System reset-configuration  

 

# Create new user 

/user add name=myname password=mypassword group=full  

# Disable admin user 

/user disable admin  

 

# Set Router Identity 

/system identity set name=MyRouter 

  

# Set Timezone 

/system clock set time-zone-name=America/New_York 

 

# Setup LAN interface (CHANGE IP ACCORDINGLY) 

Ip address add address=192.168.#.1 interface=ether# disabled=no comment=LAN 

 

# Setup WAN interface (CHANGE IP ACCORDINGLY) 

Ip address add address=172.20.#.1 interface=ether# disabled=no comment=WAN 

 

# Configure NAT (Masquerade traffic from LAN to WAN) (CHANGE INTERFACE ACCORDINGLY) 

/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade 

 

# Save Configuration (ADD NAME AND PASSWORD) 

/system backup save name=baseconfig encryption=aes-sha256 password= 
