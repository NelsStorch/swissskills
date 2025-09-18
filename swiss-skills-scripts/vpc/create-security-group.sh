#!/bin/bash

# Script to create a new AWS Security Group and optionally add ingress rules.
# Outputs the new Security Group ID on success.
# Usage: ./create-security-group.sh --group-name <name> --description <desc> --vpc-id <id> [--rules "<rules>"]
# Rule format: "protocol=<p>,port=<port>,cidr=<cidr>;..."
# Example: ./create-security-group.sh --group-name WebSG --description "Web SG" --vpc-id vpc-123 --rules "protocol=tcp,port=80,cidr=0.0.0.0/0;protocol=tcp,port=22,cidr=10.0.0.0/16"

# --- Argument Parsing ---
GROUP_NAME=""
DESCRIPTION=""
VPC_ID=""
INGRESS_RULES=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --group-name) GROUP_NAME="$2"; shift ;;
        --description) DESCRIPTION="$2"; shift ;;
        --vpc-id) VPC_ID="$2"; shift ;;
        --rules) INGRESS_RULES="$2"; shift ;;
        *) echo "Unknown parameter passed: $1" >&2; exit 1 ;;
    esac
    shift
done

# Validate arguments
if [ -z "$GROUP_NAME" ] || [ -z "$DESCRIPTION" ] || [ -z "$VPC_ID" ]; then
  echo "Error: --group-name, --description, and --vpc-id are required." >&2
  echo "Usage: $0 --group-name <name> --description <desc> --vpc-id <id> [--rules \"<rules>\"]" >&2
  exit 1
fi

# --- Main Logic ---
echo "Creating security group '$GROUP_NAME' in VPC '$VPC_ID'..." >&2
GROUP_ID=$(aws ec2 create-security-group --group-name "$GROUP_NAME" --description "$DESCRIPTION" --vpc-id "$VPC_ID" --query 'GroupId' --output text 2>&1)

if [ $? -ne 0 ]; then
    echo "Error creating security group." >&2
    echo "AWS CLI Error: $GROUP_ID" >&2
    exit 1
fi

echo "Security Group created successfully with ID: $GROUP_ID" >&2

# Add ingress rules if provided
if [ -n "$INGRESS_RULES" ]; then
    # Set IFS to ; to split the rules string
    IFS=';' read -ra RULES_ARRAY <<< "$INGRESS_RULES"
    for rule in "${RULES_ARRAY[@]}"; do
        # Use sed to extract values from the rule string
        protocol=$(echo "$rule" | sed -n 's/.*protocol=\([^,]*\).*/\1/p')
        port=$(echo "$rule" | sed -n 's/.*port=\([^,]*\).*/\1/p')
        cidr=$(echo "$rule" | sed -n 's/.*cidr=\([^,]*\).*/\1/p')

        if [ -n "$protocol" ] && [ -n "$port" ] && [ -n "$cidr" ]; then
            echo "Adding rule: Protocol=$protocol, Port=$port, CIDR=$cidr..." >&2
            aws ec2 authorize-security-group-ingress --group-id "$GROUP_ID" --protocol "$protocol" --port "$port" --cidr "$cidr" > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo "Rule added successfully." >&2
            else
                echo "Error adding rule for $protocol:$port from $cidr." >&2
            fi
        else
            echo "Warning: Skipping malformed rule: $rule" >&2
        fi
    done
fi

# Output the new Group ID to stdout
echo "$GROUP_ID"
