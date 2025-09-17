#!/bin/bash

# Script to apply a public-read bucket policy to an S3 bucket.
# This is commonly needed after enabling static website hosting.
# Usage: ./set-public-read-policy.sh <BUCKET_NAME>
# Example: ./set-public-read-policy.sh my-website-bucket

# Check if a bucket name was provided
if [ -z "$1" ]; then
  echo "Error: No bucket name provided."
  echo "Usage: $0 <BUCKET_NAME>"
  exit 1
fi

BUCKET_NAME=$1

echo "Applying public-read policy to bucket '$BUCKET_NAME'..."

# Create the policy document
POLICY=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
        }
    ]
}
EOF
)

# Apply the bucket policy
aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy "$POLICY"

if [ $? -eq 0 ]; then
    echo "Public-read policy applied successfully to bucket '$BUCKET_NAME'."
else
    echo "Error applying bucket policy. Make sure public access is not blocked at the account level."
    exit 1
fi

echo "Script finished."
