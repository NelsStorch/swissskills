#!/bin/bash

# Script to get the public IP address of a running EC2 instance by its Name tag.
# Usage: ./get-instance-ip-by-name.sh <INSTANCE_NAME_TAG>
# Example: ./get-instance-ip-by-name.sh MyWebServer01

# Check if an instance name was provided
if [ -z "$1" ]; then
  echo "Error: No instance name tag provided."
  echo "Usage: $0 <INSTANCE_NAME_TAG>"
  exit 1
fi

INSTANCE_NAME=$1

echo "Searching for running instance with Name tag: $INSTANCE_NAME..."

PUBLIC_IP=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$INSTANCE_NAME" "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].PublicIpAddress' \
    --output text)

if [ -z "$PUBLIC_IP" ]; then
    echo "No running instance found with the Name tag '$INSTANCE_NAME'."
    exit 1
fi

# Check if multiple IPs were returned (could happen if multiple instances have the same name)
IP_COUNT=$(echo "$PUBLIC_IP" | wc -w)
if [ "$IP_COUNT" -gt 1 ]; then
    echo "Warning: Multiple running instances found with that name. Returning all IPs:"
    echo "$PUBLIC_IP"
else
    echo "Instance IP: $PUBLIC_IP"
fi

echo "Script finished."
