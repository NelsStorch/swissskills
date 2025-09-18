#!/bin/bash

# Script to show the route table associated with a specific subnet.
# Outputs the route table details in JSON format.
# Usage: ./get-subnet-route-table.sh --subnet-id <SUBNET_ID>
# Example: ./get-subnet-route-table.sh --subnet-id subnet-0123456789abcdef0

# --- Argument Parsing ---
SUBNET_ID=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --subnet-id)
            SUBNET_ID="$2"
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
if [ -z "$SUBNET_ID" ]; then
  echo "Error: The --subnet-id flag is required." >&2
  echo "Usage: $0 --subnet-id <SUBNET_ID>" >&2
  exit 1
fi

# --- Main Logic ---
echo "Fetching route table for subnet: $SUBNET_ID..." >&2

aws_output=$(aws ec2 describe-route-tables \
    --filters "Name=association.subnet-id,Values=$SUBNET_ID" \
    --query 'RouteTables[*].{ID:RouteTableId, Routes:Routes, Associations:Associations}' \
    --output json 2>&1)

if [ $? -ne 0 ]; then
    echo "An error occurred while fetching the route table. Check the subnet ID." >&2
    echo "AWS CLI Error: $aws_output" >&2
    exit 1
fi

# Print the JSON output to stdout
echo "$aws_output"
