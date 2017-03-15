#!/bin/bash
# 
#  Copyright (c) 2014-2017, Reto Zingg <g.d0b3rm4n@gmail.com>
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#
#  1. Redistributions of source code must retain the above copyright notice, this
#     list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
#  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

if [ -f /etc/rmzbackup/config.inc ]; then
    . /etc/rmzbackup/config.inc
fi

if [ -f /etc/rmzbackup/config.local ]; then
    . /etc/rmzbackup/config.local
fi

WEEKDAY=$(date +%u)

for BCK_PATH in $BCK_PATHS
do
    D_OK=0

    echo "---------- $BCK_PATH ----------"
    BCK_PATH_NAME=${BCK_PATH//\//_}

    if [ -f /etc/rmzbackup/${BCK_PATH_NAME}-EXCLUDE.conf ];then
        DUPLICITY_EXCLUDE="--exclude-filelist=/etc/rmzbackup/${BCK_PATH_NAME}-EXCLUDE.conf"
    fi

    if [ "$BCK_PATH_NAME" != "${BCK_PATH_NAME/data_db_backups}" ];then
        pushd /data/db_backups/postgresql
        su -c "/usr/bin/pg_backup_rotated.sh -c /etc/pg_backup.config" postgres
        M_OK=$?
	popd

        if [ $M_OK = 1 ];then
            D_OK=1
        fi
    fi

    if [ $D_OK = 0 ];then
        $DUPLICITY full $SSH_OPTIONS $DUPLICITY_OPTIONS $DUPLICITY_EXCLUDE \
                        /$BCK_PATH ${SCP_TARGET}${RMZ_PREFIX}${BCK_PATH_NAME}
        # get exit status of the backup command
        D_OK=$?
    fi

    if [ $D_OK = 0 ];then
        $DUPLICITY remove-older-than $REMOVE_OLDER_THAN --force $SSH_OPTIONS $DUPLICITY_OPTIONS ${SCP_TARGET}${RMZ_PREFIX}${BCK_PATH_NAME}
    else
        echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- BACKUP FAILED!!!! +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-"
    fi

    if [ $WEEKDAY = 1 ];then
        $DUPLICITY collection-status $SSH_OPTIONS $DUPLICITY_OPTIONS ${SCP_TARGET}${RMZ_PREFIX}${BCK_PATH_NAME}
    fi

    unset DUPLICITY_EXCLUDE
done

echo 'df -h'  | sftp ${SFTP_OPTIONS} $BCKTARGET
echo 'df -hi' | sftp ${SFTP_OPTIONS} $BCKTARGET

