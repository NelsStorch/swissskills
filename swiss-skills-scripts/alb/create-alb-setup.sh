#!/bin/bash

# Script to create a full Application Load Balancer (ALB) setup.
# Creates an ALB, a default Target Group, and an HTTP listener.
# Outputs a JSON object with the ARNs of the created resources.
# Usage: ./create-alb-setup.sh --name <base-name> --vpc-id <id> --subnet-ids "<id1>,<id2>"
# Example: ./create-alb-setup.sh --name my-web-app --vpc-id vpc-123 --subnet-ids "subnet-abc,subnet-def"

# --- Argument Parsing ---
NAME=""
VPC_ID=""
SUBNET_IDS=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --name)
            NAME="$2"
            shift
            ;;
        --vpc-id)
            VPC_ID="$2"
            shift
            ;;
        --subnet-ids)
            SUBNET_IDS="$2"
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
if [ -z "$NAME" ] || [ -z "$VPC_ID" ] || [ -z "$SUBNET_IDS" ]; then
  echo "Error: --name, --vpc-id, and --subnet-ids are required." >&2
  exit 1
fi

# --- Main Logic ---

# 1. Create the Application Load Balancer
echo "Creating Application Load Balancer named '$NAME-alb'..." >&2
# Note: The subnet IDs string is converted from comma-separated to space-separated for the CLI
alb_json=$(aws elbv2 create-load-balancer \
    --name "$NAME-alb" \
    --type application \
    --subnets $(echo "$SUBNET_IDS" | tr ',' ' ') \
    --query 'LoadBalancers[0]' \
    --output json 2>&1)

if [ $? -ne 0 ]; then
    echo "Error creating ALB." >&2
    echo "AWS CLI Error: $alb_json" >&2
    exit 1
fi
ALB_ARN=$(echo "$alb_json" | jq -r '.LoadBalancerArn')
echo "ALB created with ARN: $ALB_ARN" >&2

# 2. Create a Target Group
echo "Creating Target Group named '$NAME-tg'..." >&2
tg_json=$(aws elbv2 create-target-group \
    --name "$NAME-tg" \
    --protocol HTTP \
    --port 80 \
    --vpc-id "$VPC_ID" \
    --health-check-protocol HTTP \
    --health-check-path / \
    --target-type instance \
    --query 'TargetGroups[0]' \
    --output json 2>&1)

if [ $? -ne 0 ]; then
    echo "Error creating Target Group." >&2
    echo "AWS CLI Error: $tg_json" >&2
    exit 1
fi
TG_ARN=$(echo "$tg_json" | jq -r '.TargetGroupArn')
echo "Target Group created with ARN: $TG_ARN" >&2

# 3. Create a Listener
echo "Creating HTTP Listener for ALB..." >&2
listener_json=$(aws elbv2 create-listener \
    --load-balancer-arn "$ALB_ARN" \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn="$TG_ARN" \
    --query 'Listeners[0]' \
    --output json 2>&1)

if [ $? -ne 0 ]; then
    echo "Error creating Listener." >&2
    echo "AWS CLI Error: $listener_json" >&2
    exit 1
fi
LISTENER_ARN=$(echo "$listener_json" | jq -r '.ListenerArn')
echo "Listener created with ARN: $LISTENER_ARN" >&2

# --- Final Output ---
echo "ALB setup complete." >&2
# Output all created ARNs as a JSON object to stdout
cat <<EOF
{
  "LoadBalancerArn": "$ALB_ARN",
  "TargetGroupArn": "$TG_ARN",
  "ListenerArn": "$LISTENER_ARN"
}
EOF
