#!/bin/bash

# Script to create a simple CodePipeline from CodeCommit to an S3 bucket.
# It creates the necessary IAM service role and policy.
# Usage: ./create-codepipeline.sh --name <PIPELINE_NAME> --repo <REPO_NAME> --bucket <BUCKET_NAME>
# Example: ./create-codepipeline.sh --name MyWebAppPipeline --repo MyWebAppRepo --bucket my-deploy-bucket

# --- Helper function for logging ---
log() {
    echo "[INFO] $1"
}
# --- Color Definitions ---
RED='\033[0;31m'

# --- Argument Parsing ---
PIPELINE_NAME=""
REPO_NAME=""
BUCKET_NAME=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --name) PIPELINE_NAME="$2"; shift ;;
        --repo) REPO_NAME="$2"; shift ;;
        --bucket) BUCKET_NAME="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [ -z "$PIPELINE_NAME" ] || [ -z "$REPO_NAME" ] || [ -z "$BUCKET_NAME" ]; then
  echo -e "${RED}Error: All arguments are required.${NC}"
  exit 1
fi

ROLE_NAME="${PIPELINE_NAME}-ServiceRole"
POLICY_NAME="${PIPELINE_NAME}-Policy"
TEMPLATE_FILE="$(dirname "$0")/pipeline-template.json"
FINAL_JSON_FILE="/tmp/${PIPELINE_NAME}.json"

# 1. Create IAM Role and Policy for CodePipeline
log "Creating IAM service role: $ROLE_NAME..."
TRUST_POLICY='{"Version": "2012-10-17","Statement": [{"Effect": "Allow","Principal": {"Service": "codepipeline.amazonaws.com"},"Action": "sts:AssumeRole"}]}'
ROLE_ARN=$(aws iam create-role --role-name "$ROLE_NAME" --assume-role-policy-document "$TRUST_POLICY" --query 'Role.Arn' --output text)
if [ $? -ne 0 ]; then log "Failed to create IAM role."; exit 1; fi

log "Creating IAM policy: $POLICY_NAME..."
# WARNING: This is a very permissive policy for competition speed.
# In a real-world scenario, this should be scoped down significantly.
POLICY_DOC=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:UploadArchive",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:CancelUploadArchive"
            ],
            "Resource": "*"
        }
    ]
}
EOF
)
POLICY_ARN=$(aws iam create-policy --policy-name "$POLICY_NAME" --policy-document "$POLICY_DOC" --query 'Policy.Arn' --output text)
aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn "$POLICY_ARN"
log "Waiting for IAM role and policy to propagate..."
sleep 10

# 2. Prepare the pipeline JSON from the template
log "Preparing pipeline definition from template..."
sed -e "s/PIPELINE_NAME_PLACEHOLDER/$PIPELINE_NAME/g" \
    -e "s|ROLE_ARN_PLACEHOLDER|$ROLE_ARN|g" \
    -e "s/BUCKET_NAME_PLACEHOLDER/$BUCKET_NAME/g" \
    -e "s/REPO_NAME_PLACEHOLDER/$REPO_NAME/g" \
    "$TEMPLATE_FILE" > "$FINAL_JSON_FILE"

# 3. Create the pipeline
log "Creating CodePipeline '$PIPELINE_NAME'..."
aws codepipeline create-pipeline --cli-input-json "file://$FINAL_JSON_FILE"

if [ $? -eq 0 ]; then
    log "CodePipeline '$PIPELINE_NAME' created successfully!"
else
    log "Failed to create CodePipeline."
fi

# Clean up the temp file
rm "$FINAL_JSON_FILE"
