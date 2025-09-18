#!/bin/bash

# Script to create a new AWS S3 bucket.
# Outputs the bucket name on success.
# Usage: ./create-s3-bucket.sh --bucket-name <BUCKET_NAME> [--region <AWS_REGION>]
# Example: ./create-s3-bucket.sh --bucket-name my-unique-bucket --region us-east-1

# --- Argument Parsing ---
BUCKET_NAME=""
AWS_REGION="us-east-1" # Default region

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --bucket-name)
            BUCKET_NAME="$2"
            shift
            ;;
        --region)
            AWS_REGION="$2"
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
  echo "Usage: $0 --bucket-name <BUCKET_NAME> [--region <AWS_REGION>]" >&2
  exit 1
fi

# --- Main Logic ---
echo "Creating S3 bucket named '$BUCKET_NAME' in region '$AWS_REGION'..." >&2

# S3 buckets in us-east-1 don't need a location constraint.
if [ "$AWS_REGION" == "us-east-1" ]; then
    aws_output=$(aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" 2>&1)
else
    aws_output=$(aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION" 2>&1)
fi

if [ $? -eq 0 ]; then
  echo "S3 bucket '$BUCKET_NAME' created successfully." >&2
  # Output the bucket name to stdout
  echo "$BUCKET_NAME"
else
  echo "Error creating S3 bucket '$BUCKET_NAME'." >&2
  echo "AWS CLI Error: $aws_output" >&2
  exit 1
fi
