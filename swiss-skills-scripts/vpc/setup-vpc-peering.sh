#!/bin/bash

# Script to create, accept, and configure routes for a VPC Peering connection.
# Usage: ./setup-vpc-peering.sh --requester-vpc-id <VPC_ID> --accepter-vpc-id <VPC_ID>
# Example: ./setup-vpc-peering.sh --requester-vpc-id vpc-11111111 --accepter-vpc-id vpc-22222222

# --- Helper function for logging ---
log() {
    echo "[INFO] $1"
}

# --- Argument Parsing ---
REQUESTER_VPC_ID=""
ACCEPTER_VPC_ID=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --requester-vpc-id) REQUESTER_VPC_ID="$2"; shift ;;
        --accepter-vpc-id) ACCEPTER_VPC_ID="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [ -z "$REQUESTER_VPC_ID" ] || [ -z "$ACCEPTER_VPC_ID" ]; then
  echo "Error: Both requester and accepter VPC IDs are required."
  exit 1
fi

# 1. Create the VPC Peering Connection
log "Creating VPC Peering connection from $REQUESTER_VPC_ID to $ACCEPTER_VPC_ID..."
PEERING_ID=$(aws ec2 create-vpc-peering-connection --vpc-id "$REQUESTER_VPC_ID" --peer-vpc-id "$ACCEPTER_VPC_ID" --query 'VpcPeeringConnection.VpcPeeringConnectionId' --output text)
if [ $? -ne 0 ]; then log "Failed to create peering connection."; exit 1; fi
log "Peering connection created: $PEERING_ID"

# 2. Accept the VPC Peering Connection
log "Accepting VPC Peering connection..."
aws ec2 accept-vpc-peering-connection --vpc-peering-connection-id "$PEERING_ID"
if [ $? -ne 0 ]; then log "Failed to accept peering connection."; exit 1; fi
log "Peering connection accepted."

# 3. Get CIDR blocks and add routes
read -p "Enter CIDR block for Requester VPC ($REQUESTER_VPC_ID): " REQUESTER_CIDR
read -p "Enter CIDR block for Accepter VPC ($ACCEPTER_VPC_ID): " ACCEPTER_CIDR

if [ -z "$REQUESTER_CIDR" ] || [ -z "$ACCEPTER_CIDR" ]; then
  echo "Error: CIDR blocks for both VPCs are required to create routes."
  exit 1
fi

# Find main route tables
REQUESTER_RT_ID=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$REQUESTER_VPC_ID" "Name=association.main,Values=true" --query 'RouteTables[0].RouteTableId' --output text)
ACCEPTER_RT_ID=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$ACCEPTER_VPC_ID" "Name=association.main,Values=true" --query 'RouteTables[0].RouteTableId' --output text)

# Add routes
log "Adding route to Accepter VPC ($ACCEPTER_CIDR) in Requester's route table ($REQUESTER_RT_ID)..."
aws ec2 create-route --route-table-id "$REQUESTER_RT_ID" --destination-cidr-block "$ACCEPTER_CIDR" --vpc-peering-connection-id "$PEERING_ID"

log "Adding route to Requester VPC ($REQUESTER_CIDR) in Accepter's route table ($ACCEPTER_RT_ID)..."
aws ec2 create-route --route-table-id "$ACCEPTER_RT_ID" --destination-cidr-block "$REQUESTER_CIDR" --vpc-peering-connection-id "$PEERING_ID"

log "VPC Peering setup complete!"
