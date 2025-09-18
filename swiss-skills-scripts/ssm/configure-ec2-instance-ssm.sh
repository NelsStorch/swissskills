#!/bin/bash

# Script to execute a local shell script on an EC2 instance using SSM Run Command.
# The target instance MUST have the SSM Agent installed and an IAM role with SSM permissions.
# Usage: ./configure-ec2-instance-ssm.sh --instance-id <INSTANCE_ID> --script-path <PATH_TO_SCRIPT>
# Example: ./configure-ec2-instance-ssm.sh --instance-id i-0123456789 --script-path ./my-config.sh

# --- Helper function for logging ---
log() {
    echo "[INFO] $1"
}
# --- Color Definitions ---
RED='\033[0;31m'

# --- Argument Parsing ---
INSTANCE_ID=""
SCRIPT_PATH=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --instance-id) INSTANCE_ID="$2"; shift ;;
        --script-path) SCRIPT_PATH="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [ -z "$INSTANCE_ID" ] || [ -z "$SCRIPT_PATH" ]; then
  echo -e "${RED}Error: Instance ID and script path are required.${NC}"
  exit 1
fi

if [ ! -f "$SCRIPT_PATH" ]; then
    echo -e "${RED}Error: Script path '$SCRIPT_PATH' is not a valid file.${NC}"
    exit 1
fi

# 1. Send the command
log "Sending script from '$SCRIPT_PATH' to instance '$INSTANCE_ID' via SSM Run Command..."
COMMAND_ID=$(aws ssm send-command \
    --instance-ids "$INSTANCE_ID" \
    --document-name "AWS-RunShellScript" \
    --parameters "commands=[\"$(cat "$SCRIPT_PATH")\"]" \
    --query "Command.CommandId" \
    --output text)

if [ $? -ne 0 ]; then
    log "Failed to send command. Check instance SSM connectivity and permissions."
    exit 1
fi

log "Command sent with ID: $COMMAND_ID"
log "Waiting for command to complete... (This can take a moment)"

# 2. Wait for the command to finish and get the output
aws ssm wait command-executed --command-id "$COMMAND_ID" --instance-id "$INSTANCE_ID"

log "Command finished. Fetching output..."
aws ssm get-command-invocation \
    --command-id "$COMMAND_ID" \
    --instance-id "$INSTANCE_ID" \
    --query '{Status:Status, Output:StandardOutputContent, Error:StandardErrorContent}' \
    --output json | jq .
