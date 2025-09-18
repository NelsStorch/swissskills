#!/bin/bash

# Script to create a new AWS IAM role.
# Outputs the new Role ARN on success.
# Usage: ./create-iam-role.sh --role-name <name> [--trust-policy <json_or_file_path>]
# Example: ./create-iam-role.sh --role-name MyEC2Role
# Example: ./create-iam-role.sh --role-name MyLambdaRole --trust-policy '{"Version":"2012-10-17",...}'
# Example: ./create-iam-role.sh --role-name MyS3Role --trust-policy file://path/to/policy.json

# --- Argument Parsing ---
ROLE_NAME=""
TRUST_POLICY_INPUT=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --role-name)
            ROLE_NAME="$2"
            shift
            ;;
        --trust-policy)
            TRUST_POLICY_INPUT="$2"
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
if [ -z "$ROLE_NAME" ]; then
  echo "Error: The --role-name flag is required." >&2
  echo "Usage: $0 --role-name <ROLE_NAME>" >&2
  exit 1
fi

# Determine the trust policy document
TRUST_POLICY_DOC=""
if [ -z "$TRUST_POLICY_INPUT" ]; then
    echo "No trust policy provided, using default for EC2 service." >&2
    TRUST_POLICY_DOC=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
)
else
    TRUST_POLICY_DOC="$TRUST_POLICY_INPUT"
fi

# --- Main Logic ---
echo "Creating IAM role named '$ROLE_NAME'..." >&2
role_output=$(aws iam create-role --role-name "$ROLE_NAME" --assume-role-policy-document "$TRUST_POLICY_DOC" --query 'Role.Arn' --output text 2>&1)

if [ $? -eq 0 ]; then
  echo "IAM role '$ROLE_NAME' created successfully." >&2
  # Output the Role ARN to stdout
  echo "$role_output"
else
  echo "Error creating IAM role. The role might already exist or the trust policy may be invalid." >&2
  echo "AWS CLI Error: $role_output" >&2
  exit 1
fi
