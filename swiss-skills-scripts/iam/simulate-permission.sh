#!/bin/bash

# Script to simulate an IAM policy for a user to check permissions for an action.
# Usage: ./simulate-permission.sh --user-arn <ARN> --action <ACTION> --resource-arn <ARN>
# Example: ./simulate-permission.sh --user-arn arn:aws:iam::123456789012:user/my-app-user --action s3:GetObject --resource-arn arn:aws:s3:::my-test-bucket/*

# Initialize variables
USER_ARN=""
ACTION=""
RESOURCE_ARN=""

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --user-arn) USER_ARN="$2"; shift ;;
        --action) ACTION="$2"; shift ;;
        --resource-arn) RESOURCE_ARN="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Validate arguments
if [ -z "$USER_ARN" ] || [ -z "$ACTION" ] || [ -z "$RESOURCE_ARN" ]; then
  echo "Error: All arguments are required."
  echo "Usage: $0 --user-arn <ARN> --action <ACTION> --resource-arn <ARN>"
  exit 1
fi

echo "Simulating if '$USER_ARN' can perform '$ACTION' on '$RESOURCE_ARN'..."

aws iam simulate-principal-policy \
    --policy-source-arn "$USER_ARN" \
    --action-names "$ACTION" \
    --resource-arns "$RESOURCE_ARN" \
    --query 'EvaluationResults[0].{EvalDecision:EvalDecision, MatchedStatements:MatchedStatements}' \
    --output json

if [ $? -ne 0 ]; then
    echo "An error occurred during simulation. Please check the ARNs and action name."
    exit 1
fi

echo "Script finished."
