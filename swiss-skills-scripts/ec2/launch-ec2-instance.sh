#!/bin/bash

# Script to launch a new AWS EC2 instance.
# Usage: ./launch-ec2-instance.sh <AMI_ID> <INSTANCE_TYPE> <KEY_NAME> <SECURITY_GROUP_ID> <SUBNET_ID> [NAME_TAG] [IAM_PROFILE_NAME]
# Example: ./launch-ec2-instance.sh ami-0c55b159cbfafe1f0 t2.micro my-key-pair sg-12345678 subnet-87654321 MyWebserver MyEC2Role

# Check for the required number of arguments
if [ "$#" -lt 5 ]; then
    echo "Error: Missing required arguments."
    echo "Usage: $0 <AMI_ID> <INSTANCE_TYPE> <KEY_NAME> <SECURITY_GROUP_ID> <SUBNET_ID> [NAME_TAG] [IAM_PROFILE_NAME]"
    exit 1
fi

AMI_ID=$1
INSTANCE_TYPE=$2
KEY_NAME=$3
SECURITY_GROUP_ID=$4
SUBNET_ID=$5
NAME_TAG=${6:-MyInstance} # Default name tag if not provided
IAM_PROFILE_NAME=$7 # Optional IAM instance profile name

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
    echo "Attaching IAM Instance Profile: $IAM_PROFILE_NAME"
    CLI_ARGS+=(--iam-instance-profile "Name=$IAM_PROFILE_NAME")
else
    echo "No IAM Instance Profile provided."
fi

# Launch the EC2 instance
echo "Launching EC2 instance..."
echo "AMI ID: $AMI_ID"
echo "Instance Type: $INSTANCE_TYPE"
echo "Key Name: $KEY_NAME"
echo "Security Group ID: $SECURITY_GROUP_ID"
echo "Subnet ID: $SUBNET_ID"
echo "Name Tag: $NAME_TAG"

INSTANCE_ID=$(aws ec2 run-instances "${CLI_ARGS[@]}")

if [ $? -eq 0 ] && [ -n "$INSTANCE_ID" ]; then
    echo "Instance launched successfully with ID: $INSTANCE_ID"
    echo "Waiting for instance to be in 'running' state..."
    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
    echo "Instance is now running."
else
    echo "Error: EC2 instance launch failed."
    exit 1
fi

echo "Script finished."
