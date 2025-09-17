#!/bin/bash

# Script to create a new AWS S3 bucket.
# Usage: ./create-s3-bucket.sh <BUCKET_NAME> [AWS_REGION]
# Example: ./create-s3-bucket.sh my-unique-competition-bucket us-east-1

# Check if a bucket name was provided
if [ -z "$1" ]; then
  echo "Error: No bucket name provided."
  echo "Usage: $0 <BUCKET_NAME> [AWS_REGION]"
  exit 1
fi

BUCKET_NAME=$1
AWS_REGION=${2:-us-east-1} # Default to us-east-1 if no region is provided

# Create the S3 bucket
echo "Creating S3 bucket named '$BUCKET_NAME' in region '$AWS_REGION'..."

# S3 buckets in us-east-1 don't need a location constraint.
if [ "$AWS_REGION" == "us-east-1" ]; then
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION"
else
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"
fi

if [ $? -eq 0 ]; then
  echo "S3 bucket '$BUCKET_NAME' created successfully."
else
  echo "Error creating S3 bucket. Bucket names must be globally unique."
  exit 1
fi

echo "Script finished."
