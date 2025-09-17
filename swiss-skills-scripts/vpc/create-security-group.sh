#!/bin/bash

# Script to create a new AWS Security Group and add ingress rules interactively.
# Usage: ./create-security-group.sh --group-name <NAME> --description "<DESCRIPTION>" --vpc-id <VPC_ID>
# Example: ./create-security-group.sh --group-name MyWebServerSG --description "SG for web servers" --vpc-id vpc-12345678

# Initialize variables
GROUP_NAME=""
DESCRIPTION=""
VPC_ID=""

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --group-name) GROUP_NAME="$2"; shift ;;
        --description) DESCRIPTION="$2"; shift ;;
        --vpc-id) VPC_ID="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Validate arguments
if [ -z "$GROUP_NAME" ] || [ -z "$DESCRIPTION" ] || [ -z "$VPC_ID" ]; then
  echo "Error: All arguments are required."
  echo "Usage: $0 --group-name <NAME> --description <DESCRIPTION> --vpc-id <VPC_ID>"
  exit 1
fi

# Create the security group
echo "Creating security group '$GROUP_NAME' in VPC '$VPC_ID'..."
GROUP_ID=$(aws ec2 create-security-group --group-name "$GROUP_NAME" --description "$DESCRIPTION" --vpc-id "$VPC_ID" --query 'GroupId' --output text)

if [ $? -ne 0 ]; then
    echo "Error creating security group. Please check the details."
    exit 1
fi

echo "Security Group created successfully with ID: $GROUP_ID"

# Loop to add ingress rules
while true; do
    read -p "Add an ingress rule? (y/n): " choice
    if [[ "$choice" != "y" ]]; then
        break
    fi

    read -p "Enter protocol (e.g., tcp, udp, icmp): " protocol
    read -p "Enter port (e.g., 22, 80, 443): " port
    read -p "Enter CIDR block (e.g., 0.0.0.0/0): " cidr

    echo "Adding rule: Protocol=$protocol, Port=$port, CIDR=$cidr..."
    aws ec2 authorize-security-group-ingress --group-id "$GROUP_ID" --protocol "$protocol" --port "$port" --cidr "$cidr"

    if [ $? -eq 0 ]; then
        echo "Rule added successfully."
    else
        echo "Error adding rule."
    fi
done

echo "Script finished."
