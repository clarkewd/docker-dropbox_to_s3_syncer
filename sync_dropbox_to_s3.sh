#! /bin/bash



cp /root/.ssh/config_template /root/.ssh/config
MYCUSTOMTAB='  '
echo "${MYCUSTOMTAB}HostName $HOSTNAME" >> /root/.ssh/config
echo "${MYCUSTOMTAB}Port $PORT" >> /root/.ssh/config
echo "${MYCUSTOMTAB}User $USERNAME" >> /root/.ssh/config



SRC=/dbox/Dropbox/"${DIRECTORY_TO_SYNC:-}"
DEST=remote:"${DIRECTORY_ON_SERVER:-}"
SLEEPSECONDS=8

function log() {
    echo "`date`:       $*"
}

log "$SRC to $DEST syncer started"

function block_for_change {
    inotifywait -m -r \
        -e modify,move,create,delete \
        "$SRC"
}

function sync {
  echo "Running rsync... $SRC to $DEST"
  rsync -rlptvzO --delete $SRC $DEST
}


sync
block_for_change | while read dir events filename
do
    # log "DIR IS: $dir"
    # log "EVENTS: $events"
    # log "FILEIS: $filename"

    sync
    sleep $SLEEPSECONDS
    log "Sync completed, sleeping $SLEEPSECONDS seconds"
done

log "$0 exited."
