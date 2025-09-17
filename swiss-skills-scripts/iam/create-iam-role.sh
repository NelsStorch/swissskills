#!/bin/bash

# Script to create a new AWS IAM role for EC2.
# Usage: ./create-iam-role.sh <ROLE_NAME>
# Example: ./create-iam-role.sh MyEC2Role

# Check if a role name was provided
if [ -z "$1" ]; then
  echo "Error: No role name provided."
  echo "Usage: $0 <ROLE_NAME>"
  exit 1
fi

ROLE_NAME=$1

# Define the trust policy for EC2
TRUST_POLICY_JSON=$(cat <<EOF
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

# Create the IAM role
echo "Creating IAM role named '$ROLE_NAME' with a trust policy for EC2..."
aws iam create-role --role-name "$ROLE_NAME" --assume-role-policy-document "$TRUST_POLICY_JSON"

if [ $? -eq 0 ]; then
  echo "IAM role '$ROLE_NAME' created successfully."
  echo "To attach a policy, use the AWS CLI:"
  echo "aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn <POLICY_ARN>"
else
  echo "Error creating IAM role. The role might already exist."
  exit 1
fi

echo "Script finished."
