#!/bin/bash

# Script to create a new AWS VPC.
# Usage: ./create-vpc.sh <CIDR_BLOCK> [NAME_TAG]
# Example: ./create-vpc.sh 10.0.0.0/16 MyNewVPC

# Check if a CIDR block was provided
if [ -z "$1" ]; then
  echo "Error: No CIDR block provided."
  echo "Usage: $0 <CIDR_BLOCK>"
  exit 1
fi

CIDR_BLOCK=$1
TAG_NAME="${2:-MyVPC}" # Optional second argument for a Name tag, defaults to "MyVPC"

# Create the VPC and capture the VPC ID
echo "Creating VPC with CIDR block: $CIDR_BLOCK and Name tag: $TAG_NAME..."
VPC_ID=$(aws ec2 create-vpc --cidr-block "$CIDR_BLOCK" --query 'Vpc.VpcId' --output text)

# Check if the VPC was created successfully
if [ -z "$VPC_ID" ]; then
    echo "Error: VPC creation failed."
    exit 1
fi

echo "VPC created successfully with ID: $VPC_ID"

# Add a Name tag to the VPC
echo "Adding Name tag to VPC..."
aws ec2 create-tags --resources "$VPC_ID" --tags "Key=Name,Value=$TAG_NAME"

echo "Script finished."
