#!/bin/bash

# Script to create the necessary VPC Endpoints for a private ECS cluster.
# Usage: ./create-vpc-endpoints.sh --vpc-id <VPC_ID> --subnet-ids <SUBNET_ID_1> <SUBNET_ID_2> ...
# Example: ./create-vpc-endpoints.sh --vpc-id vpc-12345678 --subnet-ids subnet-1111 subnet-2222

# --- Helper function for logging ---
log() {
    echo "[INFO] $1"
}

# --- Argument Parsing ---
VPC_ID=""
SUBNET_IDS=()

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --vpc-id) VPC_ID="$2"; shift ;;
        --subnet-ids) shift; while [[ "$#" -gt 0 && ! "$1" =~ ^-- ]]; do SUBNET_IDS+=("$1"); shift; done; ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
done

if [ -z "$VPC_ID" ] || [ ${#SUBNET_IDS[@]} -eq 0 ]; then
  echo "Error: VPC ID and at least one Subnet ID are required."
  exit 1
fi

# Get region from AWS config
REGION=$(aws configure get region)
if [ -z "$REGION" ]; then
    echo "Error: Could not determine AWS region. Please configure it using 'aws configure set region <your-region>'."
    exit 1
fi

# --- Create Interface Endpoints ---
log "Creating Interface Endpoint for ECR API..."
aws ec2 create-vpc-endpoint --vpc-id "$VPC_ID" --service-name "com.amazonaws.$REGION.ecr.api" --vpc-endpoint-type Interface --subnet-ids "${SUBNET_IDS[@]}" --private-dns-enabled

log "Creating Interface Endpoint for ECR DKR..."
aws ec2 create-vpc-endpoint --vpc-id "$VPC_ID" --service-name "com.amazonaws.$REGION.ecr.dkr" --vpc-endpoint-type Interface --subnet-ids "${SUBNET_IDS[@]}" --private-dns-enabled

# --- Create Gateway Endpoint for S3 ---
log "Creating Gateway Endpoint for S3..."
# Find the main route table for the VPC
MAIN_RT_ID=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" "Name=association.main,Values=true" --query 'RouteTables[0].RouteTableId' --output text)
if [ -z "$MAIN_RT_ID" ] || [ "$MAIN_RT_ID" == "None" ]; then
    echo "Error: Could not find the main route table for VPC $VPC_ID."
    exit 1
fi
log "Found main route table: $MAIN_RT_ID"

aws ec2 create-vpc-endpoint --vpc-id "$VPC_ID" --service-name "com.amazonaws.$REGION.s3" --vpc-endpoint-type Gateway --route-table-ids "$MAIN_RT_ID"

log "VPC Endpoint creation process initiated."
