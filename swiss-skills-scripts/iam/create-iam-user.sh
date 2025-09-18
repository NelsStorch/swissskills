#!/bin/bash

# Script to create a new AWS IAM user, with options to create an access key and add to a group.
# Outputs the User ARN, or a JSON object with User ARN and Access Key info if a key is created.
# Usage: ./create-iam-user.sh --user-name <name> [--create-access-key] [--group <name>]
# Example: ./create-iam-user.sh --user-name my-app-user --group Developers
# Example: ./create-iam-user.sh --user-name my-cli-user --create-access-key | jq .

# --- Argument Parsing ---
USER_NAME=""
CREATE_ACCESS_KEY=false
GROUP_NAME=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --user-name)
            USER_NAME="$2"
            shift
            ;;
        --create-access-key)
            CREATE_ACCESS_KEY=true
            ;;
        --group)
            GROUP_NAME="$2"
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
  echo "Error: --user-name is required." >&2
  echo "Usage: $0 --user-name <name> [--create-access-key] [--group <name>]" >&2
  exit 1
fi

# --- Main Logic ---
echo "Creating IAM user named '$USER_NAME'..." >&2
user_arn=$(aws iam create-user --user-name "$USER_NAME" --query 'User.Arn' --output text 2>&1)

if [ $? -ne 0 ]; then
    echo "Error creating IAM user. The user might already exist." >&2
    echo "AWS CLI Error: $user_arn" >&2
    exit 1
fi
echo "IAM user '$USER_NAME' created successfully." >&2

# Add user to group if requested
if [ -n "$GROUP_NAME" ]; then
    echo "Adding user '$USER_NAME' to group '$GROUP_NAME'..." >&2
    aws iam add-user-to-group --user-name "$USER_NAME" --group-name "$GROUP_NAME" >/dev/null
    if [ $? -eq 0 ]; then
        echo "User successfully added to group." >&2
    else
        echo "Error adding user to group. Make sure the group exists." >&2
    fi
fi

# Create access key if requested and handle output
if [ "$CREATE_ACCESS_KEY" = true ]; then
    echo "Creating access key for user '$USER_NAME'..." >&2
    # Create key and get the JSON output
    access_key_json=$(aws iam create-access-key --user-name "$USER_NAME" --output json 2>&1)
    if [ $? -ne 0 ]; then
        echo "Error creating access key." >&2
        echo "AWS CLI Error: $access_key_json" >&2
        exit 1
    fi

    echo "Access key created. Outputting JSON with User ARN and Access Key details." >&2
    # Combine User ARN and Access Key into a single JSON output
    echo "$access_key_json" | jq --arg arn "$user_arn" '. + {UserArn: $arn}'
else
    # If no key is created, just output the ARN
    echo "$user_arn"
fi
