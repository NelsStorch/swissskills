#!/bin/bash

# Script to attach a managed IAM policy to a user or a role.
# On success, this script produces no output on stdout.
# Usage: ./attach-policy.sh --policy-arn <POLICY_ARN> [--user-name <USER_NAME> | --role-name <ROLE_NAME>]
# Example (user): ./attach-policy.sh --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess --user-name my-app-user
# Example (role): ./attach-policy.sh --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess --role-name MyEC2Role

# --- Argument Parsing ---
POLICY_ARN=""
USER_NAME=""
ROLE_NAME=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --policy-arn)
            POLICY_ARN="$2"
            shift
            ;;
        --user-name)
            USER_NAME="$2"
            shift
            ;;
        --role-name)
            ROLE_NAME="$2"
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
if [ -z "$POLICY_ARN" ]; then
  echo "Error: --policy-arn is required." >&2
  exit 1
fi

if [ -z "$USER_NAME" ] && [ -z "$ROLE_NAME" ]; then
  echo "Error: You must provide either --user-name or --role-name." >&2
  exit 1
fi

if [ -n "$USER_NAME" ] && [ -n "$ROLE_NAME" ]; then
  echo "Error: Please provide either --user-name or --role-name, not both." >&2
  exit 1
fi

# --- Main Logic ---
if [ -n "$USER_NAME" ]; then
    echo "Attaching policy '$POLICY_ARN' to user '$USER_NAME'..." >&2
    aws_output=$(aws iam attach-user-policy --user-name "$USER_NAME" --policy-arn "$POLICY_ARN" 2>&1)
    TARGET_TYPE="User"
    TARGET_NAME="$USER_NAME"
else
    echo "Attaching policy '$POLICY_ARN' to role '$ROLE_NAME'..." >&2
    aws_output=$(aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn "$POLICY_ARN" 2>&1)
    TARGET_TYPE="Role"
    TARGET_NAME="$ROLE_NAME"
fi

if [ $? -eq 0 ]; then
    echo "Policy successfully attached to $TARGET_TYPE '$TARGET_NAME'." >&2
else
    echo "Error attaching policy." >&2
    echo "AWS CLI Error: $aws_output" >&2
    exit 1
fi
