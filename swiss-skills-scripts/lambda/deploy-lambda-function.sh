#!/bin/bash

# Script to create a basic IAM role, zip a local directory, and deploy it as a new Lambda function.
# Outputs a JSON object with the ARNs of the created function and role.
# Usage: ./deploy-lambda-function.sh --name <FUNCTION_NAME> --runtime <RUNTIME> --handler <HANDLER> --path <PATH_TO_CODE>
# Example: ./deploy-lambda-function.sh --name my-python-lambda --runtime python3.9 --handler index.handler --path ./my_lambda_code/

# --- Helper function for logging ---
log() {
    echo "[INFO] $1" >&2
}
# --- Color Definitions ---
RED='\033[0;31m'
NC='\033[0m'

# --- Argument Parsing ---
FUNCTION_NAME=""
RUNTIME=""
HANDLER=""
CODE_PATH=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --name) FUNCTION_NAME="$2"; shift ;;
        --runtime) RUNTIME="$2"; shift ;;
        --handler) HANDLER="$2"; shift ;;
        --path) CODE_PATH="$2"; shift ;;
        *) echo "Unknown parameter passed: $1" >&2; exit 1 ;;
    esac
    shift
done

if [ -z "$FUNCTION_NAME" ] || [ -z "$RUNTIME" ] || [ -z "$HANDLER" ] || [ -z "$CODE_PATH" ]; then
  echo -e "${RED}Error: All arguments are required.${NC}" >&2
  exit 1
fi

if [ ! -d "$CODE_PATH" ]; then
    echo -e "${RED}Error: Code path '$CODE_PATH' is not a valid directory.${NC}" >&2
    exit 1
fi

ROLE_NAME="${FUNCTION_NAME}-ExecutionRole"
ZIP_FILE_NAME="/tmp/${FUNCTION_NAME}.zip"
POLICY_ARN="arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

# --- Main Logic ---

# 1. Create IAM Role
log "Creating IAM execution role: $ROLE_NAME..."
TRUST_POLICY_JSON='{"Version": "2012-10-17","Statement": [{"Effect": "Allow","Principal": {"Service": "lambda.amazonaws.com"},"Action": "sts:AssumeRole"}]}'
ROLE_ARN=$(aws iam create-role --role-name "$ROLE_NAME" --assume-role-policy-document "$TRUST_POLICY_JSON" --query 'Role.Arn' --output text 2>&1)
if [ $? -ne 0 ]; then log "Failed to create IAM role. Error: $ROLE_ARN"; exit 1; fi

log "Attaching basic execution policy to role..."
aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn "$POLICY_ARN"
if [ $? -ne 0 ]; then log "Failed to attach policy to role."; exit 1; fi

# It can take a few seconds for the role to be fully available for use
log "Waiting for IAM role to propagate..."
sleep 10

# 2. Package the code
log "Zipping code from '$CODE_PATH' to '$ZIP_FILE_NAME'..."
(cd "$CODE_PATH" && zip -r "$ZIP_FILE_NAME" . >/dev/null)
if [ $? -ne 0 ]; then log "Failed to zip code."; rm "$ZIP_FILE_NAME"; exit 1; fi

# 3. Deploy the Lambda function
log "Creating Lambda function '$FUNCTION_NAME'..."
function_output=$(aws lambda create-function \
    --function-name "$FUNCTION_NAME" \
    --runtime "$RUNTIME" \
    --role "$ROLE_ARN" \
    --handler "$HANDLER" \
    --zip-file "fileb://$ZIP_FILE_NAME" \
    --output json 2>&1)

# Clean up the zip file
rm "$ZIP_FILE_NAME"

if [ $? -eq 0 ]; then
    log "Lambda function '$FUNCTION_NAME' created successfully!"
    FUNCTION_ARN=$(echo "$function_output" | jq -r '.FunctionArn')
    # Output created resource info as a JSON object to stdout
    cat <<EOF
{
  "FunctionArn": "$FUNCTION_ARN",
  "FunctionName": "$FUNCTION_NAME",
  "RoleArn": "$ROLE_ARN"
}
EOF
else
    log "Failed to create Lambda function."
    log "AWS CLI Error: $function_output"
    exit 1
fi
