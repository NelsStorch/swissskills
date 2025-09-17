#!/bin/bash

# Script to get key details for a specific AWS EC2 instance.
# Usage: ./get-instance-details.sh <INSTANCE_ID>
# Example: ./get-instance-details.sh i-0123456789abcdef0

# Check if an instance ID was provided
if [ -z "$1" ]; then
  echo "Error: No instance ID provided."
  echo "Usage: $0 <INSTANCE_ID>"
  exit 1
fi

INSTANCE_ID=$1

# Get instance details
echo "Fetching details for instance: $INSTANCE_ID..."
aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].{InstanceId:InstanceId, InstanceType:InstanceType, State:State.Name, PublicIpAddress:PublicIpAddress, PrivateIpAddress:PrivateIpAddress, KeyName:KeyName, SubnetId:SubnetId, VpcId:VpcId, SecurityGroups:SecurityGroups}' \
    --output json

if [ $? -ne 0 ]; then
    echo "Error fetching details. Make sure the instance ID is correct and you have the necessary permissions."
    exit 1
fi

echo "Script finished."
