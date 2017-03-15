# RMZ Backup Configuration

BCKUSER="backup"
BCKHOST="localhost"

export PASSPHRASE='secretpassphrase'
export SFTP_OPTIONS="-oIdentityFile=/etc/rmzbackup/backup-ssh-key"
export SSH_OPTIONS="--ssh-options=-oIdentityFile=/etc/rmzbackup/backup-ssh-key"
export BCKTARGET="${BCKUSER}@${BCKHOST}"
export SCP_TARGET="sftp://${BCKTARGET}/rmzbackup/${HOSTNAME}/"
export RMZ_PREFIX="rmzbck_"
export DUPLICITY="/usr/bin/duplicity"
export REMOVE_OLDER_THAN="2W"
export DUPLICITY_OPTIONS="--archive-dir=/data/rmzbackup --tempdir=/data/rmzbackup/tmp -v0"
export BCK_PATHS="etc data/db_backups"
