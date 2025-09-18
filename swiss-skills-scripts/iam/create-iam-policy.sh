#!/bin/bash

# Script to create a new IAM policy from a JSON document.
# Outputs the new policy ARN on success.
# Usage: ./create-iam-policy.sh --policy-name <name> --policy-document <json_or_file_path>
# Example (JSON string): ./create-iam-policy.sh --policy-name MyTestPolicy --policy-document '{"Version":"2012-10-17",...}'
# Example (file): ./create-iam-policy.sh --policy-name MyTestPolicy --policy-document file://./policy.json

# --- Argument Parsing ---
POLICY_NAME=""
POLICY_DOCUMENT=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --policy-name)
            POLICY_NAME="$2"
            shift
            ;;
        --policy-document)
            POLICY_DOCUMENT="$2"
            shift
            ;;
        *)
            echo "Unknown parameter passed: $1" >&2
            exit 1
            ;;
    esac
    shift
done

# Validate arguments
if [ -z "$POLICY_NAME" ] || [ -z "$POLICY_DOCUMENT" ]; then
  echo "Error: Both --policy-name and --policy-document are required." >&2
  echo "Usage: $0 --policy-name <name> --policy-document <json_or_file_path>" >&2
  exit 1
fi

# --- Main Logic ---
echo "Creating IAM policy named '$POLICY_NAME'..." >&2

# The aws cli handles both raw JSON and file:// paths for the --policy-document argument.
policy_output=$(aws iam create-policy \
    --policy-name "$POLICY_NAME" \
    --policy-document "$POLICY_DOCUMENT" \
    --query 'Policy.Arn' \
    --output text 2>&1)

if [ $? -eq 0 ]; then
    echo "IAM policy '$POLICY_NAME' created successfully." >&2
    # Output the new policy ARN to stdout
    echo "$policy_output"
else
    echo "Error creating IAM policy." >&2
    echo "AWS CLI Error: $policy_output" >&2
    exit 1
fi
