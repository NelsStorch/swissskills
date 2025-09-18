#!/bin/bash

# Script to get key details for a specific AWS EC2 instance.
# Usage: ./get-instance-details.sh --instance-id <INSTANCE_ID>
# Example: ./get-instance-details.sh --instance-id i-0123456789abcdef0

# --- Argument Parsing ---
INSTANCE_ID=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --instance-id)
            INSTANCE_ID="$2"
            shift
            ;;
        *)
            echo "Unknown parameter passed: $1" >&2
            exit 1
            ;;
    esac
    shift
done

# Check if an instance ID was provided
if [ -z "$INSTANCE_ID" ]; then
  echo "Error: The --instance-id flag is required." >&2
  echo "Usage: $0 --instance-id <INSTANCE_ID>" >&2
  exit 1
fi

# --- Main Logic ---
echo "Fetching details for instance: $INSTANCE_ID..." >&2

# Get instance details and capture output and errors
aws_output=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].{InstanceId:InstanceId, InstanceType:InstanceType, State:State.Name, PublicIpAddress:PublicIpAddress, PrivateIpAddress:PrivateIpAddress, KeyName:KeyName, SubnetId:SubnetId, VpcId:VpcId, SecurityGroups:SecurityGroups}' \
    --output json 2>&1)

# Check if the AWS CLI command was successful
if [ $? -ne 0 ]; then
    echo "Error fetching details for instance '$INSTANCE_ID'." >&2
    echo "AWS CLI Error: $aws_output" >&2
    exit 1
fi

# Print the successful JSON output to stdout
echo "$aws_output"
