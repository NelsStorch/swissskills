#!/bin/bash

# Script to find any AWS resources matching a specific tag.
# Usage: ./find-resources-by-tag.sh --tag-key <KEY> --tag-value <VALUE>
# Example: ./find-resources-by-tag.sh --tag-key Project --tag-value Phoenix

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

echo "Searching for all resources with tag '$TAG_KEY=$TAG_VALUE'..."

aws resourcegroupstaggingapi get-resources \
    --tag-filters "Key=$TAG_KEY,Values=$TAG_VALUE" \
    --query 'ResourceTagMappingList[*].ResourceARN' \
    --output table

if [ $? -ne 0 ]; then
    echo "An error occurred while searching for resources."
    exit 1
fi

echo "Script finished."
