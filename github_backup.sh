#!/bin/bash
# Author: Salih Marangoz

##############################################################################################################

# Required packages:
# $ sudo apt install python-pip git nmcli
# $ sudo -H pip install github-backup

# Usage:
# $ bash github_backup.sh

# How to set automatic backup (cron):
# sudo cp github_backup.sh /etc/github_backup.sh
# sudo chmod -x /etc/github_backup.sh
# $ crontab -e
# Place the line below at the end of the file:
# 00 20 * * * /bin/bash /etc/github_backup.sh # everyday at 20:00

# How to convert bare repository to normal repository:
# $ cd /path/to/repository
# $ mkdir .git
# $ mv *!(.git) .git/
# $ git config --local --bool core.bare false
# $ git reset --hard

# References:
# https://github.com/josegonzalez/python-github-backup
# https://stackoverflow.com/questions/43228973/detect-if-current-connection-is-metered-with-networkmanager

##############################################################################################################

# Parameters
export PATH=$PATH":/usr/local/bin/"
export ACCESS_TOKEN="PLACE_GITHUB_READONLY_API_TOKEN_HERE"                            # <== PLACE GITHUB ACCESS TOKEN HERE
export USERNAME="PLACE_GITHUB_USERNAME_HERE"                                          # <== PLACE GITHUB USERNAME TOKEN HERE
export PRIVATE_BACKUP_ENABLED="yes"
export FORKED_BACKUP_ENABLED="yes"
export STARRED_BACKUP_ENABLED="yes"
export PRIVATE_BACKUP_PARAMETERS="--all --bare --incremental"
export FORKED_BACKUP_PARAMETERS="--repositories --wikis --issues --pulls --labels --milestones --releases --bare --incremental"
export STARRED_BACKUP_PARAMETERS="--repositories --wikis --issues --pulls --labels --milestones --releases --bare --incremental"
export OUTPUT_DIRECTORY=$HOME"/github_backup"
export LOG_FILE=$OUTPUT_DIRECTORY"/github_"$USERNAME"_backup.log"
export CONTINUE_IF_METERED="no"
export RESET_LOGFILE="yes"
export MANAGE_FS_PERMISSIONS="yes"

# Create output directories if not exist
mkdir -p $OUTPUT_DIRECTORY
if [ $? -ne 0 ] ; then
    echo "Output directory cant be created"
    exit 1
fi
echo "$(date "+%m%d%Y %T") : Created output directories" >> $LOG_FILE

# Manage filesystem permissions
if [[ $MANAGE_FS_PERMISSIONS == *"yes"* ]]; then
    echo "$(date "+%m%d%Y %T") : Changing output directory and log file permissions" >> $LOG_FILE
    chmod 700 $OUTPUT_DIRECTORY
    chmod 700 $LOG_FILE
fi

# Reset logfile
echo "======================================================================" >> $LOG_FILE
if [[ $RESET_LOGFILE == *"yes"* ]]; then
    echo "$(date "+%m%d%Y %T") : Resetting log file" > $LOG_FILE
fi

# Check if network is metered
NETWORK_DEVICE=$(nmcli -g GENERAL.DEVICE dev show `ip route list 0/0 | sed -r 's/.*dev (\S*).*/\1/g'`)
echo "$(date "+%m%d%Y %T") : Active network device: $NETWORK_DEVICE" >> $LOG_FILE
NETWORK_METERED=$(nmcli -g GENERAL.METERED dev show `ip route list 0/0 | sed -r 's/.*dev (\S*).*/\1/g'`)
echo "$(date "+%m%d%Y %T") : Is connection metered: $NETWORK_METERED" >> $LOG_FILE
if [ $CONTINUE_IF_METERED == *"no"* ]; then
    if [[ $NETWORK_METERED == *"yes"* ]]; then
        echo "$(date "+%m%d%Y %T") : Process aborted because current network is metered!" >> $LOG_FILE
        exit
    fi
fi

# Do backups
if [[ $PRIVATE_BACKUP_ENABLED == *"yes"* ]]; then
    echo "$(date "+%m%d%Y %T") : Running private backup" >> $LOG_FILE
    echo "" >> $LOG_FILE
    github-backup $USERNAME --token $ACCESS_TOKEN --output-directory $OUTPUT_DIRECTORY $PRIVATE_BACKUP_PARAMETERS --private --gists >> $LOG_FILE 2>&1
    echo "" >> $LOG_FILE
fi

if [[ $FORKED_BACKUP_ENABLED == *"yes"* ]]; then
    echo "$(date "+%m%d%Y %T") : Running fork backup" >> $LOG_FILE
    echo "" >> $LOG_FILE
    github-backup $USERNAME --token $ACCESS_TOKEN --output-directory $OUTPUT_DIRECTORY $FORKED_BACKUP_PARAMETERS --fork >> $LOG_FILE 2>&1
    echo "" >> $LOG_FILE
fi

if [[ $STARRED_BACKUP_ENABLED == *"yes"* ]]; then
    echo "$(date "+%m%d%Y %T") : Running starred backup" >> $LOG_FILE
    echo "" >> $LOG_FILE
    github-backup $USERNAME --token $ACCESS_TOKEN --output-directory $OUTPUT_DIRECTORY $STARRED_BACKUP_PARAMETERS --all-starred --starred-gists >> $LOG_FILE 2>&1
    echo "" >> $LOG_FILE
fi

# Finished
echo "$(date "+%m%d%Y %T") : Backup completed" >> $LOG_FILE


