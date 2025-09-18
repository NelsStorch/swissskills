#!/bin/bash

# Script to create, accept, and configure routes for a VPC Peering connection.
# Outputs the new VPC Peering Connection ID on success.
# Usage: ./setup-vpc-peering.sh --requester-vpc-id <id> --accepter-vpc-id <id> --requester-cidr <cidr> --accepter-cidr <cidr>
# Example: ./setup-vpc-peering.sh --requester-vpc-id vpc-111 --accepter-vpc-id vpc-222 --requester-cidr 10.1.0.0/16 --accepter-cidr 10.2.0.0/16

# --- Helper function for logging ---
log() {
    echo "[INFO] $1" >&2
}

# --- Argument Parsing ---
REQUESTER_VPC_ID=""
ACCEPTER_VPC_ID=""
REQUESTER_CIDR=""
ACCEPTER_CIDR=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --requester-vpc-id) REQUESTER_VPC_ID="$2"; shift ;;
        --accepter-vpc-id) ACCEPTER_VPC_ID="$2"; shift ;;
        --requester-cidr) REQUESTER_CIDR="$2"; shift ;;
        --accepter-cidr) ACCEPTER_CIDR="$2"; shift ;;
        *) echo "Unknown parameter passed: $1" >&2; exit 1 ;;
    esac
    shift
done

if [ -z "$REQUESTER_VPC_ID" ] || [ -z "$ACCEPTER_VPC_ID" ] || [ -z "$REQUESTER_CIDR" ] || [ -z "$ACCEPTER_CIDR" ]; then
  echo "Error: All arguments are required." >&2
  echo "Usage: $0 --requester-vpc-id <id> --accepter-vpc-id <id> --requester-cidr <cidr> --accepter-cidr <cidr>" >&2
  exit 1
fi

# 1. Create the VPC Peering Connection
log "Creating VPC Peering connection from $REQUESTER_VPC_ID to $ACCEPTER_VPC_ID..."
PEERING_ID=$(aws ec2 create-vpc-peering-connection --vpc-id "$REQUESTER_VPC_ID" --peer-vpc-id "$ACCEPTER_VPC_ID" --query 'VpcPeeringConnection.VpcPeeringConnectionId' --output text 2>&1)
if [ $? -ne 0 ]; then log "Failed to create peering connection. AWS Error: $PEERING_ID"; exit 1; fi
log "Peering connection created: $PEERING_ID"

# 2. Accept the VPC Peering Connection
log "Accepting VPC Peering connection..."
aws ec2 accept-vpc-peering-connection --vpc-peering-connection-id "$PEERING_ID" >/dev/null
if [ $? -ne 0 ]; then log "Failed to accept peering connection."; exit 1; fi
log "Peering connection accepted."

# 3. Find main route tables
log "Finding main route tables for both VPCs..."
REQUESTER_RT_ID=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$REQUESTER_VPC_ID" "Name=association.main,Values=true" --query 'RouteTables[0].RouteTableId' --output text)
ACCEPTER_RT_ID=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$ACCEPTER_VPC_ID" "Name=association.main,Values=true" --query 'RouteTables[0].RouteTableId' --output text)

if [ -z "$REQUESTER_RT_ID" ] || [ -z "$ACCEPTER_RT_ID" ]; then
    log "Could not find the main route table for one or both VPCs."
    exit 1
fi

# 4. Add routes
log "Adding route to Accepter VPC ($ACCEPTER_CIDR) in Requester's route table ($REQUESTER_RT_ID)..."
aws ec2 create-route --route-table-id "$REQUESTER_RT_ID" --destination-cidr-block "$ACCEPTER_CIDR" --vpc-peering-connection-id "$PEERING_ID" >/dev/null
if [ $? -ne 0 ]; then log "Failed to add route to accepter VPC."; fi

log "Adding route to Requester VPC ($REQUESTER_CIDR) in Accepter's route table ($ACCEPTER_RT_ID)..."
aws ec2 create-route --route-table-id "$ACCEPTER_RT_ID" --destination-cidr-block "$REQUESTER_CIDR" --vpc-peering-connection-id "$PEERING_ID" >/dev/null
if [ $? -ne 0 ]; then log "Failed to add route to requester VPC."; fi

log "VPC Peering setup complete!"

# Output the Peering Connection ID to stdout
echo "$PEERING_ID"
