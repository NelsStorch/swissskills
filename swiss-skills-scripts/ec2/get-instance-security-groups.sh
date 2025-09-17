#!/bin/bash

# Script to display the details of security groups attached to an EC2 instance.
# Usage: ./get-instance-security-groups.sh <INSTANCE_ID>
# Example: ./get-instance-security-groups.sh i-0123456789abcdef0

# Check if an instance ID was provided
if [ -z "$1" ]; then
  echo "Error: No instance ID provided."
  echo "Usage: $0 <INSTANCE_ID>"
  exit 1
fi

INSTANCE_ID=$1

echo "Fetching security groups for instance: $INSTANCE_ID..."

# First, get the list of security group IDs from the instance
SG_IDS=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[*].Instances[*].SecurityGroups[*].GroupId' \
    --output text)

if [ -z "$SG_IDS" ]; then
    echo "No security groups found for this instance or instance not found."
    exit 1
fi

echo "Found Security Group IDs: $SG_IDS"
echo "---"

# Now, describe each security group in detail
aws ec2 describe-security-groups \
    --group-ids $SG_IDS \
    --query 'SecurityGroups[*].{ID:GroupId, Name:GroupName, IngressRules:IpPermissions}' \
    --output json

if [ $? -ne 0 ]; then
    echo "An error occurred while fetching security group details."
    exit 1
fi

echo "Script finished."
