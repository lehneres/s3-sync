#!/bin/bash
set -Eeo pipefail

if [ -z "$S3_BUCKET" ] || [ -z "$DESTINATION" ]; then
  echo "Must set S3_BUCKET and DESTINATION env vars" 1>&2
  exit 1
fi

# OWNER_UID defaults to 0
if [ -z "$OWNER_UID" ]; then
  OWNER_UID=0
fi

# OWNER_GID default to OWNER_UID
if [ -z "$OWNER_GID" ]; then
  OWNER_GID=$OWNER_UID
fi

function pull_data {
  echo "Pulling initial Data from S3"
  aws s3 sync s3://$S3_BUCKET$S3_KEY $DESTINATION

  # Optionally set file permissions
  echo "Setting permissions to $OWNER_UID:$OWNER_GID"
  chown -R $OWNER_UID:$OWNER_GID $DESTINATION
  
  touch /initial_sync_completed
  echo "Done"
}

pull_data

function push_data {
  echo "Pushing Data to S3"
  aws s3 sync $DESTINATION s3://$S3_BUCKET$S3_KEY
}

trap push_data SIGHUP SIGINT SIGTERM

while [ -n "$INTERVAL" ]; do
  s=`date +'%s'`
  
  push_data

  sleep $(( $INTERVAL - (`date +'%s'` - $s) ))
done
