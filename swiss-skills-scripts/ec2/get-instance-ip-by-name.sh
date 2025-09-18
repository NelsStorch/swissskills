#!/bin/bash

# Script to get the public IP address of a running EC2 instance by its Name tag.
# Outputs the public IP address(es) to stdout.
# Usage: ./get-instance-ip-by-name.sh --name <INSTANCE_NAME_TAG>
# Example: ./get-instance-ip-by-name.sh --name MyWebServer01

# --- Argument Parsing ---
INSTANCE_NAME=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --name)
            INSTANCE_NAME="$2"
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
if [ -z "$INSTANCE_NAME" ]; then
  echo "Error: The --name flag is required." >&2
  echo "Usage: $0 --name <INSTANCE_NAME_TAG>" >&2
  exit 1
fi

# --- Main Logic ---
echo "Searching for running instance with Name tag: $INSTANCE_NAME..." >&2

PUBLIC_IP=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$INSTANCE_NAME" "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].PublicIpAddress' \
    --output text 2>&1)

# Check for errors from AWS CLI
if [ $? -ne 0 ]; then
    echo "Error searching for instance '$INSTANCE_NAME'." >&2
    echo "AWS CLI Error: $PUBLIC_IP" >&2
    exit 1
fi

if [ -z "$PUBLIC_IP" ]; then
    echo "No running instance found with the Name tag '$INSTANCE_NAME'." >&2
    exit 1
fi

# Check if multiple IPs were returned (could happen if multiple instances have the same name)
IP_COUNT=$(echo "$PUBLIC_IP" | wc -w)
if [ "$IP_COUNT" -gt 1 ]; then
    echo "Warning: Multiple running instances found with that name. Returning all IPs." >&2
fi

# Output the IP(s) to stdout
echo "$PUBLIC_IP"
