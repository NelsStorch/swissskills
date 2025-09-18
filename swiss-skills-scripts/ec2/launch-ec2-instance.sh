#!/bin/bash

# Script to launch a new AWS EC2 instance.
# Outputs the new instance ID on success.
# Usage: ./launch-ec2-instance.sh --ami-id <id> --instance-type <type> --key-name <key> --security-group-id <sg-id> --subnet-id <subnet-id> [--name <tag>] [--iam-profile <profile>]
# Example: ./launch-ec2-instance.sh --ami-id ami-0c55b159cbfafe1f0 --instance-type t2.micro --key-name my-key --security-group-id sg-123 --subnet-id subnet-456 --name WebServer --iam-profile MyEC2Role

# --- Argument Parsing ---
AMI_ID=""
INSTANCE_TYPE=""
KEY_NAME=""
SECURITY_GROUP_ID=""
SUBNET_ID=""
NAME_TAG="MyInstance" # Default name
IAM_PROFILE_NAME=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --ami-id) AMI_ID="$2"; shift ;;
        --instance-type) INSTANCE_TYPE="$2"; shift ;;
        --key-name) KEY_NAME="$2"; shift ;;
        --security-group-id) SECURITY_GROUP_ID="$2"; shift ;;
        --subnet-id) SUBNET_ID="$2"; shift ;;
        --name) NAME_TAG="$2"; shift ;;
        --iam-profile) IAM_PROFILE_NAME="$2"; shift ;;
        *) echo "Unknown parameter passed: $1" >&2; exit 1 ;;
    esac
    shift
done

# Validate required arguments
if [ -z "$AMI_ID" ] || [ -z "$INSTANCE_TYPE" ] || [ -z "$KEY_NAME" ] || [ -z "$SECURITY_GROUP_ID" ] || [ -z "$SUBNET_ID" ]; then
    echo "Error: Missing required arguments." >&2
    echo "Usage: $0 --ami-id <id> --instance-type <type> --key-name <key> --security-group-id <sg-id> --subnet-id <subnet-id>" >&2
    exit 1
fi

# --- Main Logic ---
echo "Building EC2 launch command..." >&2

# Build the command dynamically
CLI_ARGS=(
    --image-id "$AMI_ID"
    --instance-type "$INSTANCE_TYPE"
    --key-name "$KEY_NAME"
    --security-group-ids "$SECURITY_GROUP_ID"
    --subnet-id "$SUBNET_ID"
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$NAME_TAG}]"
    --query 'Instances[0].InstanceId'
    --output text
)

# Add IAM instance profile if provided
if [ -n "$IAM_PROFILE_NAME" ]; then
    echo "Attaching IAM Instance Profile: $IAM_PROFILE_NAME" >&2
    CLI_ARGS+=(--iam-instance-profile "Name=$IAM_PROFILE_NAME")
else
    echo "No IAM Instance Profile provided." >&2
fi

# Launch the EC2 instance
echo "Launching EC2 instance with Name tag: $NAME_TAG..." >&2
INSTANCE_ID=$(aws ec2 run-instances "${CLI_ARGS[@]}" 2>&1)

if [ $? -ne 0 ]; then
    echo "Error: EC2 instance launch failed." >&2
    echo "AWS CLI Error: $INSTANCE_ID" >&2
    exit 1
fi

echo "Instance launched successfully with ID: $INSTANCE_ID" >&2
echo "Waiting for instance to be in 'running' state..." >&2
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
echo "Instance is now running." >&2

# Output the ID to stdout
echo "$INSTANCE_ID"
