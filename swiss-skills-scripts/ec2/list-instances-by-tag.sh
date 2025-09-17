#!/bin/bash

# Script to list running EC2 instances matching a specific tag.
# Usage: ./list-instances-by-tag.sh --tag-key <KEY> --tag-value <VALUE>
# Example: ./list-instances-by-tag.sh --tag-key Environment --tag-value Production

# Initialize variables
TAG_KEY=""
TAG_VALUE=""

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --tag-key) TAG_KEY="$2"; shift ;;
        --tag-value) TAG_VALUE="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Validate arguments
if [ -z "$TAG_KEY" ] || [ -z "$TAG_VALUE" ]; then
  echo "Error: Both tag key and tag value are required."
  echo "Usage: $0 --tag-key <KEY> --tag-value <VALUE>"
  exit 1
fi

echo "Searching for running instances with tag '$TAG_KEY=$TAG_VALUE'..."

aws ec2 describe-instances \
    --filters "Name=tag:$TAG_KEY,Values=$TAG_VALUE" "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].{ID:InstanceId, Type:InstanceType, IP:PublicIpAddress, Key:KeyName, Name:Tags[?Key==`Name`].Value | [0]}' \
    --output table

if [ $? -ne 0 ]; then
    echo "An error occurred while fetching instances."
    exit 1
fi

echo "Script finished."
