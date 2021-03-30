#!/bin/bash

TIMESTAMP=`date +%Y-%m-%d__%H-%M-%S`
BACKUP_FOLDER_ID="<FOLDER_ID_FROM_GDRIVE>"

# appdata folders to backup (separated by spaces)
APP_LIST=""

# docker-appdata folders to backup (separated by spaces)
DAPP_LIST=""

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
mkdir /opt/backup/data/$BACKUP_FOLDER/docker-appdata
mkdir /opt/backup/data/$BACKUP_FOLDER/appdata

for service in $DAPP_LIST; do
    tar --exclude="<FOLDER_TO_EXCLUDE>" -cvjf - /mnt/docker-appdata/$service | gpg --trust-model always -e -r <GPG_KEY_ID> -o /opt/backup/data/$BACKUP_FOLDER/appdata/$service.tar.bz2.gpg
done

for service in $APP_LIST; do
    tar --exclude="node_modules" --exclude=".npm" -cvjf - /mnt/appdata/$service | gpg --trust-model always -e -r <GPG_KEY_ID> -o /opt/backup/data/$BACKUP_FOLDER/docker-appdata/$service.tar.bz2.gpg 
done

gdrive sync upload /opt/backup/data/ $BACKUP_FOLDER_ID
