#!/bin/bash

# Script to enable static website hosting on an S3 bucket.
# Usage: ./enable-static-website-hosting.sh <BUCKET_NAME>
# Example: ./enable-static-website-hosting.sh my-website-bucket

# Check if a bucket name was provided
if [ -z "$1" ]; then
  echo "Error: No bucket name provided."
  echo "Usage: $0 <BUCKET_NAME>"
  exit 1
fi

BUCKET_NAME=$1
INDEX_DOC="index.html"
ERROR_DOC="error.html"

echo "Enabling static website hosting for bucket '$BUCKET_NAME'..."
echo "Index document: $INDEX_DOC"
echo "Error document: $ERROR_DOC"

aws s3 website "s3://$BUCKET_NAME" --index-document "$INDEX_DOC" --error-document "$ERROR_DOC"

if [ $? -eq 0 ]; then
    # Get the region of the bucket to construct the website URL
    REGION=$(aws s3api get-bucket-location --bucket "$BUCKET_NAME" --query 'LocationConstraint' --output text)
    if [ -z "$REGION" ] || [ "$REGION" == "None" ]; then
        # us-east-1 returns a null location constraint, or "None" in some CLI versions
        REGION="us-east-1"
    fi
    
    # S3 website endpoint formats vary by region
    if [ "$REGION" == "us-east-1" ]; then
        echo "Website hosting enabled successfully."
        echo "Endpoint: http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"
    else
        echo "Website hosting enabled successfully."
        echo "Endpoint: http://$BUCKET_NAME.s3-website.$REGION.amazonaws.com"
    fi
else
    echo "Error enabling website hosting. Please check the bucket name and permissions."
    exit 1
fi

echo "Script finished."
