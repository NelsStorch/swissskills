#!/bin/bash

# Script to apply a public-read bucket policy to an S3 bucket.
# This is commonly needed after enabling static website hosting.
# On success, this script produces no output on stdout.
# Usage: ./set-public-read-policy.sh --bucket-name <BUCKET_NAME>
# Example: ./set-public-read-policy.sh --bucket-name my-website-bucket

# --- Argument Parsing ---
BUCKET_NAME=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --bucket-name)
            BUCKET_NAME="$2"
            shift
            ;;
        *)
            echo "Unknown parameter passed: $1" >&2
            exit 1
            ;;
    esac
    shift
done

# Validate arguments
if [ -z "$BUCKET_NAME" ]; then
  echo "Error: The --bucket-name flag is required." >&2
  echo "Usage: $0 --bucket-name <BUCKET_NAME>" >&2
  exit 1
fi

# --- Main Logic ---
echo "Applying public-read policy to bucket '$BUCKET_NAME'..." >&2

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
aws_output=$(aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy "$POLICY" 2>&1)

if [ $? -eq 0 ]; then
    echo "Public-read policy applied successfully to bucket '$BUCKET_NAME'." >&2
else
    echo "Error applying bucket policy. Make sure public access is not blocked at the account level." >&2
    echo "AWS CLI Error: $aws_output" >&2
    exit 1
fi
