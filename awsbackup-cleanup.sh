#!/bin/bash

vAWSVaultName=$1
vAWSInventoryFile='./aws-backup-restore-points.json'

# Retrieve vault backup points for deletion
aws backup list-recovery-points-by-backup-vault --backup-vault-name ${vAWSVaultName} > ${vAWSInventoryFile}

## Parse inventory file
vArchiveIds=$(jq -r .RecoveryPoints[].RecoveryPointArn < ${vAWSInventoryFile})
vFileCount=1

## Echo out to start 
echo Starting remove task

read -p "Are you sure? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then

for vArchiveId in ${vArchiveIds}; do
    echo "Deleting Archive #${vFileCount}: ${vArchiveId}"
    aws backup delete-recovery-point --recovery-point-arn=${vArchiveId} --backup-vault-name ${vAWSVaultName}
    let "vFileCount++"
done

fi

## Echo out to finish
echo Finished remove task on ${vFileCount} archives

