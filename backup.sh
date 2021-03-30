#!/bin/bash

TIMESTAMP=`date +%Y-%m-%d__%H-%M-%S`
BACKUP_FOLDER_ID="<GDRIVE-ID>"

# appdata folders to backup (separated by spaces)
APP_LIST="<FOLDERS SEPARATED BY SPACES>"

# docker-appdata folders to backup (separated by spaces)
DAPP_LIST="<FOLDERS SEPARATED BY SPACES>"

if [ ! -f "/mnt/appdata/.itworks" ]; then
    echo "/mnt/appdata : not mounted, not backing up"
    exit 1
fi

if [ ! -f "/mnt/docker-appdata/.itworks" ]; then
    echo "/mnt/docker-appdata : not mounted, not backing up"
    exit 1
fi

BACKUP_FOLDER="backup-$TIMESTAMP"

mkdir /opt/backup/data/$BACKUP_FOLDER
mkdir /opt/backup/data/$BACKUP_FOLDER/docker
mkdir /opt/backup/data/$BACKUP_FOLDER/docker/appdata
mkdir /opt/backup/data/$BACKUP_FOLDER/appdata

for service in $DAPP_LIST; do
    echo "BACKUP : /mnt/docker-appdata/$service"
    tar --exclude="<FOLDER_TO_EXCLUDE>" -cjf - /mnt/docker-appdata/$service | gpg --trust-model always -e -r <KEY_ID> -o /opt/backup/data/$BACKUP_FOLDER/docker/$service.tar.bz2.gpg
done

for service in $APP_LIST; do
    echo "BACKUP : /mnt/appdata/$service"
    tar --exclude="node_modules" --exclude=".npm" -cjf - /mnt/appdata/$service | gpg --trust-model always -e -r <KEY_ID> -o /opt/backup/data/$BACKUP_FOLDER/appdata/$service.tar.bz2.gpg 
done

/usr/local/go/bin/gdrive sync upload /opt/backup/data/$BACKUP_FOLDER $BACKUP_FOLDER_ID
rm /opt/backup/data/$BACKUP_FOLDER -rf
