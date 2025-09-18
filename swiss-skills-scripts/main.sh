#!/bin/bash

# ==============================================================================
# SwissSkills AWS Script Launcher
#
# This script provides an interactive menu to run the various helper scripts
# for AWS resource management.
# ==============================================================================

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Utility Functions ---
press_enter_to_continue() {
    echo ""
    read -p "Press Enter to continue..."
}

# --- Resource Selectors ---
# Global variable to hold the return value of a selector function
SELECTOR_RESULT=""

select_vpc() {
    SELECTOR_RESULT=""
    local vpcs
    vpcs=$(aws ec2 describe-vpcs --query 'Vpcs[*].{ID:VpcId, Name:Tags[?Key==`Name`].Value | [0]}' --output json)
    
    if [ -z "$vpcs" ] || [ "$vpcs" == "[]" ]; then
        echo -e "${RED}No VPCs found.${NC}"
        return 1
    fi
    
    local options=()
    while IFS= read -r line; do
        local id=$(echo "$line" | jq -r '.ID')
        local name=$(echo "$line" | jq -r '.Name')
        [ "$name" == "null" ] && name="-"
        options+=("$id ($name)")
    done < <(echo "$vpcs" | jq -c '.[]')
    
    options+=("Cancel")

    echo -e "${YELLOW}Please select a VPC:${NC}"
    select opt in "${options[@]}"; do
        if [[ "$opt" == "Cancel" ]]; then
            return 1
        elif [ -n "$opt" ]; then
            SELECTOR_RESULT=$(echo "$opt" | awk '{print $1}')
            return 0
        else
            echo -e "${RED}Invalid option. Please try again.${NC}"
        fi
    done
}

select_instance() {
    SELECTOR_RESULT=""
    local instances
    instances=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].{ID:InstanceId, Name:Tags[?Key==`Name`].Value | [0]}' --output json)

    if [ -z "$instances" ] || [ "$instances" == "[]" ]; then
        echo -e "${RED}No running instances found.${NC}"
        return 1
    fi

    local options=()
    while IFS= read -r line; do
        local id=$(echo "$line" | jq -r '.ID')
        local name=$(echo "$line" | jq -r '.Name')
        [ "$name" == "null" ] && name="-"
        options+=("$id ($name)")
    done < <(echo "$instances" | jq -c '.[]')
    
    options+=("Cancel")

    echo -e "${YELLOW}Please select an Instance:${NC}"
    select opt in "${options[@]}"; do
        if [[ "$opt" == "Cancel" ]]; then
            return 1
        elif [ -n "$opt" ]; then
            SELECTOR_RESULT=$(echo "$opt" | awk '{print $1}')
            return 0
        else
            echo -e "${RED}Invalid option. Please try again.${NC}"
        fi
    done
}

select_security_group() {
    SELECTOR_RESULT=""
    local vpc_filter_arg=""
    if [ -n "$1" ]; then
        vpc_filter_arg="--filters Name=vpc-id,Values=$1"
    fi

    local sgs
    sgs=$(aws ec2 describe-security-groups $vpc_filter_arg --query 'SecurityGroups[*].{ID:GroupId, Name:GroupName}' --output json)

    if [ -z "$sgs" ] || [ "$sgs" == "[]" ]; then
        echo -e "${RED}No Security Groups found.${NC}"
        return 1
    fi

    local options=()
    while IFS= read -r line; do
        local id=$(echo "$line" | jq -r '.ID')
        local name=$(echo "$line" | jq -r '.Name')
        options+=("$id ($name)")
    done < <(echo "$sgs" | jq -c '.[]')

    options+=("Cancel")

    echo -e "${YELLOW}Please select a Security Group:${NC}"
    select opt in "${options[@]}"; do
        if [[ "$opt" == "Cancel" ]]; then
            return 1
        elif [ -n "$opt" ]; then
            SELECTOR_RESULT=$(echo "$opt" | awk '{print $1}')
            return 0
        else
            echo -e "${RED}Invalid option. Please try again.${NC}"
        fi
    done
}

select_iam_role() {
    SELECTOR_RESULT=""
    local roles
    roles=$(aws iam list-roles --query 'Roles[*].RoleName' --output json)

    if [ -z "$roles" ] || [ "$roles" == "[]" ]; then
        echo -e "${RED}No IAM Roles found.${NC}"
        return 1
    fi

    local options=()
    while IFS= read -r line; do
        options+=("$line")
    done < <(echo "$roles" | jq -r '.[]')

    options+=("Cancel")

    echo -e "${YELLOW}Please select an IAM Role:${NC}"
    select opt in "${options[@]}"; do
        if [[ "$opt" == "Cancel" ]]; then
            return 1
        elif [ -n "$opt" ]; then
            SELECTOR_RESULT=$opt
            return 0
        else
            echo -e "${RED}Invalid option. Please try again.${NC}"
        fi
    done
}

select_log_group() {
    SELECTOR_RESULT=""
    local groups
    groups=$(aws logs describe-log-groups --query 'logGroups[*].logGroupName' --output json)

    if [ -z "$groups" ] || [ "$groups" == "[]" ]; then
        echo -e "${RED}No CloudWatch Log Groups found.${NC}"
        return 1
    fi

    local options=()
    while IFS= read -r line; do
        options+=("$line")
    done < <(echo "$groups" | jq -r '.[]')

    options+=("Cancel")

    echo -e "${YELLOW}Please select a Log Group:${NC}"
    select opt in "${options[@]}"; do
        if [[ "$opt" == "Cancel" ]]; then
            return 1
        elif [ -n "$opt" ]; then
            SELECTOR_RESULT=$opt
            return 0
        else
            echo -e "${RED}Invalid option. Please try again.${NC}"
        fi
    done
}

select_subnet() {
    SELECTOR_RESULT=""
    local vpc_filter_arg=""
    if [ -n "$1" ]; then
        vpc_filter_arg="--filters Name=vpc-id,Values=$1"
    fi

    local subnets
    subnets=$(aws ec2 describe-subnets $vpc_filter_arg --query 'Subnets[*].{ID:SubnetId, Name:Tags[?Key==`Name`].Value | [0], CIDR:CidrBlock}' --output json)

    if [ -z "$subnets" ] || [ "$subnets" == "[]" ]; then
        echo -e "${RED}No Subnets found.${NC}"
        return 1
    fi

    local options=()
    while IFS= read -r line; do
        local id=$(echo "$line" | jq -r '.ID')
        local name=$(echo "$line" | jq -r '.Name')
        local cidr=$(echo "$line" | jq -r '.CIDR')
        [ "$name" == "null" ] && name="-"
        options+=("$id ($name, $cidr)")
    done < <(echo "$subnets" | jq -c '.[]')

    options+=("Cancel")

    echo -e "${YELLOW}Please select a Subnet:${NC}"
    select opt in "${options[@]}"; do
        if [[ "$opt" == "Cancel" ]]; then
            return 1
        elif [ -n "$opt" ]; then
            SELECTOR_RESULT=$(echo "$opt" | awk '{print $1}')
            return 0
        else
            echo -e "${RED}Invalid option. Please try again.${NC}"
        fi
    done
}

# --- Runner Functions (Parameter gathering and script execution) ---

# --- Advanced Network Runners ---
run_setup_peering() {
    clear; echo -e "${BLUE}--- Setup VPC Peering ---${NC}"
    echo "Select Requester VPC:"
    select_vpc; [ $? -ne 0 ] && press_enter_to_continue && return
    local req_vpc=$SELECTOR_RESULT
    echo "Select Accepter VPC:"
    select_vpc; [ $? -ne 0 ] && press_enter_to_continue && return
    local acc_vpc=$SELECTOR_RESULT
    ./vpc/setup-vpc-peering.sh --requester-vpc-id "$req_vpc" --accepter-vpc-id "$acc_vpc"
    press_enter_to_continue
}

run_create_endpoints() {
    clear; echo -e "${BLUE}--- Create VPC Endpoints for ECS ---${NC}"
    echo "Select the VPC to add endpoints to:"
    select_vpc; [ $? -ne 0 ] && press_enter_to_continue && return
    local vpc_id=$SELECTOR_RESULT
    echo "Select one or more private subnets (press Enter after selection, Ctrl+D to finish):"
    local subnets=()
    while select_subnet "$vpc_id"; do
        subnets+=("$SELECTOR_RESULT")
    done
    [ ${#subnets[@]} -eq 0 ] && { echo -e "${RED}At least one subnet is required.${NC}"; press_enter_to_continue; return; }
    ./vpc/create-vpc-endpoints.sh --vpc-id "$vpc_id" --subnet-ids "${subnets[@]}"
    press_enter_to_continue
}

run_teardown_vpc() {
    clear; echo -e "${BLUE}--- Teardown Full VPC ---${NC}"
    echo -e "${RED}WARNING: This is a destructive action.${NC}"
    read -p "Are you sure you want to continue? (y/n): " choice
    [ "$choice" != "y" ] && return

    read -p "Enter VPC ID: " vpc_id
    read -p "Enter Public Subnet ID: " public_subnet_id
    read -p "Enter Private Subnet ID: " private_subnet_id
    read -p "Enter Internet Gateway ID: " igw_id
    read -p "Enter NAT Gateway ID: " nat_gw_id
    read -p "Enter Public Route Table ID: " public_rt_id
    read -p "Enter Private Route Table ID: " private_rt_id

    [ -z "$vpc_id" ] && { echo "VPC ID is required."; press_enter_to_continue; return; }

    ./vpc/teardown-full-vpc.sh \
        --vpc-id "$vpc_id" \
        --public-subnet-id "$public_subnet_id" \
        --private-subnet-id "$private_subnet_id" \
        --igw-id "$igw_id" \
        --nat-gw-id "$nat_gw_id" \
        --public-rt-id "$public_rt_id" \
        --private-rt-id "$private_rt_id"
    
    press_enter_to_continue
}

# --- Deployment & Config Runners ---
run_deploy_lambda() {
    clear; echo -e "${BLUE}--- Deploy Lambda Function ---${NC}"
    read -p "Enter Function Name: " func_name
    read -p "Enter Runtime (e.g., python3.9): " runtime
    read -p "Enter Handler (e.g., index.handler): " handler
    read -p "Enter path to local code directory: " code_path
    [ -z "$func_name" ] || [ -z "$runtime" ] || [ -z "$handler" ] || [ -z "$code_path" ] && { echo -e "${RED}All parameters are required.${NC}"; press_enter_to_continue; return; }
    ./lambda/deploy-lambda-function.sh --name "$func_name" --runtime "$runtime" --handler "$handler" --path "$code_path"
    press_enter_to_continue
}

run_create_codepipeline() {
    clear; echo -e "${BLUE}--- Create CodePipeline (CodeCommit to S3) ---${NC}"
    read -p "Enter Pipeline Name: " pipe_name
    read -p "Enter CodeCommit Repository Name: " repo_name
    read -p "Enter S3 Bucket Name for artifacts and deployment: " bucket_name
    [ -z "$pipe_name" ] || [ -z "$repo_name" ] || [ -z "$bucket_name" ] && { echo -e "${RED}All parameters are required.${NC}"; press_enter_to_continue; return; }
    ./codepipeline/create-codepipeline.sh --name "$pipe_name" --repo "$repo_name" --bucket "$bucket_name"
    press_enter_to_continue
}

run_configure_ssm() {
    clear; echo -e "${BLUE}--- Configure EC2 via SSM ---${NC}"
    echo "Select the instance to configure:"
    select_instance; [ $? -ne 0 ] && press_enter_to_continue && return
    local inst_id=$SELECTOR_RESULT
    read -p "Enter path to local configuration script to run: " script_path
    [ -z "$script_path" ] && { echo -e "${RED}Script path is required.${NC}"; press_enter_to_continue; return; }
    ./ssm/configure-ec2-instance-ssm.sh --instance-id "$inst_id" --script-path "$script_path"
    press_enter_to_continue
}

run_set_ddb_features() {
    clear; echo -e "${BLUE}--- Set DynamoDB Features ---${NC}"
    read -p "Enter Table Name: " table_name
    [ -z "$table_name" ] && { echo "Table Name is required."; press_enter_to_continue; return; }

    local options=("Enable TTL" "Enable Deletion Protection" "Create Backup" "Cancel")
    select opt in "${options[@]}"; do
        case $opt in
            "Enable TTL")
                read -p "Enter TTL Attribute Name: " ttl_attr
                [ -z "$ttl_attr" ] && { echo "Attribute Name is required."; break; }
                ./dynamodb/set-dynamodb-features.sh --table-name "$table_name" --enable-ttl --attribute-name "$ttl_attr"
                break
                ;;
            "Enable Deletion Protection")
                ./dynamodb/set-dynamodb-features.sh --table-name "$table_name" --enable-deletion-protection
                break
                ;;
            "Create Backup")
                read -p "Enter Backup Name: " backup_name
                [ -z "$backup_name" ] && { echo "Backup Name is required."; break; }
                ./dynamodb/set-dynamodb-features.sh --table-name "$table_name" --create-backup --backup-name "$backup_name"
                break
                ;;
            "Cancel")
                break
                ;;
            *) echo "Invalid option $REPLY";;
        esac
    done
    press_enter_to_continue
}

run_create_cw_alarm() {
    clear; echo -e "${BLUE}--- Create CloudWatch Alarm ---${NC}"
    
    read -p "Enter Alarm Name: " alarm_name
    read -p "Enter Metric Name (e.g., CPUUtilization): " metric_name
    read -p "Enter Namespace (e.g., AWS/EC2): " namespace
    read -p "Enter Statistic (e.g., Average): " statistic
    read -p "Enter Period in seconds (e.g., 300): " period
    read -p "Enter Evaluation Periods (e.g., 1): " eval_periods
    read -p "Enter Threshold (e.g., 80): " threshold
    read -p "Enter Comparison Operator (e.g., GreaterThanThreshold): " comparison_op
    read -p "Enter Dimensions (optional, e.g., Name=InstanceId,Value=i-123): " dimensions
    read -p "Enter SNS Topic ARN for action (optional): " sns_topic_arn

    # Basic validation
    if [ -z "$alarm_name" ] || [ -z "$metric_name" ] || [ -z "$namespace" ] || [ -z "$statistic" ] || [ -z "$period" ] || [ -z "$eval_periods" ] || [ -z "$threshold" ] || [ -z "$comparison_op" ]; then
      echo -e "${RED}Error: Missing one or more required arguments.${NC}"
      press_enter_to_continue
      return
    fi
    
    # Build array of arguments
    local args=(
        --name "$alarm_name"
        --metric "$metric_name"
        --namespace "$namespace"
        --statistic "$statistic"
        --period "$period"
        --evaluation-periods "$eval_periods"
        --threshold "$threshold"
        --comparison-operator "$comparison_op"
    )

    if [ -n "$dimensions" ]; then
        args+=(--dimensions "$dimensions")
    fi

    if [ -n "$sns_topic_arn" ]; then
        args+=(--sns-topic-arn "$sns_topic_arn")
    fi

    ./cloudwatch/create-cw-alarm.sh "${args[@]}"
    press_enter_to_continue
}

run_find_by_tag() {
    clear; echo -e "${BLUE}--- Find Resources by Tag ---${NC}"
    read -p "Enter Tag Key: " tag_key
    read -p "Enter Tag Value: " tag_value
    [ -z "$tag_key" ] || [ -z "$tag_value" ] && { echo -e "${RED}Tag key and value are required.${NC}"; press_enter_to_continue; return; }
    ./utils/find-resources-by-tag.sh --tag-key "$tag_key" --tag-value "$tag_value"
    press_enter_to_continue
}

run_get_arn() {
    clear; echo -e "${BLUE}--- Get Resource ARN ---${NC}"
    echo "Supported types: s3-bucket, iam-user, iam-role"
    read -p "Enter resource type: " res_type
    read -p "Enter resource name/ID: " res_name
    [ -z "$res_type" ] || [ -z "$res_name" ] && { echo -e "${RED}All parameters are required.${NC}"; press_enter_to_continue; return; }
    ./utils/get-arn.sh --type "$res_type" --name "$res_name"
    press_enter_to_continue
}

run_cheat_sheet() {
    clear; echo -e "${BLUE}--- Interactive Cheatsheet ---${NC}"
    read -p "Enter a service/topic (e.g., s3, ec2) or leave blank for usage: " service
    if [ -n "$service" ]; then
        read -p "Enter a sub-topic (e.g., crr, filter): " sub_topic
        ./utils/cheat.sh "$service" "$sub_topic"
    else
        ./utils/cheat.sh
    fi
    press_enter_to_continue
}

# --- Original Runner Functions ---
# VPC Runners
run_create_vpc() {
    clear; echo -e "${BLUE}--- Create a simple VPC ---${NC}"
    read -p "Enter VPC CIDR block (e.g., 10.10.0.0/16): " vpc_cidr
    read -p "Enter a Name tag for the VPC (e.g., MyVPC): " name_tag
    [ -z "$vpc_cidr" ] && { echo -e "${RED}CIDR cannot be empty.${NC}"; press_enter_to_continue; return; }
    ./vpc/create-vpc.sh "$vpc_cidr" "$name_tag"
    press_enter_to_continue
}

run_create_full_vpc() {
    clear; echo -e "${BLUE}--- Create a Full VPC ---${NC}"
    read -p "Enter a Name Prefix (e.g., MyWebApp): " name_prefix
    read -p "Enter VPC CIDR (e.g., 10.0.0.0/16): " vpc_cidr
    read -p "Enter Public Subnet CIDR (e.g., 10.0.1.0/24): " public_cidr
    read -p "Enter Private Subnet CIDR (e.g., 10.0.2.0/24): " private_cidr
    [ -z "$name_prefix" ] || [ -z "$vpc_cidr" ] || [ -z "$public_cidr" ] || [ -z "$private_cidr" ] && { echo -e "${RED}All parameters are required.${NC}"; press_enter_to_continue; return; }
    ./vpc/create-full-vpc.sh --vpc-cidr "$vpc_cidr" --public-subnet-cidr "$public_cidr" --private-subnet-cidr "$private_cidr" --name-prefix "$name_prefix"
    press_enter_to_continue
}

run_create_sg() {
    clear; echo -e "${BLUE}--- Create a Security Group ---${NC}"
    select_vpc
    [ $? -ne 0 ] && press_enter_to_continue && return
    local vpc_id=$SELECTOR_RESULT
    read -p "Enter Group Name: " sg_name
    read -p "Enter Description: " sg_desc
    [ -z "$sg_name" ] || [ -z "$sg_desc" ] && { echo -e "${RED}Name and description are required.${NC}"; press_enter_to_continue; return; }
    ./vpc/create-security-group.sh --group-name "$sg_name" --description "$sg_desc" --vpc-id "$vpc_id"
    press_enter_to_continue
}

run_get_vpc_info() {
    clear; echo -e "${BLUE}--- Get VPC Info ---${NC}"
    select_vpc
    [ $? -ne 0 ] && press_enter_to_continue && return
    local vpc_id=$SELECTOR_RESULT
    ./vpc/get-vpc-info.sh "$vpc_id"
    press_enter_to_continue
}

run_get_subnet_route_table() {
    clear; echo -e "${BLUE}--- Get Subnet's Route Table ---${NC}"
    read -p "Filter subnets by VPC? (y/n): " choice
    local vpc_id=""
    if [[ "$choice" == "y" ]]; then
        select_vpc
        [ $? -ne 0 ] && press_enter_to_continue && return
        vpc_id=$SELECTOR_RESULT
    fi
    select_subnet "$vpc_id"
    [ $? -ne 0 ] && press_enter_to_continue && return
    local subnet_id=$SELECTOR_RESULT
    ./vpc/get-subnet-route-table.sh "$subnet_id"
    press_enter_to_continue
}

# EC2 Runners
run_launch_ec2() {
    clear; echo -e "${BLUE}--- Launch EC2 Instance ---${NC}"
    echo "First, select the VPC where the instance will be launched."
    select_vpc
    [ $? -ne 0 ] && press_enter_to_continue && return
    local vpc_id=$SELECTOR_RESULT
    echo -e "\nNow, select a subnet from VPC '$vpc_id'."
    select_subnet "$vpc_id"
    [ $? -ne 0 ] && press_enter_to_continue && return
    local subnet_id=$SELECTOR_RESULT
    echo -e "\nNow, select a security group from VPC '$vpc_id'."
    select_security_group "$vpc_id"
    [ $? -ne 0 ] && press_enter_to_continue && return
    local sg_id=$SELECTOR_RESULT
    echo -e "\nNow, select an IAM Role (Instance Profile) to attach (optional)."
    select_iam_role
    local iam_profile=""
    if [ $? -eq 0 ]; then
        iam_profile=$SELECTOR_RESULT
    fi
    read -p "Enter AMI ID (e.g., ami-0c55b159cbfafe1f0): " ami_id
    read -p "Enter Instance Type (e.g., t2.micro): " inst_type
    read -p "Enter Key Name: " key_name
    read -p "Enter Name Tag (optional): " name_tag
    [ -z "$ami_id" ] || [ -z "$inst_type" ] || [ -z "$key_name" ] && { echo -e "${RED}AMI ID, Instance Type, and Key Name are required.${NC}"; press_enter_to_continue; return; }
    ./ec2/launch-ec2-instance.sh "$ami_id" "$inst_type" "$key_name" "$sg_id" "$subnet_id" "$name_tag" "$iam_profile"
    press_enter_to_continue
}

run_create_launch_template() {
    clear; echo -e "${BLUE}--- Create Launch Template ---${NC}"
    read -p "Enter Template Name: " tmpl_name
    read -p "Enter AMI ID: " ami_id
    read -p "Enter Instance Type: " inst_type
    read -p "Enter Key Name: " key_name
    read -p "Enter Security Group ID: " sg_id
    [ -z "$tmpl_name" ] || [ -z "$ami_id" ] || [ -z "$inst_type" ] || [ -z "$key_name" ] || [ -z "$sg_id" ] && { echo -e "${RED}All parameters are required.${NC}"; press_enter_to_continue; return; }
    ./ec2/create-launch-template.sh --template-name "$tmpl_name" --ami-id "$ami_id" --instance-type "$inst_type" --key-name "$key_name" --security-group-id "$sg_id"
    press_enter_to_continue
}

run_get_instance_details() {
    clear; echo -e "${BLUE}--- Get Instance Details ---${NC}"
    select_instance
    [ $? -ne 0 ] && press_enter_to_continue && return
    local inst_id=$SELECTOR_RESULT
    ./ec2/get-instance-details.sh "$inst_id"
    press_enter_to_continue
}

run_get_ip_by_name() {
    clear; echo -e "${BLUE}--- Get Instance IP by Name ---${NC}"
    read -p "Enter Instance Name Tag: " name_tag
    [ -z "$name_tag" ] && { echo -e "${RED}Name tag is required.${NC}"; press_enter_to_continue; return; }
    ./ec2/get-instance-ip-by-name.sh "$name_tag"
    press_enter_to_continue
}

run_list_instances_by_tag() {
    clear; echo -e "${BLUE}--- List Instances by Tag ---${NC}"
    read -p "Enter Tag Key: " tag_key
    read -p "Enter Tag Value: " tag_value
    [ -z "$tag_key" ] || [ -z "$tag_value" ] && { echo -e "${RED}Tag key and value are required.${NC}"; press_enter_to_continue; return; }
    ./ec2/list-instances-by-tag.sh --tag-key "$tag_key" --tag-value "$tag_value"
    press_enter_to_continue
}

run_get_instance_sg() {
    clear; echo -e "${BLUE}--- Get Instance Security Groups ---${NC}"
    select_instance
    [ $? -ne 0 ] && press_enter_to_continue && return
    local inst_id=$SELECTOR_RESULT
    ./ec2/get-instance-security-groups.sh "$inst_id"
    press_enter_to_continue
}

# S3 Runners
run_create_s3_bucket() {
    clear; echo -e "${BLUE}--- Create S3 Bucket ---${NC}"
    read -p "Enter Bucket Name: " bucket_name
    read -p "Enter AWS Region (optional, default us-east-1): " region
    [ -z "$bucket_name" ] && { echo -e "${RED}Bucket name is required.${NC}"; press_enter_to_continue; return; }
    ./s3/create-s3-bucket.sh "$bucket_name" "$region"
    press_enter_to_continue
}

run_enable_s3_website() {
    clear; echo -e "${BLUE}--- Enable S3 Static Website Hosting ---${NC}"
    read -p "Enter Bucket Name: " bucket_name
    [ -z "$bucket_name" ] && { echo -e "${RED}Bucket name is required.${NC}"; press_enter_to_continue; return; }
    ./s3/enable-static-website-hosting.sh "$bucket_name"
    press_enter_to_continue
}

run_set_s3_public_policy() {
    clear; echo -e "${BLUE}--- Set S3 Public Read Policy ---${NC}"
    read -p "Enter Bucket Name: " bucket_name
    [ -z "$bucket_name" ] && { echo -e "${RED}Bucket name is required.${NC}"; press_enter_to_continue; return; }
    ./s3/set-public-read-policy.sh "$bucket_name"
    press_enter_to_continue
}

run_setup_s3_crr() {
    clear; echo -e "${BLUE}--- Setup S3 Cross-Region Replication ---${NC}"
    read -p "Enter Source Bucket Name: " source_bucket
    read -p "Enter Destination Bucket Name: " dest_bucket
    read -p "Enter IAM Role ARN for replication: " role_arn
    [ -z "$source_bucket" ] || [ -z "$dest_bucket" ] || [ -z "$role_arn" ] && { echo -e "${RED}All parameters are required.${NC}"; press_enter_to_continue; return; }
    ./s3/setup-cross-region-replication.sh --source-bucket "$source_bucket" --destination-bucket "$dest_bucket" --role-arn "$role_arn"
    press_enter_to_continue
}

run_list_s3_contents() {
    clear; echo -e "${BLUE}--- List S3 Bucket Contents ---${NC}"
    read -p "Enter Bucket Name: " bucket_name
    read -p "Show full details? (y/n): " details_choice
    [ -z "$bucket_name" ] && { echo -e "${RED}Bucket name is required.${NC}"; press_enter_to_continue; return; }
    details_flag=""
    if [[ "$details_choice" == "y" ]]; then
        details_flag="--details"
    fi
    ./s3/list-bucket-contents.sh "$bucket_name" "$details_flag"
    press_enter_to_continue
}

# IAM Runners
run_create_iam_user() {
    clear; echo -e "${BLUE}--- Create IAM User ---${NC}"
    read -p "Enter User Name: " user_name
    read -p "Create access key? (y/n): " key_choice
    read -p "Add to group? (Enter group name or leave blank): " group_name
    [ -z "$user_name" ] && { echo -e "${RED}User name is required.${NC}"; press_enter_to_continue; return; }
    args="--user-name $user_name"
    if [[ "$key_choice" == "y" ]]; then
        args="$args --create-access-key"
    fi
    if [ -n "$group_name" ]; then
        args="$args --group $group_name"
    fi
    ./iam/create-iam-user.sh $args
    press_enter_to_continue
}

run_create_iam_role() {
    clear; echo -e "${BLUE}--- Create IAM Role for EC2 ---${NC}"
    read -p "Enter Role Name: " role_name
    [ -z "$role_name" ] && { echo -e "${RED}Role name is required.${NC}"; press_enter_to_continue; return; }
    ./iam/create-iam-role.sh "$role_name"
    press_enter_to_continue
}

run_attach_iam_policy() {
    clear; echo -e "${BLUE}--- Attach IAM Policy ---${NC}"
    read -p "Enter Policy ARN: " policy_arn
    [ -z "$policy_arn" ] && { echo -e "${RED}Policy ARN is required.${NC}"; press_enter_to_continue; return; }
    read -p "Attach to user or role? (user/role): " target_type
    local args="--policy-arn $policy_arn"
    if [[ "$target_type" == "user" ]]; then
        read -p "Enter User Name: " user_name
        [ -z "$user_name" ] && { echo -e "${RED}User name is required.${NC}"; press_enter_to_continue; return; }
        args="$args --user-name $user_name"
    elif [[ "$target_type" == "role" ]]; then
        select_iam_role
        [ $? -ne 0 ] && press_enter_to_continue && return
        local role_name=$SELECTOR_RESULT
        args="$args --role-name $role_name"
    else
        echo -e "${RED}Invalid target type.${NC}"; press_enter_to_continue; return;
    fi
    ./iam/attach-policy.sh $args
    press_enter_to_continue
}

run_get_user_policies() {
    clear; echo -e "${BLUE}--- Get User Policies ---${NC}"
    read -p "Enter User Name: " user_name
    [ -z "$user_name" ] && { echo -e "${RED}User name is required.${NC}"; press_enter_to_continue; return; }
    ./iam/get-user-policies.sh "$user_name"
    press_enter_to_continue
}

run_simulate_permission() {
    clear; echo -e "${BLUE}--- Simulate IAM Permission ---${NC}"
    read -p "Enter User ARN to test: " user_arn
    read -p "Enter Action to test (e.g., s3:GetObject): " action
    read -p "Enter Resource ARN to test against: " resource_arn
    [ -z "$user_arn" ] || [ -z "$action" ] || [ -z "$resource_arn" ] && { echo -e "${RED}All parameters are required.${NC}"; press_enter_to_continue; return; }
    ./iam/simulate-permission.sh --user-arn "$user_arn" --action "$action" --resource-arn "$resource_arn"
    press_enter_to_continue
}

# Diagnostic Runners
run_diagnose_ec2() {
    clear; echo -e "${BLUE}--- Diagnose EC2 Connectivity ---${NC}"
    select_instance
    [ $? -ne 0 ] && press_enter_to_continue && return
    local inst_id=$SELECTOR_RESULT
    ./ec2/diagnose-connectivity.sh "$inst_id"
    press_enter_to_continue
}

run_check_s3_website() {
    clear; echo -e "${BLUE}--- Check S3 Public Website Config ---${NC}"
    read -p "Enter Bucket Name to check: " bucket_name
    [ -z "$bucket_name" ] && { echo -e "${RED}Bucket name is required.${NC}"; press_enter_to_continue; return; }
    ./s3/check-public-website.sh "$bucket_name"
    press_enter_to_continue
}

run_check_iam_trust() {
    clear; echo -e "${BLUE}--- Check IAM Role Trust Policy ---${NC}"
    select_iam_role
    [ $? -ne 0 ] && press_enter_to_continue && return
    local role_name=$SELECTOR_RESULT
    ./iam/check-role-trust.sh "$role_name"
    press_enter_to_continue
}

run_find_cfn_failure() {
    clear; echo -e "${BLUE}--- Find CloudFormation Failure Event ---${NC}"
    read -p "Enter Stack Name: " stack_name
    [ -z "$stack_name" ] && { echo -e "${RED}Stack name is required.${NC}"; press_enter_to_continue; return; }
    ./cloudformation/find-failed-resource.sh "$stack_name"
    press_enter_to_continue
}

# --- Menus ---
vpc_menu() {
    local options=("Create a simple VPC" "Create a full VPC" "Teardown a full VPC" "Setup VPC Peering" "Create VPC Endpoints for ECS" "Create a Security Group" "Get VPC Info" "Get Subnet's Route Table" "Back to Main Menu")
    while true; do
        clear; echo -e "${YELLOW}--- VPC Management ---${NC}"
        select opt in "${options[@]}"; do
            case $opt in
                "Create a simple VPC") run_create_vpc; break ;;
                "Create a full VPC") run_create_full_vpc; break ;;
                "Teardown a full VPC") run_teardown_vpc; break ;;
                "Setup VPC Peering") run_setup_peering; break ;;
                "Create VPC Endpoints for ECS") run_create_endpoints; break ;;
                "Create a Security Group") run_create_sg; break ;;
                "Get VPC Info") run_get_vpc_info; break ;;
                "Get Subnet's Route Table") run_get_subnet_route_table; break ;;
                "Back to Main Menu") return ;;
                *) echo -e "${RED}Invalid option $REPLY${NC}"; press_enter_to_continue; break ;;
            esac
        done
    done
}

ec2_menu() {
    local options=("Launch EC2 Instance" "Create Launch Template" "Configure EC2 via SSM" "Get Instance Details" "Get Instance IP by Name" "List Instances by Tag" "Get Instance Security Groups" "Back to Main Menu")
    while true; do
        clear; echo -e "${YELLOW}--- EC2 Management ---${NC}"
        select opt in "${options[@]}"; do
            case $opt in
                "Launch EC2 Instance") run_launch_ec2; break ;;
                "Create Launch Template") run_create_launch_template; break ;;
                "Configure EC2 via SSM") run_configure_ssm; break ;;
                "Get Instance Details") run_get_instance_details; break ;;
                "Get Instance IP by Name") run_get_ip_by_name; break ;;
                "List Instances by Tag") run_list_instances_by_tag; break ;;
                "Get Instance Security Groups") run_get_instance_sg; break ;;
                "Back to Main Menu") return ;;
                *) echo -e "${RED}Invalid option $REPLY${NC}"; press_enter_to_continue; break ;;
            esac
        done
    done
}

s3_menu() {
    local options=("Create S3 Bucket" "Enable Static Website Hosting" "Set Public Read Policy" "Setup Cross-Region Replication" "List Bucket Contents" "Back to Main Menu")
    while true; do
        clear; echo -e "${YELLOW}--- S3 Management ---${NC}"
        select opt in "${options[@]}"; do
            case $opt in
                "Create S3 Bucket") run_create_s3_bucket; break ;;
                "Enable Static Website Hosting") run_enable_s3_website; break ;;
                "Set Public Read Policy") run_set_s3_public_policy; break ;;
                "Setup Cross-Region Replication") run_setup_s3_crr; break ;;
                "List Bucket Contents") run_list_s3_contents; break ;;
                "Back to Main Menu") return ;;
                *) echo -e "${RED}Invalid option $REPLY${NC}"; press_enter_to_continue; break ;;
            esac
        done
    done
}

iam_menu() {
    local options=("Create IAM User" "Create IAM Role for EC2" "Attach IAM Policy" "Get User Policies" "Simulate IAM Permission" "Back to Main Menu")
    while true; do
        clear; echo -e "${YELLOW}--- IAM Management ---${NC}"
        select opt in "${options[@]}"; do
            case $opt in
                "Create IAM User") run_create_iam_user; break ;;
                "Create IAM Role for EC2") run_create_iam_role; break ;;
                "Attach IAM Policy") run_attach_iam_policy; break ;;
                "Get User Policies") run_get_user_policies; break ;;
                "Simulate IAM Permission") run_simulate_permission; break ;;
                "Back to Main Menu") return ;;
                *) echo -e "${RED}Invalid option $REPLY${NC}"; press_enter_to_continue; break ;;
            esac
        done
    done
}

deployment_menu() {
    local options=("Deploy Lambda Function" "Create CodePipeline (CodeCommit->S3)" "Back to Main Menu")
    while true; do
        clear; echo -e "${YELLOW}--- Deployment & CI/CD ---${NC}"
        select opt in "${options[@]}"; do
            case $opt in
                "Deploy Lambda Function") run_deploy_lambda; break ;;
                "Create CodePipeline (CodeCommit->S3)") run_create_codepipeline; break ;;
                "Back to Main Menu") return ;;
                *) echo -e "${RED}Invalid option $REPLY${NC}"; press_enter_to_continue; break ;;
            esac
        done
    done
}

advanced_config_menu() {
    local options=("Set DynamoDB Features" "Create CloudWatch Alarm" "Back to Main Menu")
    while true; do
        clear; echo -e "${YELLOW}--- Advanced Configuration ---${NC}"
        select opt in "${options[@]}"; do
            case $opt in
                "Set DynamoDB Features") run_set_ddb_features; break ;;
                "Create CloudWatch Alarm") run_create_cw_alarm; break ;;
                "Back to Main Menu") return ;;
                *) echo -e "${RED}Invalid option $REPLY${NC}"; press_enter_to_continue; break ;;
            esac
        done
    done
}

diagnostics_menu() {
    local options=("Diagnose EC2 Connectivity" "Check S3 Public Website Config" "Check IAM Role Trust Policy" "Find CloudFormation Failure Event" "Back to Main Menu")
    while true; do
        clear; echo -e "${YELLOW}--- Diagnostic Scripts ---${NC}"
        select opt in "${options[@]}"; do
            case $opt in
                "Diagnose EC2 Connectivity") run_diagnose_ec2; break ;;
                "Check S3 Public Website Config") run_check_s3_website; break ;;
                "Check IAM Role Trust Policy") run_check_iam_trust; break ;;
                "Find CloudFormation Failure Event") run_find_cfn_failure; break ;;
                "Back to Main Menu") return ;;
                *) echo -e "${RED}Invalid option $REPLY${NC}"; press_enter_to_continue; break ;;
            esac
        done
    done
}

utility_menu() {
    local options=("Find Resources by Tag" "Get Resource ARN" "Interactive Cheatsheet" "Back to Main Menu")
    while true; do
        clear; echo -e "${YELLOW}--- Utility Scripts ---${NC}"
        select opt in "${options[@]}"; do
            case $opt in
                "Find Resources by Tag") run_find_by_tag; break ;;
                "Get Resource ARN") run_get_arn; break ;;
                "Interactive Cheatsheet") run_cheat_sheet; break ;;
                "Back to Main Menu") return ;;
                *) echo -e "${RED}Invalid option $REPLY${NC}"; press_enter_to_continue; break ;;
            esac
        done
    done
}

main_menu() {
    local options=(
        "VPC Management" 
        "EC2 Management" 
        "S3 Management" 
        "IAM Management" 
        "Deployment & CI/CD"
        "Advanced Configuration"
        "Diagnostics" 
        "Utilities" 
        "Exit"
    )
    while true; do
        clear
        echo -e "${YELLOW}===== SwissSkills AWS Script Launcher =====${NC}"
        echo "Select a category:"
        select opt in "${options[@]}"; do
            case $opt in
                "VPC Management") vpc_menu; break ;;
                "EC2 Management") ec2_menu; break ;;
                "S3 Management") s3_menu; break ;;
                "IAM Management") iam_menu; break ;;
                "Deployment & CI/CD") deployment_menu; break ;;
                "Advanced Configuration") advanced_config_menu; break ;;
                "Diagnostics") diagnostics_menu; break ;;
                "Utilities") utility_menu; break ;;
                "Exit") exit 0 ;;
                *) echo -e "${RED}Invalid option $REPLY${NC}"; press_enter_to_continue; break ;;
            esac
        done
    done
}

# --- Script Start ---
# Change to the script's directory to ensure relative paths work
cd "$(dirname "$0")" || exit
main_menu
