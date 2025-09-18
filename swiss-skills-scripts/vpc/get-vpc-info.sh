#!/bin/bash

# Script to get detailed information about an AWS VPC and its components.
# All output is sent to stderr as this is a diagnostic script.
# Usage: ./get-vpc-info.sh --vpc-id <VPC_ID>
# Example: ./get-vpc-info.sh --vpc-id vpc-0123456789abcdef0

# --- Argument Parsing ---
VPC_ID=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --vpc-id)
            VPC_ID="$2"
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
if [ -z "$VPC_ID" ]; then
  echo "Error: The --vpc-id flag is required." >&2
  echo "Usage: $0 --vpc-id <VPC_ID>" >&2
  exit 1
fi

# --- Main Logic (all output to stderr) ---
{
    echo "Fetching details for VPC: $VPC_ID..."

    echo "--- VPC Details ---"
    aws ec2 describe-vpcs --vpc-ids "$VPC_ID" --output table

    echo -e "\n--- Subnets ---"
    aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].{ID:SubnetId, CIDR:CidrBlock, AZ:AvailabilityZone, Public:MapPublicIpOnLaunch}' --output table

    echo -e "\n--- Route Tables ---"
    aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query 'RouteTables[*].{ID:RouteTableId, Main:Associations[?Main].Main, Routes:Routes}' --output json

    echo -e "\n--- Security Groups ---"
    aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query 'SecurityGroups[*].{ID:GroupId, Name:GroupName, Description:Description}' --output table

    echo "Script finished."
} >&2
