#!/bin/bash

# Script to create a new AWS VPC.
# Outputs the new VPC ID on success.
# Usage: ./create-vpc.sh --cidr <CIDR_BLOCK> [--name <NAME_TAG>]
# Example: ./create-vpc.sh --cidr 10.0.0.0/16 --name MyNewVPC

# --- Argument Parsing ---
CIDR_BLOCK=""
TAG_NAME="MyVPC" # Default name

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --cidr)
            CIDR_BLOCK="$2"
            shift
            ;;
        --name)
            TAG_NAME="$2"
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
if [ -z "$CIDR_BLOCK" ]; then
  echo "Error: The --cidr flag is required." >&2
  echo "Usage: $0 --cidr <CIDR_BLOCK> [--name <NAME_TAG>]" >&2
  exit 1
fi

# --- Main Logic ---
echo "Creating VPC with CIDR block: $CIDR_BLOCK and Name tag: $TAG_NAME..." >&2
VPC_ID=$(aws ec2 create-vpc --cidr-block "$CIDR_BLOCK" --query 'Vpc.VpcId' --output text 2>&1)

# Check if the VPC was created successfully
if [ $? -ne 0 ]; then
    echo "Error: VPC creation failed." >&2
    echo "AWS CLI Error: $VPC_ID" >&2
    exit 1
fi

echo "VPC created successfully with ID: $VPC_ID" >&2

# Add a Name tag to the VPC
echo "Adding Name tag to VPC..." >&2
aws ec2 create-tags --resources "$VPC_ID" --tags "Key=Name,Value=$TAG_NAME" > /dev/null

# Output the VPC ID to stdout
echo "$VPC_ID"
