#!/bin/bash

# Script to enable static website hosting on an S3 bucket.
# Outputs the website endpoint URL on success.
# Usage: ./enable-static-website-hosting.sh --bucket-name <name> [--index-document <doc>] [--error-document <doc>]
# Example: ./enable-static-website-hosting.sh --bucket-name my-website-bucket

# --- Argument Parsing ---
BUCKET_NAME=""
INDEX_DOC="index.html" # Default
ERROR_DOC="error.html" # Default

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --bucket-name)
            BUCKET_NAME="$2"
            shift
            ;;
        --index-document)
            INDEX_DOC="$2"
            shift
            ;;
        --error-document)
            ERROR_DOC="$2"
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
echo "Enabling static website hosting for bucket '$BUCKET_NAME'..." >&2
echo "Index document: $INDEX_DOC" >&2
echo "Error document: $ERROR_DOC" >&2

aws_output=$(aws s3 website "s3://$BUCKET_NAME" --index-document "$INDEX_DOC" --error-document "$ERROR_DOC" 2>&1)

if [ $? -eq 0 ]; then
    echo "Website hosting enabled successfully." >&2

    # Get the region of the bucket to construct the website URL
    REGION=$(aws s3api get-bucket-location --bucket "$BUCKET_NAME" --query 'LocationConstraint' --output text)
    # Handle the us-east-1 region case where LocationConstraint is null or "None"
    if [ -z "$REGION" ] || [ "$REGION" == "None" ] || [ "$REGION" == "null" ]; then
        REGION="us-east-1"
    fi
    
    # S3 website endpoint formats vary by region
    if [ "$REGION" == "us-east-1" ]; then
        endpoint="http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"
    else
        endpoint="http://$BUCKET_NAME.s3-website.$REGION.amazonaws.com"
    fi

    echo "Endpoint: $endpoint" >&2
    # Output the endpoint URL to stdout
    echo "$endpoint"
else
    echo "Error enabling website hosting." >&2
    echo "AWS CLI Error: $aws_output" >&2
    exit 1
fi
