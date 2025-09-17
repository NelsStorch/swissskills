#!/bin/bash

# Script to get the ARN for a specific AWS resource.
# Usage: ./get-arn.sh --type <TYPE> --name <NAME_OR_ID>
# Supported types: s3-bucket, iam-user, iam-role
# Example: ./get-arn.sh --type s3-bucket --name my-test-bucket
# Example: ./get-arn.sh --type iam-user --name my-app-user

# Initialize variables
RESOURCE_TYPE=""
RESOURCE_NAME=""

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --type) RESOURCE_TYPE="$2"; shift ;;
        --name) RESOURCE_NAME="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Validate arguments
if [ -z "$RESOURCE_TYPE" ] || [ -z "$RESOURCE_NAME" ]; then
  echo "Error: Both resource type and name/id are required."
  echo "Usage: $0 --type <TYPE> --name <NAME_OR_ID>"
  exit 1
fi

echo "Getting ARN for $RESOURCE_TYPE '$RESOURCE_NAME'..."

ARN=""
case $RESOURCE_TYPE in
    s3-bucket)
        ARN="arn:aws:s3:::$RESOURCE_NAME"
        ;;
    iam-user)
        ARN=$(aws iam get-user --user-name "$RESOURCE_NAME" --query 'User.Arn' --output text)
        ;;
    iam-role)
        ARN=$(aws iam get-role --role-name "$RESOURCE_NAME" --query 'Role.Arn' --output text)
        ;;
    *)
        echo "Error: Unsupported resource type '$RESOURCE_TYPE'."
        echo "Supported types: s3-bucket, iam-user, iam-role"
        exit 1
        ;;
esac

if [ -n "$ARN" ] && [ "$ARN" != "None" ]; then
    echo "$ARN"
else
    echo "Could not find ARN for $RESOURCE_TYPE '$RESOURCE_NAME'."
    exit 1
fi

echo "Script finished."
