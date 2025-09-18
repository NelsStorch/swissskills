#!/bin/bash

# Script to find the most recent failure event in a CloudFormation stack.
# Outputs the JSON of the first failed event found.
# Usage: ./find-failed-resource.sh --stack-name <STACK_NAME>
# Example: ./find-failed-resource.sh --stack-name MyWebAppStack

# --- Color Definitions ---
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- Argument Parsing ---
STACK_NAME=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --stack-name)
            STACK_NAME="$2"
            shift
            ;;
        *)
            echo -e "${RED}Unknown parameter passed: $1${NC}" >&2
            exit 1
            ;;
    esac
    shift
done

if [ -z "$STACK_NAME" ]; then
  echo -e "${RED}Error: --stack-name flag is required.${NC}" >&2
  echo "Usage: $0 --stack-name <STACK_NAME>" >&2
  exit 1
fi

# --- Main Logic ---
echo -e "${YELLOW}--- Analyzing Failures for Stack: $STACK_NAME ---${NC}" >&2

# Get all stack events and find the first one that is a CREATE_FAILED or UPDATE_FAILED
FAILURE_EVENT_JSON=$(aws cloudformation describe-stack-events --stack-name "$STACK_NAME" \
    --query 'StackEvents[?ResourceStatus==`CREATE_FAILED` || ResourceStatus==`UPDATE_FAILED`]|[0]' --output json 2>&1)

if [ $? -ne 0 ]; then
    echo -e "${RED}Error describing stack events. Check the stack name.${NC}" >&2
    echo "AWS CLI Error: $FAILURE_EVENT_JSON" >&2
    exit 1
fi

if [ -z "$FAILURE_EVENT_JSON" ] || [ "$FAILURE_EVENT_JSON" == "null" ]; then
    echo "No CREATE_FAILED or UPDATE_FAILED events found for this stack." >&2
    exit 0
fi

# Output the found JSON event to stdout
echo "$FAILURE_EVENT_JSON"

# Also print a summary to stderr for the user
{
    echo -e "\n${RED}Found a failure event!${NC}"
    echo "-------------------------------------"
    echo "$FAILURE_EVENT_JSON" | jq -r '"Logical Resource ID: \(.LogicalResourceId)\nResource Type:       \(.ResourceType)\nReason for Failure:  \(.ResourceStatusReason)"'
    echo "-------------------------------------"
} >&2
