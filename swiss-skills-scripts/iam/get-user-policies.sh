#!/bin/bash

# Script to list IAM policies attached to an AWS IAM user.
# Usage: ./get-user-policies.sh <USER_NAME>
# Example: ./get-user-policies.sh my-app-user

# Check if a user name was provided
if [ -z "$1" ]; then
  echo "Error: No user name provided."
  echo "Usage: $0 <USER_NAME>"
  exit 1
fi

USER_NAME=$1

echo "Fetching policies for IAM user: $USER_NAME..."

echo "--- Attached User Policies ---"
aws iam list-attached-user-policies --user-name "$USER_NAME" --query 'AttachedPolicies[*].PolicyName' --output table

echo -e "\n--- Inline User Policies ---"
POLICY_NAMES=$(aws iam list-user-policies --user-name "$USER_NAME" --query 'PolicyNames' --output json)
if [ -n "$POLICY_NAMES" ] && [ "$POLICY_NAMES" != "[]" ]; then
    echo "$POLICY_NAMES" | jq -r '.[]'
else
    echo "No inline policies found."
fi

echo "Script finished."
