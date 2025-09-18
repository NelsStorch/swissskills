#!/bin/bash

# Script to find any AWS resources matching a specific tag.
# Outputs a list of resource ARNs to stdout.
# Usage: ./find-resources-by-tag.sh --tag-key <KEY> --tag-value <VALUE>
# Example: ./find-resources-by-tag.sh --tag-key Project --tag-value Phoenix

# --- Argument Parsing ---
TAG_KEY=""
TAG_VALUE=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --tag-key)
            TAG_KEY="$2"
            shift
            ;;
        --tag-value)
            TAG_VALUE="$2"
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
if [ -z "$TAG_KEY" ] || [ -z "$TAG_VALUE" ]; then
  echo "Error: Both --tag-key and --tag-value are required." >&2
  echo "Usage: $0 --tag-key <KEY> --tag-value <VALUE>" >&2
  exit 1
fi

# --- Main Logic ---
echo "Searching for all resources with tag '$TAG_KEY=$TAG_VALUE'..." >&2

aws_output=$(aws resourcegroupstaggingapi get-resources \
    --tag-filters "Key=$TAG_KEY,Values=$TAG_VALUE" \
    --query 'ResourceTagMappingList[*].ResourceARN' \
    --output text 2>&1)

if [ $? -ne 0 ]; then
    echo "An error occurred while searching for resources." >&2
    echo "AWS CLI Error: $aws_output" >&2
    exit 1
fi

# Print the list of ARNs to stdout
echo "$aws_output"

echo "Search complete." >&2
