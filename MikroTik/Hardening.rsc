# ===================================================
# Script Name: hardening.rsc
# Description: Hardening Script for MicroTik router for NCAE Cyber Games 2025
# Author: Paul DuHamel Jr - Team 1
# Created: 3/12/2025
# Last Modified: 3/12/2025
# Version: 1.0
# ===================================================

# Firewall: Secure MikroTik Without Blocking LAN

## Disabled local admin account (DO NOT RUN UNTIL YOU SET UP A NEW USER)
/user disable admin 

## Allow Established & Related Traffic
/ip firewall filter add chain=input connection-state=established,related action=accept comment="Allow Established & Related" log=yes log-prefix="EstablishedRelated"
/ip firewall filter add chain=forward connection-state=established,related action=accept log=yes log-prefix="EstablishedRelated"

## Drop Invalid Packets
/ip firewall filter add chain=input connection-state=invalid action=drop comment="Drop Invalid" log=yes log-prefix="DropInvalid"
/ip firewall filter add chain=forward connection-state=invalid action=drop log=yes log-prefix="DropInvalid"

## Allow ICMP (Limited)
/ip firewall filter add chain=input protocol=icmp limit=5,10 action=accept comment="Allow ICMP (Limited)" log=yes log-prefix="AllowICMP"
/ip firewall filter add chain=input protocol=icmp action=drop comment="Drop Excess ICMP" log=yes log-prefix="DropICMP"

## Secure Router Access (INPUT chain) UPDATE IP ADDRESS AND INTERFACES

/ip firewall filter add chain=input protocol=tcp dst-port=2222 src-address=192.168.54.0/24 action=accept comment="Allow SSH from LAN" log=yes log-prefix="AllowSSH"
/ip firewall filter add chain=input protocol=tcp dst-port=2222 in-interface=ether5 action=drop comment="Block SSH from WAN" log=yes log-prefix="BlockSSH_WAN"
/ip firewall filter add chain=input protocol=tcp dst-port=8291 in-interface=ether5 action=drop comment="Block Winbox from WAN" log=yes log-prefix="BlockWinbox_WAN"

## Block Direct Access from WAN UPDATE IP ADDRESS AND INTERFACES
/ip firewall filter add chain=input in-interface=ether5 action=drop comment="Block all access from WAN" log=yes log-prefix="BlockAll_WAN"

## Drop Port Scanners & Malicious Traffic
/ip firewall filter add chain=input protocol=tcp psd=21,3s,3,1 action=drop comment="Drop Port Scanners" log=yes log-prefix="DropPortScanners"
/ip firewall filter add chain=input protocol=tcp action=add-src-to-address-list address-list=port_scanners address-list-timeout=1d comment="Detect & Block Scanners" log=yes log-prefix="DetectScanners"
/ip firewall filter add chain=input src-address-list=port_scanners action=drop comment="Drop Known Scanners" log=yes log-prefix="DropScanners"

## Protect Against Brute Force Attacks (SSH & Winbox)
/ip firewall filter add chain=input protocol=tcp dst-port=2222 connection-state=new limit=2,5 action=accept comment="Limit SSH Attempts" log=yes log-prefix="LimitSSH"
/ip firewall filter add chain=input protocol=tcp dst-port=2222 connection-state=new action=drop comment="Block Excess SSH" log=yes log-prefix="BlockSSH"
/ip firewall filter add chain=input protocol=tcp dst-port=8291 connection-state=new limit=2,5 action=accept comment="Limit Winbox Attempts" log=yes log-prefix="LimitWinbox"
/ip firewall filter add chain=input protocol=tcp dst-port=8291 connection-state=new action=drop comment="Block Excess Winbox" log=yes log-prefix="BlockWinbox"

## Allow HTTP access from LAN UPDATE IP ADDRESS AND INTERFACES
/ip firewall filter add chain=input protocol=tcp dst-port=8080 src-address=192.168.54.0/24 action=accept comment="Allow WebFig from LAN" log=yes log-prefix="AllowWebFig"
/ip firewall filter add chain=input protocol=tcp dst-port=8080 connection-state=new limit=2,5 action=accept comment="Limit WebFig Attempts" log=yes log-prefix="LimitWebFig"
/ip firewall filter add chain=input protocol=tcp dst-port=8080 connection-state=new action=drop comment="Block Excess WebFig" log=yes log-prefix="BlockWebFig"

## Default Drop Rule (Last Rule in INPUT)
/ip firewall filter add chain=input action=drop comment="Drop All Other Unwanted Input Traffic" log=yes log-prefix="DropAll"

# Secure MikroTik Services (disabled www after inputting script!!!!!)
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=no
/ip service set www-ssl disabled=yes
/ip service set ssh port=2222
/ip service set winbox disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
