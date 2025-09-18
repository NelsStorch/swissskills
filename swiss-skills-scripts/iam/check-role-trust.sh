#!/bin/bash

# Script to display the trust policy (AssumeRolePolicyDocument) for an IAM role.
# Usage: ./check-role-trust.sh <ROLE_NAME>
# Example: ./check-role-trust.sh MyEC2Role

# --- Color Definitions ---
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# --- Argument Parsing ---
if [ -z "$1" ]; then
  echo -e "${RED}Error: No role name provided.${NC}"
  echo "Usage: $0 <ROLE_NAME>"
  exit 1
fi
ROLE_NAME=$1

echo -e "${YELLOW}--- Trust Policy for IAM Role: $ROLE_NAME ---${NC}"

# Get the role's trust policy and pretty-print it with jq
aws iam get-role --role-name "$ROLE_NAME" --query 'Role.AssumeRolePolicyDocument' --output json 2>/dev/null | jq .

if [ $? -ne 0 ]; then
    echo -e "${RED}Could not retrieve or parse trust policy. Check if the role name is correct.${NC}"
    exit 1
fi

echo -e "${YELLOW}--- End of Policy ---${NC}"
