#! /bin/bash

# Syncs local directory $SRC with aws s3 bucket $DEST. When file foo is added,
# a temporary marker file foo.uploading.txt is created while the file is
# uploading to S3. The marker file is deleted once the upload is completed, or
# else a foo.uploadfailures.txt file is left with the error.

#SRC=/home/jturner/coastec/dropbox_to_s3_syncer/dropbox/Dropbox
#DEST=
SRC=/dbox/Dropbox/"${DIRECTORY_TO_SYNC:-}"
DEST=s3://"$S3_BUCKET"


function log() {
    echo "`date`:       $*"
}

log "$SRC to $DEST syncer started"

function block_for_change {
    inotifywait -m -r \
        -e modify,move,create,delete \
	--exclude ".*\.upload(ing|ed|failures)\.txt" \
        "$SRC"
}

function sync {
        aws s3 sync "$SRC" "$DEST" --exclude .dropbox ${S3_SYNC_FLAGS:-}
}

# Creates a .uploading.txt, .uploaded.txt or .uploadfailures.txt marker file in Dropbox to indicate the status of a file upload.
function upload_marker_file {
	local state="$1"	# Upload status. 'begin', 'success' or an error message
	local dir="$2"		# Upload file's dir
	local events="$3"	# aws s3 sync event. We only care about CREATE
	local filename="$4"	# Upload filename
	case $events in
	   CREATE)
		case $state in
		   begin)
			if [[ $events = CREATE ]]; then
				echo "Upload began at `date`" >> "$dir"/"$filename".uploading.txt
			fi
		   ;;
		   success)
				rm -f "$dir"/"$filename".{uploading,uploadfailures}.txt 
				# Alternatively, if we want a permament record:
		#		echo "Upload finished at `date`" >> "$dir"/"$filename".uploading.txt
		#		mv "$dir"/"$filename".uploading.txt "$dir"/"$filename".uploaded.txt
		   ;;
		   *)
			   # Error of some sort
				echo -e "Upload failed at `date`:\n'$state'" >> "$dir"/"$filename".uploading.txt
				cat "$dir"/"$filename".uploading.txt >> "$dir"/"$filename".uploadfailures.txt
				rm "$dir"/"$filename".uploading.txt
		esac
	esac
}

sync
block_for_change | while read dir events filename
do
    upload_marker_file begin "$dir" "$events" "$filename"
    log "Sync starting: files altered: $filename"
    set -vx
    result=$(sync 2>&1)
    [[ $? == 0 ]] && upload_marker_file success "$dir" "$events" "$filename" ||  upload_marker_file "$result" "$dir" "$events" "$filename"
    sleep 1
    log "Sync completed"
done
log "$0 exited."
