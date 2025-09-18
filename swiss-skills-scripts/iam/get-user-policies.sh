#!/bin/bash

# Script to list IAM policies attached to an AWS IAM user.
# All output is sent to stderr as this is a diagnostic script.
# Usage: ./get-user-policies.sh --user-name <USER_NAME>
# Example: ./get-user-policies.sh --user-name my-app-user

# --- Argument Parsing ---
USER_NAME=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --user-name)
            USER_NAME="$2"
            shift
            ;;
        *)
            echo "Unknown parameter passed: $1" >&2
            exit 1
            ;;
    esac
    shift
done

if [ -z "$USER_NAME" ]; then
  echo "Error: The --user-name flag is required." >&2
  echo "Usage: $0 --user-name <USER_NAME>" >&2
  exit 1
fi

# --- Main Logic (all output to stderr) ---
{
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
} >&2
