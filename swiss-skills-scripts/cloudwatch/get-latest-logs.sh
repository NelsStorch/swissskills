#!/bin/bash

# Script to get the latest log events from a CloudWatch Log Group.
# Usage: ./get-latest-logs.sh --log-group-name <LOG_GROUP_NAME> [--limit <NUMBER>]
# Example: ./get-latest-logs.sh --log-group-name /aws/lambda/my-function --limit 5

# Initialize variables
LOG_GROUP_NAME=""
LIMIT=10 # Default limit

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --log-group-name) LOG_GROUP_NAME="$2"; shift ;;
        --limit) LIMIT="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Validate arguments
if [ -z "$LOG_GROUP_NAME" ]; then
  echo "Error: Log group name is required."
  echo "Usage: $0 --log-group-name <LOG_GROUP_NAME> [--limit <NUMBER>]"
  exit 1
fi

echo "Fetching latest $LIMIT log events from '$LOG_GROUP_NAME'..."

# Get the latest log stream
LATEST_STREAM=$(aws logs describe-log-streams --log-group-name "$LOG_GROUP_NAME" --order-by LastEventTime --descending --limit 1 --query 'logStreams[0].logStreamName' --output text)

if [ -z "$LATEST_STREAM" ] || [ "$LATEST_STREAM" == "None" ]; then
    echo "No log streams found for this log group."
    exit 1
fi

echo "Reading from latest stream: $LATEST_STREAM"

# Get the log events
aws logs get-log-events \
    --log-group-name "$LOG_GROUP_NAME" \
    --log-stream-name "$LATEST_STREAM" \
    --limit "$LIMIT" \
    --query 'events[*].message' \
    --output text

if [ $? -ne 0 ]; then
    echo "An error occurred while fetching log events."
    exit 1
fi

echo "Script finished."
