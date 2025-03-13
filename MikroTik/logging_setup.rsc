# ===================================================
# Script Name: logging_setup.rsc
# Description: Setup Logging to Remote Server
# Author: Paul DuHamel Jr - Team 1
# Created: 3/12/2025
# Last Modified: 3/12/2025
# Version: 1.0
# ===================================================

## create remote logging action named "remote", sends log to specified IP address on port 514 (note, we will utilize a default rule here and modify it to our needs) 
 
## locate the 'remote' rule and number (IE: name="remote")
 
System logging action print 
 
## update IP address to remote syslog server (ctrl+o to save/quit) 
 
System logging action edit number=3 remote 
 
## update IP address to router IP address for proper routing 
 
System logging action edit number=3 src-address 
 
## specify which topics are logged and where to log them 
 
## view current actions 
 
System logging print 
 
## set action to remote for desired topics (numbers will vary based on your needs, action name was specified in the above steps) 
 
System logging set numbers=0,1,2,3,4,5 action=remote 
 
## once you have your remote log server setup, you can test this by producing a log with... 
 
Log info message="TESTLOG" 

## additionally, you can add a comment to the 'remote' logging action to make searching and identifying easier (IE: comment -> FirewallTest)

system logging action edit number=3 comment
