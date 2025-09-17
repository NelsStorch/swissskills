#!/bin/bash

# Script to show the route table associated with a specific subnet.
# Usage: ./get-subnet-route-table.sh <SUBNET_ID>
# Example: ./get-subnet-route-table.sh subnet-0123456789abcdef0

# Check if a subnet ID was provided
if [ -z "$1" ]; then
  echo "Error: No subnet ID provided."
  echo "Usage: $0 <SUBNET_ID>"
  exit 1
fi

SUBNET_ID=$1

echo "Fetching route table for subnet: $SUBNET_ID..."

# Describe the route tables, filtering by the association with the subnet ID
aws ec2 describe-route-tables \
    --filters "Name=association.subnet-id,Values=$SUBNET_ID" \
    --query 'RouteTables[*].{ID:RouteTableId, Routes:Routes, Associations:Associations}' \
    --output json

if [ $? -ne 0 ]; then
    echo "An error occurred while fetching the route table. Check the subnet ID."
    exit 1
fi

echo "Script finished."
