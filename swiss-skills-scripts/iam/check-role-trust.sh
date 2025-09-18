#!/bin/bash

# Script to display the trust policy (AssumeRolePolicyDocument) for an IAM role.
# Outputs the JSON trust policy document to stdout.
# Usage: ./check-role-trust.sh --role-name <ROLE_NAME>
# Example: ./check-role-trust.sh --role-name MyEC2Role

# --- Color Definitions ---
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# --- Argument Parsing ---
ROLE_NAME=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --role-name)
            ROLE_NAME="$2"
            shift
            ;;
        *)
            echo -e "${RED}Unknown parameter passed: $1${NC}" >&2
            exit 1
            ;;
    esac
    shift
done

if [ -z "$ROLE_NAME" ]; then
  echo -e "${RED}Error: --role-name flag is required.${NC}" >&2
  echo "Usage: $0 --role-name <ROLE_NAME>" >&2
  exit 1
fi

# --- Main Logic ---
echo -e "${YELLOW}--- Trust Policy for IAM Role: $ROLE_NAME ---${NC}" >&2

# Get the role's trust policy
policy_doc=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.AssumeRolePolicyDocument' --output json 2>&1)

if [ $? -ne 0 ]; then
    echo -e "${RED}Could not retrieve trust policy. Check if the role name is correct.${NC}" >&2
    echo "AWS CLI Error: $policy_doc" >&2
    exit 1
fi

# Pretty-print the JSON policy to stdout
echo "$policy_doc" | jq .

echo -e "${YELLOW}--- End of Policy ---${NC}" >&2
