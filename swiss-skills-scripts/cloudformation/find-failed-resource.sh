#!/bin/bash

# Script to find the most recent failure event in a CloudFormation stack.
# Usage: ./find-failed-resource.sh <STACK_NAME>
# Example: ./find-failed-resource.sh MyWebAppStack

# --- Color Definitions ---
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- Argument Parsing ---
if [ -z "$1" ]; then
  echo -e "${RED}Error: No stack name provided.${NC}"
  echo "Usage: $0 <STACK_NAME>"
  exit 1
fi
STACK_NAME=$1

echo -e "${YELLOW}--- Analyzing Failures for Stack: $STACK_NAME ---${NC}"

# Get all stack events and find the first one that is a CREATE_FAILED or UPDATE_FAILED
FAILURE_EVENT_JSON=$(aws cloudformation describe-stack-events --stack-name "$STACK_NAME" \
    --query 'StackEvents[?ResourceStatus==`CREATE_FAILED` || ResourceStatus==`UPDATE_FAILED`]|[0]' 2>/dev/null)

if [ -z "$FAILURE_EVENT_JSON" ] || [ "$FAILURE_EVENT_JSON" == "null" ]; then
    echo "No CREATE_FAILED or UPDATE_FAILED events found for this stack."
    exit 0
fi

# Extract and display the details
LOGICAL_ID=$(echo "$FAILURE_EVENT_JSON" | jq -r '.LogicalResourceId')
RESOURCE_TYPE=$(echo "$FAILURE_EVENT_JSON" | jq -r '.ResourceType')
STATUS_REASON=$(echo "$FAILURE_EVENT_JSON" | jq -r '.ResourceStatusReason')

echo -e "${RED}Found a failure event!${NC}"
echo "-------------------------------------"
echo "Logical Resource ID: $LOGICAL_ID"
echo "Resource Type:       $RESOURCE_TYPE"
echo "Reason for Failure:  $STATUS_REASON"
echo "-------------------------------------"
