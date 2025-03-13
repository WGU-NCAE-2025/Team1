# ===================================================
# Script Name: retrieve_ssh.rsc
# Description: Retrieve SSH Key from LAN
# Author: Paul DuHamel Jr - Team 1
# Created: 3/12/2025
# Last Modified: 3/12/2025
# Version: 1.0
# ===================================================

## http option (change IP/file as needed) 

/tool fetch url="http://192.168.1.100:8080/test.pub" mode=http dst-path=test.pub 

 

## sftp option 

tool fetch address= src-path= user= mode=sftp password= dst-path= port=22 host="" keep-result=yes 
