#!/bin/bash

# Script to attach a managed IAM policy to a user or a role.
# Usage: ./attach-policy.sh --policy-arn <POLICY_ARN> [--user-name <USER_NAME> | --role-name <ROLE_NAME>]
# Example (user): ./attach-policy.sh --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess --user-name my-app-user
# Example (role): ./attach-policy.sh --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess --role-name MyEC2Role

# Initialize variables
POLICY_ARN=""
USER_NAME=""
ROLE_NAME=""

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --policy-arn) POLICY_ARN="$2"; shift ;;
        --user-name) USER_NAME="$2"; shift ;;
        --role-name) ROLE_NAME="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Validate arguments
if [ -z "$POLICY_ARN" ]; then
  echo "Error: Policy ARN is required."
  exit 1
fi

if [ -z "$USER_NAME" ] && [ -z "$ROLE_NAME" ]; then
  echo "Error: You must provide either a user name or a role name."
  exit 1
fi

if [ -n "$USER_NAME" ] && [ -n "$ROLE_NAME" ]; then
  echo "Error: Please provide either a user name or a role name, not both."
  exit 1
fi

# Attach the policy
if [ -n "$USER_NAME" ]; then
    echo "Attaching policy '$POLICY_ARN' to user '$USER_NAME'..."
    aws iam attach-user-policy --user-name "$USER_NAME" --policy-arn "$POLICY_ARN"
    TARGET_TYPE="User"
    TARGET_NAME="$USER_NAME"
else
    echo "Attaching policy '$POLICY_ARN' to role '$ROLE_NAME'..."
    aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn "$POLICY_ARN"
    TARGET_TYPE="Role"
    TARGET_NAME="$ROLE_NAME"
fi

if [ $? -eq 0 ]; then
    echo "Policy successfully attached to $TARGET_TYPE '$TARGET_NAME'."
else
    echo "Error attaching policy. Please check the names, ARN, and permissions."
    exit 1
fi

echo "Script finished."
