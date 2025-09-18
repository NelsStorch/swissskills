#!/bin/bash

# Script to filter log events from a CloudWatch Log Group.
# Outputs the filtered log messages to stdout.
# Usage: ./filter-logs.sh --log-group-name <NAME> --filter-pattern "<PATTERN>"
# Example: ./filter-logs.sh --log-group-name /aws/lambda/my-function --filter-pattern "ERROR"
# Example: ./filter-logs.sh --log-group-name /aws/lambda/my-function --filter-pattern '{$.level = "error"}'

# --- Argument Parsing ---
LOG_GROUP_NAME=""
FILTER_PATTERN=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --log-group-name)
            LOG_GROUP_NAME="$2"
            shift
            ;;
        --filter-pattern)
            FILTER_PATTERN="$2"
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
if [ -z "$LOG_GROUP_NAME" ] || [ -z "$FILTER_PATTERN" ]; then
  echo "Error: Both --log-group-name and --filter-pattern are required." >&2
  echo "Usage: $0 --log-group-name <NAME> --filter-pattern \"<PATTERN>\"" >&2
  exit 1
fi

# --- Main Logic ---
echo "Filtering events from '$LOG_GROUP_NAME' with pattern: '$FILTER_PATTERN'..." >&2

aws_output=$(aws logs filter-log-events \
    --log-group-name "$LOG_GROUP_NAME" \
    --filter-pattern "$FILTER_PATTERN" \
    --query 'events[*].message' \
    --output text 2>&1)

if [ $? -ne 0 ]; then
    echo "An error occurred while filtering log events." >&2
    echo "AWS CLI Error: $aws_output" >&2
    exit 1
fi

# Print the filtered logs to stdout
echo "$aws_output"

echo "Filtering complete." >&2
