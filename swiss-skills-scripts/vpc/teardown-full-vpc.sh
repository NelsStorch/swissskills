#!/bin/bash

# Script to tear down the resources created by create-full-vpc.sh.
# Requires the IDs of the created resources.
# Usage: ./teardown-full-vpc.sh --vpc-id <VPC_ID> --public-subnet-id <ID> --private-subnet-id <ID> \
#   --igw-id <ID> --nat-gw-id <ID> --public-rt-id <ID> --private-rt-id <ID>

# --- Helper function for logging ---
log() {
    echo "[INFO] $1"
}

# --- Argument Parsing ---
VPC_ID=""
PUBLIC_SUBNET_ID=""
PRIVATE_SUBNET_ID=""
IGW_ID=""
NAT_GW_ID=""
PUBLIC_RT_ID=""
PRIVATE_RT_ID=""

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --vpc-id) VPC_ID="$2"; shift; shift ;;
        --public-subnet-id) PUBLIC_SUBNET_ID="$2"; shift; shift ;;
        --private-subnet-id) PRIVATE_SUBNET_ID="$2"; shift; shift ;;
        --igw-id) IGW_ID="$2"; shift; shift ;;
        --nat-gw-id) NAT_GW_ID="$2"; shift; shift ;;
        --public-rt-id) PUBLIC_RT_ID="$2"; shift; shift ;;
        --private-rt-id) PRIVATE_RT_ID="$2"; shift; shift ;;
        *) echo "Unknown param: $1"; exit 1 ;;
    esac
done

# --- Deletion Logic ---
# Order is important!

# 1. Delete NAT Gateway
if [ -n "$NAT_GW_ID" ]; then
    log "Deleting NAT Gateway: $NAT_GW_ID... (This can take a few minutes)"
    aws ec2 delete-nat-gateway --nat-gateway-id "$NAT_GW_ID"
    aws ec2 wait nat-gateway-deleted --nat-gateway-ids "$NAT_GW_ID"
    log "NAT Gateway deleted. Please release its Elastic IP manually if the create script allocated one."
fi

# 2. Detach and Delete Internet Gateway
if [ -n "$IGW_ID" ] && [ -n "$VPC_ID" ]; then
    log "Detaching Internet Gateway: $IGW_ID from VPC: $VPC_ID"
    aws ec2 detach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID"
    log "Deleting Internet Gateway: $IGW_ID"
    aws ec2 delete-internet-gateway --internet-gateway-id "$IGW_ID"
fi

# 3. Delete Subnets
if [ -n "$PUBLIC_SUBNET_ID" ]; then
    log "Deleting Public Subnet: $PUBLIC_SUBNET_ID"
    aws ec2 delete-subnet --subnet-id "$PUBLIC_SUBNET_ID"
fi
if [ -n "$PRIVATE_SUBNET_ID" ]; then
    log "Deleting Private Subnet: $PRIVATE_SUBNET_ID"
    aws ec2 delete-subnet --subnet-id "$PRIVATE_SUBNET_ID"
fi

# 4. Delete custom Route Tables
# This should happen after subnets are gone, as deleting subnets automatically disassociates route tables.
if [ -n "$PUBLIC_RT_ID" ]; then
    log "Deleting Public Route Table: $PUBLIC_RT_ID"
    aws ec2 delete-route-table --route-table-id "$PUBLIC_RT_ID"
fi
if [ -n "$PRIVATE_RT_ID" ]; then
    log "Deleting Private Route Table: $PRIVATE_RT_ID"
    aws ec2 delete-route-table --route-table-id "$PRIVATE_RT_ID"
fi

# 5. Delete the VPC
if [ -n "$VPC_ID" ]; then
    log "Deleting VPC: $VPC_ID"
    aws ec2 delete-vpc --vpc-id "$VPC_ID"
fi

log "Teardown script finished."
