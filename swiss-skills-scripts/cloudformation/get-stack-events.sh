#!/bin/bash

# Script to get the event history for a CloudFormation stack.
# Very useful for debugging failed stack creations or updates.
# Usage: ./get-stack-events.sh <STACK_NAME>
# Example: ./get-stack-events.sh MyWebAppStack

# Check if a stack name was provided
if [ -z "$1" ]; then
  echo "Error: No stack name provided."
  echo "Usage: $0 <STACK_NAME>"
  exit 1
fi

STACK_NAME=$1

echo "Fetching events for stack '$STACK_NAME'..."

aws cloudformation describe-stack-events \
    --stack-name "$STACK_NAME" \
    --query 'StackEvents[*].{Timestamp:Timestamp, Resource:LogicalResourceId, Type:ResourceType, Status:ResourceStatus, Reason:ResourceStatusReason}' \
    --output table

if [ $? -ne 0 ]; then
    echo "An error occurred while fetching stack events. Check the stack name."
    exit 1
fi

echo "Script finished."
