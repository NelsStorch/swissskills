#!/bin/bash

# Script to simulate an IAM policy for a user to check permissions for an action.
# Outputs a JSON object with the simulation result.
# Usage: ./simulate-permission.sh --user-arn <ARN> --action <ACTION> --resource-arn <ARN>
# Example: ./simulate-permission.sh --user-arn arn:aws:iam::123456789012:user/my-app-user --action s3:GetObject --resource-arn arn:aws:s3:::my-test-bucket/*

# --- Argument Parsing ---
USER_ARN=""
ACTION=""
RESOURCE_ARN=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --user-arn)
            USER_ARN="$2"
            shift
            ;;
        --action)
            ACTION="$2"
            shift
            ;;
        --resource-arn)
            RESOURCE_ARN="$2"
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
if [ -z "$USER_ARN" ] || [ -z "$ACTION" ] || [ -z "$RESOURCE_ARN" ]; then
  echo "Error: All arguments are required." >&2
  echo "Usage: $0 --user-arn <ARN> --action <ACTION> --resource-arn <ARN>" >&2
  exit 1
fi

# --- Main Logic ---
echo "Simulating if '$USER_ARN' can perform '$ACTION' on '$RESOURCE_ARN'..." >&2

aws_output=$(aws iam simulate-principal-policy \
    --policy-source-arn "$USER_ARN" \
    --action-names "$ACTION" \
    --resource-arns "$RESOURCE_ARN" \
    --query 'EvaluationResults[0].{EvalDecision:EvalDecision, MatchedStatements:MatchedStatements}' \
    --output json 2>&1)

if [ $? -ne 0 ]; then
    echo "An error occurred during simulation. Please check the ARNs and action name." >&2
    echo "AWS CLI Error: $aws_output" >&2
    exit 1
fi

# Print the JSON result to stdout
echo "$aws_output"

echo "Simulation finished." >&2
