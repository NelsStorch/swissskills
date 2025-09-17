#!/bin/bash

# Script to list the contents of an AWS S3 bucket.
# Usage: ./list-bucket-contents.sh <BUCKET_NAME> [--details]
# Example: ./list-bucket-contents.sh my-bucket
# Example: ./list-bucket-contents.sh my-bucket --details

# Check if a bucket name was provided
if [ -z "$1" ]; then
  echo "Error: No bucket name provided."
  echo "Usage: $0 <BUCKET_NAME> [--details]"
  exit 1
fi

BUCKET_NAME=$1
SHOW_DETAILS=false

if [ "$2" == "--details" ]; then
    SHOW_DETAILS=true
fi

# List bucket contents
echo "Listing contents for bucket: $BUCKET_NAME..."

if [ "$SHOW_DETAILS" = true ]; then
    aws s3 ls "s3://$BUCKET_NAME" --recursive --human-readable --summarize
else
    aws s3 ls "s3://$BUCKET_NAME"
fi

if [ $? -ne 0 ]; then
    echo "Error listing bucket contents. Make sure the bucket name is correct and you have permissions."
    exit 1
fi

echo "Script finished."
