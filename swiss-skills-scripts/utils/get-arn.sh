#!/bin/bash

# Script to get the ARN for a specific AWS resource.
# Outputs the resource ARN to stdout.
# Usage: ./get-arn.sh --type <TYPE> --name <NAME_OR_ID>
# Supported types: s3-bucket, iam-user, iam-role
# Example: ./get-arn.sh --type s3-bucket --name my-test-bucket
# Example: ./get-arn.sh --type iam-user --name my-app-user

# --- Argument Parsing ---
RESOURCE_TYPE=""
RESOURCE_NAME=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --type)
            RESOURCE_TYPE="$2"
            shift
            ;;
        --name)
            RESOURCE_NAME="$2"
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
if [ -z "$RESOURCE_TYPE" ] || [ -z "$RESOURCE_NAME" ]; then
  echo "Error: Both --type and --name are required." >&2
  echo "Usage: $0 --type <TYPE> --name <NAME_OR_ID>" >&2
  exit 1
fi

# --- Main Logic ---
echo "Getting ARN for $RESOURCE_TYPE '$RESOURCE_NAME'..." >&2

ARN=""
case $RESOURCE_TYPE in
    s3-bucket)
        # S3 ARN is a simple static format
        ARN="arn:aws:s3:::$RESOURCE_NAME"
        ;;
    iam-user)
        ARN=$(aws iam get-user --user-name "$RESOURCE_NAME" --query 'User.Arn' --output text 2>&1)
        ;;
    iam-role)
        ARN=$(aws iam get-role --role-name "$RESOURCE_NAME" --query 'Role.Arn' --output text 2>&1)
        ;;
    *)
        echo "Error: Unsupported resource type '$RESOURCE_TYPE'." >&2
        echo "Supported types: s3-bucket, iam-user, iam-role" >&2
        exit 1
        ;;
esac

# Check for errors from AWS CLI or if ARN is empty
if [ $? -ne 0 ] || [ -z "$ARN" ] || [ "$ARN" == "None" ]; then
    echo "Could not find ARN for $RESOURCE_TYPE '$RESOURCE_NAME'." >&2
    # If the ARN variable contains an error message from the CLI, print it
    if [[ "$ARN" == *"error"* || "$ARN" == *"Error"* ]]; then
        echo "AWS CLI Error: $ARN" >&2
    fi
    exit 1
fi

# Print the final ARN to stdout
echo "$ARN"
