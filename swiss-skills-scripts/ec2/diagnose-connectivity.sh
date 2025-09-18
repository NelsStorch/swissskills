#!/bin/bash

# Script to diagnose common connectivity issues for an EC2 instance.
# Usage: ./diagnose-connectivity.sh <INSTANCE_ID>
# Example: ./diagnose-connectivity.sh i-0123456789abcdef0

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- Helper Functions ---
check_ok() { echo -e "  [${GREEN}OK${NC}] $1"; }
check_fail() { echo -e "  [${RED}FAIL${NC}] $1"; }
check_warn() { echo -e "  [${YELLOW}WARN${NC}] $1"; }
info() { echo -e "  - $1"; }

# --- Argument Parsing ---
if [ -z "$1" ]; then
  echo -e "${RED}Error: No instance ID provided.${NC}"
  echo "Usage: $0 <INSTANCE_ID>"
  exit 1
fi
INSTANCE_ID=$1

echo -e "${YELLOW}--- Diagnosing Connectivity for Instance: $INSTANCE_ID ---${NC}"

# --- Get Instance Details ---
INSTANCE_JSON=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0]' 2>/dev/null)
if [ -z "$INSTANCE_JSON" ]; then
    check_fail "Could not retrieve instance details. Check if the instance ID is correct."
    exit 1
fi

SUBNET_ID=$(echo "$INSTANCE_JSON" | jq -r '.SubnetId')
VPC_ID=$(echo "$INSTANCE_JSON" | jq -r '.VpcId')
SG_IDS=$(echo "$INSTANCE_JSON" | jq -r '.SecurityGroups[].GroupId' | tr '\n' ' ')

# --- Check 1: Instance State ---
echo "1. Checking Instance State..."
INSTANCE_STATE=$(echo "$INSTANCE_JSON" | jq -r '.State.Name')
if [ "$INSTANCE_STATE" == "running" ]; then
    check_ok "Instance is running."
else
    check_fail "Instance is NOT running. Current state: $INSTANCE_STATE"
    exit 1
fi

# --- Check 2: Security Groups ---
echo "2. Checking Security Group Rules..."
SG_JSON=$(aws ec2 describe-security-groups --group-ids $SG_IDS --output json)
PORTS_TO_CHECK=(22 80 443)
for port in "${PORTS_TO_CHECK[@]}"; do
    RULE_FOUND=$(echo "$SG_JSON" | jq --argjson p "$port" '.SecurityGroups[].IpPermissions[] | select(.FromPort <= $p and .ToPort >= $p and (.IpRanges[].CidrIp == "0.0.0.0/0"))')
    if [ -n "$RULE_FOUND" ]; then
        check_ok "Port $port is open to the internet (0.0.0.0/0)."
    else
        check_warn "Port $port does not appear to be open to the internet."
    fi
done

# --- Check 3: Subnet Route Table ---
echo "3. Checking Subnet Route Table for Internet Gateway..."
RT_JSON=$(aws ec2 describe-route-tables --filters "Name=association.subnet-id,Values=$SUBNET_ID" --output json)
IGW_ROUTE=$(echo "$RT_JSON" | jq '.RouteTables[].Routes[] | select(.DestinationCidrBlock == "0.0.0.0/0" and .GatewayId | startswith("igw-"))')

if [ -n "$IGW_ROUTE" ]; then
    IGW_ID=$(echo "$IGW_ROUTE" | jq -r '.GatewayId')
    check_ok "Subnet's route table has a route to the internet via: $IGW_ID"
else
    check_fail "Subnet's route table does NOT have a route to 0.0.0.0/0 via an Internet Gateway."
    info "This instance may not be able to receive traffic from the internet."
fi

echo -e "${YELLOW}--- Diagnosis Complete ---${NC}"
