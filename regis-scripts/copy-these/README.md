# Instructions

## Copy paste and then run the scripts in this order

### *(If you CAN'T copy paste because of you only have a terminal, then MANUALLY CONFIGURE YOUR IP/NETWORK SHIT)*
YOU WILL THEN BE ABLE TO DOWNLOAD WHAT YOU NEED WITH A SIMPLE `curl` COMMAND.

Remember to give them executable permissions!
`sudo chmod 700 <script>.sh`

Run them! With `sudo`!
1. `sudo ./1-rsyncBackup.sh`
2. `sudo ./2-setupLoggingUser.sh`
3. `sudo ./3-networkSetup.sh`
4. Find the corresponding download script in the 4-key-scripts-download


---


## Rocky Linux Setup
### 1. Manually create backup folder in the future logging user's directory
- `mkdir -p /home/logging/backups`

### 2. Manual rsync backup
- `rsync -a -v /etc/ /home/logging/backups/etc/`
- `rsync -a -v --exclude='logging/backups' /home/ /home/logging/backups/home/`
- `rsync -a -v /var/ /home/logging/backups/var/`

### 3. Manually configure your other system/service specific things
???

### 4. Wait for ALL CLEAR -> Download scripts tarball
- `curl http://$LOGGING_SERVER_IP:8000/scripts.tar.gz -o /home/logging/scripts.tar.gz`

### 5. Extract the tarball to: `/home/logging/scripts`
- `mkdir /home/logging/scripts`
- `tar -xzf "/home/logging/scripts.tar.gz -C "/home/logging/scripts"`

### 6. Run the scripts
- `cd /home/logging/scripts/copy-these`
- `sudo chmod ...scripts`
- Run the scripts from `/home/logging/scripts/copy-these ` (as above)

