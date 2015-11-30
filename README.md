# Dropbox to AWS S3 Syncer

A Docker image that watches a directory of files (typically from Dropbox), and
syncs any changes to Amazon S3.

The synced directory is assumed to be mounted as a volume to /dbox/Dropbox.

This Docker image is not intended to be used alone, but in conjuction with a
Dropbox-in-Docker container https://github.com/redradishtech/docker-dropbox.
See the `docker-compose.yml` file in the parent directory.

## Required Environment Variables

AWS connection details:

	AWS_ACCESS_KEY_ID
	AWS_SECRET_ACCESS_KEY
	AWS_DEFAULT_REGION

	S3_BUCKET			# Name of the S3 bucket to to

## Optional env variables

	DIRECTORY_TO_SYNC		# If you wish to sync only a subdirectory of /dbox/Dropbox, specify it here.
	S3_SYNC_FLAGS			# Flags passed to 'aws s3 sync'. You might like '--dry-run' to start with, or '--delete' if you're really confident

