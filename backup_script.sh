#!/bin/bash

# This file must be created which defines the following variables
# SEAFDIR - Seafile installation directory
# SEAFDATADIR - Seafile data directory
# BACKUPDIR - Directory to store backups in
# BUCKET_PATH - Path to store backup in the form b2://b2_bucket_name/path
# SEAFILE_USER - User who owns the seafile data directory
# B2_ACCOUNT_INFO - File with cached B2 authorisation info (created by backblaze-b2)
source backup_script_private.sh

TIMESTAMP=$(date +"%F_%H%M%S_%N")
{
# Access scripts in the current directory easily...
cd $(dirname $0)

export B2_ACCOUNT_INFO

# Stop the server
echo "Shutting down seafile"
su $SEAFILE_USER -c "${SEAFDIR}/seafile-server-latest/seahub.sh stop"
su $SEAFILE_USER -c "${SEAFDIR}/seafile-server-latest/seafile.sh stop"

# Dump databases
echo Dumping GroupMgr database
sqlite3 ${SEAFDIR}/ccnet/GroupMgr/groupmgr.db .dump > ${SEAFDATADIR}/database_backups/groupmgr.db.bak_${TIMESTAMP}
echo Dumping UserMgr database...
sqlite3 ${SEAFDIR}/ccnet/PeerMgr/usermgr.db .dump > ${SEAFDATADIR}/database_backups/usermgr.db.bak_${TIMESTAMP}
echo Dumping SeaFile database...
sqlite3 ${SEAFDATADIR}/seafile.db .dump > ${SEAFDATADIR}/database_backups/seafile.db.bak_${TIMESTAMP}
echo Dumping SeaHub database...
sqlite3 ${SEAFDIR}/seahub.db .dump > ${SEAFDATADIR}/database_backups/seahub.db.bak_${TIMESTAMP}

echo "Running backup"
./backup.sh ${SEAFDATADIR} ${BACKUPDIR}

# Stop the server
echo "Starting up seafile"
su $SEAFILE_USER -c "${SEAFDIR}/seafile-server-latest/seahub.sh start"
su $SEAFILE_USER -c "${SEAFDIR}/seafile-server-latest/seafile.sh start"

echo "Syncing to backblaze"
# Threads 1 prevents us from accidentally maxing out our internet!
# We should set the lifecycle rules to keep all versions (default behaviour) just in case
backblaze-b2 sync --threads 1 $BACKUPDIR $BUCKET_PATH

} 2>&1 | tee ${BACKUPDIR}/${TIMESTAMP}.log
