#!/bin/bash

# An interactive cheatsheet for common/complex AWS CLI commands.
# Usage: ./cheat.sh [SERVICE] [SUB_TOPIC]
# Example: ./cheat.sh s3 crr

# --- Color Definitions ---
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
RED='\033[0;31m'

# --- Show Functions ---
show_s3_crr() {
    echo -e "${YELLOW}--- S3 Cross-Region Replication (put-bucket-replication) ---${NC}"
    echo "aws s3api put-bucket-replication --bucket <SOURCE_BUCKET> --replication-configuration '{
        \"Role\": \"arn:aws:iam::<ACCOUNT_ID>:role/<REPLICATION_ROLE>\",
        \"Rules\": [ { \"ID\": \"ReplicateAll\", \"Status\": \"Enabled\", \"Priority\": 1, \"DeleteMarkerReplication\": { \"Status\": \"Disabled\" }, \"Filter\" : { \"Prefix\": \"\"}, \"Destination\": { \"Bucket\": \"arn:aws:s3:::<DESTINATION_BUCKET>\" } } ]
    }'"
}

show_cfn_wait() {
    echo -e "${YELLOW}--- CloudFormation Wait Conditions ---${NC}"
    echo "aws cloudformation wait stack-create-complete --stack-name <STACK_NAME>"
    echo "aws cloudformation wait stack-update-complete --stack-name <STACK_NAME>"
    echo "aws cloudformation wait stack-delete-complete --stack-name <STACK_NAME>"
}

show_iam_policy() {
    echo -e "${YELLOW}--- Basic IAM Policy Structure ---${NC}"
    echo '{
        "Version": "2012-10-17",
        "Statement": [ { "Effect": "Allow", "Action": ["s3:GetObject"], "Resource": "arn:aws:s3:::<BUCKET_NAME>/*" } ]
    }'
}

show_ec2_filter() {
    echo -e "${YELLOW}--- Filtering EC2 Instances by Tag ---${NC}"
    echo "aws ec2 describe-instances --filters \"Name=tag:<TAG_KEY>,Values=<TAG_VALUE>\""
}

show_ssm_run() {
    echo -e "${YELLOW}--- SSM Run Command (AWS-RunShellScript) ---${NC}"
    echo "aws ssm send-command \\
    --instance-ids <INSTANCE_ID> \\
    --document-name \"AWS-RunShellScript\" \\
    --parameters '{\"commands\":[\"your_command_here\"]}'"
}

show_lambda_create() {
    echo -e "${YELLOW}--- Lambda Create Function ---${NC}"
    echo "aws lambda create-function \\
    --function-name <FUNCTION_NAME> \\
    --runtime <RUNTIME> \\
    --role <ROLE_ARN> \\
    --handler <HANDLER> \\
    --zip-file fileb://<PATH_TO_ZIP>"
}

show_vpc_peering() {
    echo -e "${YELLOW}--- VPC Peering ---${NC}"
    echo "# Step 1: Create the connection"
    echo "aws ec2 create-vpc-peering-connection --vpc-id <REQUESTER_VPC> --peer-vpc-id <ACCEPTER_VPC>"
    echo "# Step 2: Accept the connection"
    echo "aws ec2 accept-vpc-peering-connection --vpc-peering-connection-id <PEERING_ID>"
    echo "# Step 3: Add routes to both VPCs"
    echo "aws ec2 create-route --route-table-id <REQUESTER_RT_ID> --destination-cidr-block <ACCEPTER_CIDR> --vpc-peering-connection-id <PEERING_ID>"
    echo "aws ec2 create-route --route-table-id <ACCEPTER_RT_ID> --destination-cidr-block <REQUESTER_CIDR> --vpc-peering-connection-id <PEERING_ID>"
}

show_codepipeline_create() {
    echo -e "${YELLOW}--- CodePipeline Create Pipeline ---${NC}"
    echo "# Creates a pipeline from a JSON file. Use a template and 'sed' to fill in placeholders."
    echo "aws codepipeline create-pipeline --cli-input-json file://<PATH_TO_PIPELINE.json>"
}

# --- Main Logic ---
SERVICE=$1
SUB_TOPIC=$2

if [ -z "$SERVICE" ]; then
    echo "Usage: $0 [SERVICE] [SUB_TOPIC]"
    echo ""
    echo "Available services:"
    echo "  s3, ec2, iam, cfn, ssm, lambda, vpc, codepipeline"
    exit 0
fi

case $SERVICE in
    s3)
        case $SUB_TOPIC in
            crr) show_s3_crr ;;
            *) echo -e "${RED}Unknown sub-topic for s3. Available: crr${NC}" ;;
        esac
        ;;
    ec2)
        case $SUB_TOPIC in
            filter) show_ec2_filter ;;
            *) echo -e "${RED}Unknown sub-topic for ec2. Available: filter${NC}" ;;
        esac
        ;;
    iam)
        case $SUB_TOPIC in
            policy) show_iam_policy ;;
            *) echo -e "${RED}Unknown sub-topic for iam. Available: policy${NC}" ;;
        esac
        ;;
    cfn)
        case $SUB_TOPIC in
            wait) show_cfn_wait ;;
            *) echo -e "${RED}Unknown sub-topic for cfn. Available: wait${NC}" ;;
        esac
        ;;
    ssm)
        case $SUB_TOPIC in
            run) show_ssm_run ;;
            *) echo -e "${RED}Unknown sub-topic for ssm. Available: run${NC}" ;;
        esac
        ;;
    lambda)
        case $SUB_TOPIC in
            create) show_lambda_create ;;
            *) echo -e "${RED}Unknown sub-topic for lambda. Available: create${NC}" ;;
        esac
        ;;
    vpc)
        case $SUB_TOPIC in
            peering) show_vpc_peering ;;
            *) echo -e "${RED}Unknown sub-topic for vpc. Available: peering${NC}" ;;
        esac
        ;;
    codepipeline)
        case $SUB_TOPIC in
            create) show_codepipeline_create ;;
            *) echo -e "${RED}Unknown sub-topic for codepipeline. Available: create${NC}" ;;
        esac
        ;;
    *)
        echo -e "${RED}Unknown service: $SERVICE${NC}"
        exit 1
        ;;
esac
