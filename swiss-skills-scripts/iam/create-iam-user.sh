#!/bin/bash

# Script to create a new AWS IAM user, with options to create an access key and add to a group.
# Usage: ./create-iam-user.sh --user-name <USER_NAME> [--create-access-key] [--group <GROUP_NAME>]
# Example: ./create-iam-user.sh --user-name my-app-user
# Example: ./create-iam-user.sh --user-name my-cli-user --create-access-key --group Developers

# Initialize variables
USER_NAME=""
CREATE_ACCESS_KEY=false
GROUP_NAME=""

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --user-name) USER_NAME="$2"; shift ;;
        --create-access-key) CREATE_ACCESS_KEY=true ;;
        --group) GROUP_NAME="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Check if a user name was provided
if [ -z "$USER_NAME" ]; then
  echo "Error: User name is required."
  echo "Usage: $0 --user-name <USER_NAME> [--create-access-key] [--group <GROUP_NAME>]"
  exit 1
fi

# Create the IAM user
echo "Creating IAM user named '$USER_NAME'..."
aws iam create-user --user-name "$USER_NAME"

if [ $? -ne 0 ]; then
    echo "Error creating IAM user. The user might already exist."
    exit 1
fi

echo "IAM user '$USER_NAME' created successfully."

# Create access key if requested
if [ "$CREATE_ACCESS_KEY" = true ]; then
    echo "Creating access key for user '$USER_NAME'..."
    ACCESS_KEY_INFO=$(aws iam create-access-key --user-name "$USER_NAME")
    echo "Access key created. Please save these credentials securely:"
    echo "$ACCESS_KEY_INFO"
fi

# Add user to group if requested
if [ -n "$GROUP_NAME" ]; then
    echo "Adding user '$USER_NAME' to group '$GROUP_NAME'..."
    aws iam add-user-to-group --user-name "$USER_NAME" --group-name "$GROUP_NAME"
    if [ $? -eq 0 ]; then
        echo "User successfully added to group."
    else
        echo "Error adding user to group. Make sure the group exists."
    fi
fi

echo "Script finished."
