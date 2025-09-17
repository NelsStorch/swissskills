#!/bin/bash

# Script to get detailed information about an AWS VPC and its components.
# Usage: ./get-vpc-info.sh <VPC_ID>
# Example: ./get-vpc-info.sh vpc-0123456789abcdef0

# Check if a VPC ID was provided
if [ -z "$1" ]; then
  echo "Error: No VPC ID provided."
  echo "Usage: $0 <VPC_ID>"
  exit 1
fi

VPC_ID=$1

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
