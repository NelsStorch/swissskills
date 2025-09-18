#!/bin/bash

# Script to display the details of security groups attached to an EC2 instance.
# Outputs the security group details in JSON format.
# Usage: ./get-instance-security-groups.sh --instance-id <INSTANCE_ID>
# Example: ./get-instance-security-groups.sh --instance-id i-0123456789abcdef0

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

# Validate arguments
if [ -z "$INSTANCE_ID" ]; then
  echo "Error: The --instance-id flag is required." >&2
  echo "Usage: $0 --instance-id <INSTANCE_ID>" >&2
  exit 1
fi

# --- Main Logic ---
echo "Fetching security groups for instance: $INSTANCE_ID..." >&2

# First, get the list of security group IDs from the instance
sg_ids_output=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[*].Instances[*].SecurityGroups[*].GroupId' \
    --output text 2>&1)

if [ $? -ne 0 ]; then
    echo "Error fetching instance details for '$INSTANCE_ID'." >&2
    echo "AWS CLI Error: $sg_ids_output" >&2
    exit 1
fi

if [ -z "$sg_ids_output" ]; then
    echo "No security groups found for this instance or instance not found." >&2
    exit 1
fi

echo "Found Security Group IDs: $sg_ids_output" >&2
echo "---" >&2

# Now, describe each security group in detail and send to stdout
aws_output=$(aws ec2 describe-security-groups \
    --group-ids $sg_ids_output \
    --query 'SecurityGroups[*].{ID:GroupId, Name:GroupName, IngressRules:IpPermissions}' \
    --output json 2>&1)

if [ $? -ne 0 ]; then
    echo "An error occurred while fetching security group details." >&2
    echo "AWS CLI Error: $aws_output" >&2
    exit 1
fi

echo "$aws_output"
