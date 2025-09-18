#!/bin/bash

# Script to create a new EC2 Launch Template.
# Outputs the ID of the new launch template on success.
# Usage: ./create-launch-template.sh --template-name <NAME> --ami-id <AMI_ID> --instance-type <TYPE> --key-name <KEY> --security-group-id <SG_ID>
# Example: ./create-launch-template.sh --template-name MyWebTemplate --ami-id ami-0c55b159cbfafe1f0 --instance-type t2.micro --key-name my-key --security-group-id sg-12345678

# --- Argument Parsing ---
TEMPLATE_NAME=""
AMI_ID=""
INSTANCE_TYPE=""
KEY_NAME=""
SG_ID=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --template-name) TEMPLATE_NAME="$2"; shift ;;
        --ami-id) AMI_ID="$2"; shift ;;
        --instance-type) INSTANCE_TYPE="$2"; shift ;;
        --key-name) KEY_NAME="$2"; shift ;;
        --security-group-id) SG_ID="$2"; shift ;;
        *) echo "Unknown parameter passed: $1" >&2; exit 1 ;;
    esac
    shift
done

# Validate arguments
if [ -z "$TEMPLATE_NAME" ] || [ -z "$AMI_ID" ] || [ -z "$INSTANCE_TYPE" ] || [ -z "$KEY_NAME" ] || [ -z "$SG_ID" ]; then
  echo "Error: All arguments are required." >&2
  echo "Usage: $0 --template-name <NAME> --ami-id <AMI_ID> --instance-type <TYPE> --key-name <KEY> --security-group-id <SG_ID>" >&2
  exit 1
fi

# --- Main Logic ---
echo "Creating EC2 Launch Template named '$TEMPLATE_NAME'..." >&2

# Construct the launch template data JSON
LAUNCH_TEMPLATE_DATA=$(cat <<EOF
{
    "ImageId": "$AMI_ID",
    "InstanceType": "$INSTANCE_TYPE",
    "KeyName": "$KEY_NAME",
    "SecurityGroupIds": ["$SG_ID"]
}
EOF
)

# Create the launch template and capture the ID
template_id=$(aws ec2 create-launch-template \
    --launch-template-name "$TEMPLATE_NAME" \
    --launch-template-data "$LAUNCH_TEMPLATE_DATA" \
    --query 'LaunchTemplate.LaunchTemplateId' \
    --output text 2>&1)

# Check for errors
if [ $? -ne 0 ]; then
    echo "Error creating launch template '$TEMPLATE_NAME'." >&2
    echo "AWS CLI Error: $template_id" >&2
    exit 1
fi

# Output the ID on success
echo "$template_id"

echo "Launch Template '$TEMPLATE_NAME' created successfully with ID: $template_id" >&2
