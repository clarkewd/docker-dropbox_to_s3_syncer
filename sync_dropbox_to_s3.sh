#! /bin/bash -eu

SRC=/dbox/Dropbox/"${DIRECTORY_TO_SYNC:-}"
DEST=s3://"$S3_BUCKET"


function log() {
    echo "`date`:       $*"
}

log "$SRC to $DEST syncer started"

function block_for_change {
    log "Watching for changes in $SRC"
    inotifywait -r \
        -e modify,move,create,delete \
        --exclude ".*.swp" \
        "$SRC"
}

function sync {
        aws s3 sync "$SRC" "$DEST" --exclude .dropbox ${S3_SYNC_FLAGS:-}
}

sync
while block_for_change
do
    log "Sync starting"
    sync
    log "Sync completed"
done
log "$0 finished. This should not normally happen"
