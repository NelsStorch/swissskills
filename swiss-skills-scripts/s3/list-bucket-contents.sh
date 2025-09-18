#!/bin/bash

# Script to list the contents of an AWS S3 bucket.
# Outputs the list of contents to stdout.
# Usage: ./list-bucket-contents.sh --bucket-name <BUCKET_NAME> [--details]
# Example: ./list-bucket-contents.sh --bucket-name my-bucket
# Example: ./list-bucket-contents.sh --bucket-name my-bucket --details

# --- Argument Parsing ---
BUCKET_NAME=""
SHOW_DETAILS=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --bucket-name)
            BUCKET_NAME="$2"
            shift
            ;;
        --details)
            SHOW_DETAILS=true
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
  echo "Usage: $0 --bucket-name <BUCKET_NAME> [--details]" >&2
  exit 1
fi

# --- Main Logic ---
echo "Listing contents for bucket: $BUCKET_NAME..." >&2

# Build command arguments
LS_ARGS=("s3://$BUCKET_NAME")
if [ "$SHOW_DETAILS" = true ]; then
    LS_ARGS+=(--recursive --human-readable --summarize)
fi

# List bucket contents and capture output
aws_output=$(aws s3 ls "${LS_ARGS[@]}" 2>&1)

if [ $? -ne 0 ]; then
    echo "Error listing bucket contents." >&2
    echo "AWS CLI Error: $aws_output" >&2
    exit 1
fi

# Print the list to stdout
echo "$aws_output"
