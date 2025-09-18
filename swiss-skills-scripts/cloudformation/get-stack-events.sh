#!/bin/bash

# Script to get the event history for a CloudFormation stack.
# Outputs a table of stack events to stdout.
# Usage: ./get-stack-events.sh --stack-name <STACK_NAME>
# Example: ./get-stack-events.sh --stack-name MyWebAppStack

# --- Argument Parsing ---
STACK_NAME=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --stack-name)
            STACK_NAME="$2"
            shift
            ;;
        *)
            echo "Unknown parameter passed: $1" >&2
            exit 1
            ;;
    esac
    shift
done

if [ -z "$STACK_NAME" ]; then
  echo "Error: The --stack-name flag is required." >&2
  echo "Usage: $0 --stack-name <STACK_NAME>" >&2
  exit 1
fi

# --- Main Logic ---
echo "Fetching events for stack '$STACK_NAME'..." >&2

aws_output=$(aws cloudformation describe-stack-events \
    --stack-name "$STACK_NAME" \
    --query 'StackEvents[*].{Timestamp:Timestamp, Resource:LogicalResourceId, Type:ResourceType, Status:ResourceStatus, Reason:ResourceStatusReason}' \
    --output table 2>&1)

if [ $? -ne 0 ]; then
    echo "An error occurred while fetching stack events. Check the stack name." >&2
    echo "AWS CLI Error: $aws_output" >&2
    exit 1
fi

# Print the table to stdout
echo "$aws_output"

echo "Script finished." >&2
