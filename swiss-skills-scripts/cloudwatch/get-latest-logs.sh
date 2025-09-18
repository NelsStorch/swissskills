#!/bin/bash

# Script to get the latest log events from a CloudWatch Log Group.
# Outputs the latest log messages to stdout.
# Usage: ./get-latest-logs.sh --log-group-name <LOG_GROUP_NAME> [--limit <NUMBER>]
# Example: ./get-latest-logs.sh --log-group-name /aws/lambda/my-function --limit 5

# --- Argument Parsing ---
LOG_GROUP_NAME=""
LIMIT=10 # Default limit

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --log-group-name)
            LOG_GROUP_NAME="$2"
            shift
            ;;
        --limit)
            LIMIT="$2"
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
if [ -z "$LOG_GROUP_NAME" ]; then
  echo "Error: --log-group-name is required." >&2
  echo "Usage: $0 --log-group-name <LOG_GROUP_NAME> [--limit <NUMBER>]" >&2
  exit 1
fi

# --- Main Logic ---
echo "Fetching latest $LIMIT log events from '$LOG_GROUP_NAME'..." >&2

# Get the latest log stream
latest_stream_name=$(aws logs describe-log-streams --log-group-name "$LOG_GROUP_NAME" --order-by LastEventTime --descending --limit 1 --query 'logStreams[0].logStreamName' --output text 2>&1)

if [ $? -ne 0 ]; then
    echo "Error describing log streams." >&2
    echo "AWS CLI Error: $latest_stream_name" >&2
    exit 1
fi

if [ -z "$latest_stream_name" ] || [ "$latest_stream_name" == "None" ]; then
    echo "No log streams found for this log group." >&2
    exit 1
fi

echo "Reading from latest stream: $latest_stream_name" >&2

# Get the log events
log_events=$(aws logs get-log-events \
    --log-group-name "$LOG_GROUP_NAME" \
    --log-stream-name "$latest_stream_name" \
    --limit "$LIMIT" \
    --query 'events[*].message' \
    --output text 2>&1)

if [ $? -ne 0 ]; then
    echo "An error occurred while fetching log events." >&2
    echo "AWS CLI Error: $log_events" >&2
    exit 1
fi

# Print the log events to stdout
echo "$log_events"
