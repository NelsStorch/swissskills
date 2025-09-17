#!/bin/bash

# Script to create a full VPC with a public subnet, a private subnet,
# an Internet Gateway, a NAT Gateway, and configured route tables.
# Usage: ./create-full-vpc.sh --vpc-cidr <CIDR> --public-subnet-cidr <CIDR> --private-subnet-cidr <CIDR> --name-prefix <PREFIX>
# Example: ./create-full-vpc.sh --vpc-cidr 10.0.0.0/16 --public-subnet-cidr 10.0.1.0/24 --private-subnet-cidr 10.0.2.0/24 --name-prefix MyWebApp

# --- Helper function for logging ---
log() {
    echo "[INFO] $1"
}

# --- Argument Parsing ---
VPC_CIDR=""
PUBLIC_SUBNET_CIDR=""
PRIVATE_SUBNET_CIDR=""
NAME_PREFIX=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --vpc-cidr) VPC_CIDR="$2"; shift ;;
        --public-subnet-cidr) PUBLIC_SUBNET_CIDR="$2"; shift ;;
        --private-subnet-cidr) PRIVATE_SUBNET_CIDR="$2"; shift ;;
        --name-prefix) NAME_PREFIX="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [ -z "$VPC_CIDR" ] || [ -z "$PUBLIC_SUBNET_CIDR" ] || [ -z "$PRIVATE_SUBNET_CIDR" ] || [ -z "$NAME_PREFIX" ]; then
  echo "Error: All arguments are required."
  exit 1
fi

# --- Main Script Logic ---

# 1. Create VPC
log "Creating VPC..."
VPC_ID=$(aws ec2 create-vpc --cidr-block "$VPC_CIDR" --query 'Vpc.VpcId' --output text)
aws ec2 create-tags --resources "$VPC_ID" --tags "Key=Name,Value=${NAME_PREFIX}-VPC"
log "VPC created with ID: $VPC_ID"

# 2. Create Public Subnet
log "Creating Public Subnet..."
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block "$PUBLIC_SUBNET_CIDR" --query 'Subnet.SubnetId' --output text)
aws ec2 create-tags --resources "$PUBLIC_SUBNET_ID" --tags "Key=Name,Value=${NAME_PREFIX}-PublicSubnet"
log "Public Subnet created with ID: $PUBLIC_SUBNET_ID"

# 3. Create Private Subnet
log "Creating Private Subnet..."
PRIVATE_SUBNET_ID=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block "$PRIVATE_SUBNET_CIDR" --query 'Subnet.SubnetId' --output text)
aws ec2 create-tags --resources "$PRIVATE_SUBNET_ID" --tags "Key=Name,Value=${NAME_PREFIX}-PrivateSubnet"
log "Private Subnet created with ID: $PRIVATE_SUBNET_ID"

# 4. Create Internet Gateway and attach to VPC
log "Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 create-tags --resources "$IGW_ID" --tags "Key=Name,Value=${NAME_PREFIX}-IGW"
aws ec2 attach-internet-gateway --vpc-id "$VPC_ID" --internet-gateway-id "$IGW_ID"
log "Internet Gateway created and attached: $IGW_ID"

# 5. Create Public Route Table
log "Creating Public Route Table..."
PUBLIC_RT_ID=$(aws ec2 create-route-table --vpc-id "$VPC_ID" --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-tags --resources "$PUBLIC_RT_ID" --tags "Key=Name,Value=${NAME_PREFIX}-PublicRouteTable"
aws ec2 create-route --route-table-id "$PUBLIC_RT_ID" --destination-cidr-block 0.0.0.0/0 --gateway-id "$IGW_ID"
aws ec2 associate-route-table --subnet-id "$PUBLIC_SUBNET_ID" --route-table-id "$PUBLIC_RT_ID"
log "Public Route Table created and configured: $PUBLIC_RT_ID"

# 6. Create NAT Gateway
log "Creating Elastic IP for NAT Gateway..."
EIP_ALLOC_ID=$(aws ec2 allocate-address --domain vpc --query 'AllocationId' --output text)
log "Creating NAT Gateway... (This can take a few minutes)"
NAT_GW_ID=$(aws ec2 create-nat-gateway --subnet-id "$PUBLIC_SUBNET_ID" --allocation-id "$EIP_ALLOC_ID" --query 'NatGateway.NatGatewayId' --output text)
aws ec2 create-tags --resources "$NAT_GW_ID" --tags "Key=Name,Value=${NAME_PREFIX}-NAT-GW"
log "Waiting for NAT Gateway to become available..."
aws ec2 wait nat-gateway-available --nat-gateway-ids "$NAT_GW_ID"
log "NAT Gateway created: $NAT_GW_ID"

# 7. Create Private Route Table
log "Creating Private Route Table..."
PRIVATE_RT_ID=$(aws ec2 create-route-table --vpc-id "$VPC_ID" --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-tags --resources "$PRIVATE_RT_ID" --tags "Key=Name,Value=${NAME_PREFIX}-PrivateRouteTable"
aws ec2 create-route --route-table-id "$PRIVATE_RT_ID" --destination-cidr-block 0.0.0.0/0 --nat-gateway-id "$NAT_GW_ID"
aws ec2 associate-route-table --subnet-id "$PRIVATE_SUBNET_ID" --route-table-id "$PRIVATE_RT_ID"
log "Private Route Table created and configured: $PRIVATE_RT_ID"

log "--- VPC Setup Complete ---"
echo "VPC_ID: $VPC_ID"
echo "Public Subnet ID: $PUBLIC_SUBNET_ID"
echo "Private Subnet ID: $PRIVATE_SUBNET_ID"
echo "Internet Gateway ID: $IGW_ID"
echo "NAT Gateway ID: $NAT_GW_ID"
echo "Public Route Table ID: $PUBLIC_RT_ID"
echo "Private Route Table ID: $PRIVATE_RT_ID"
