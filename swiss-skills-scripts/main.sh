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

    # Select VPC first to filter other resources
    echo "First, select the VPC where the instance will be launched."
    select_vpc
    [ $? -ne 0 ] && press_enter_to_continue && return
    local vpc_id=$SELECTOR_RESULT

    # Select Subnet from the chosen VPC
    echo -e "\nNow, select a subnet from VPC '$vpc_id'."
    select_subnet "$vpc_id"
    [ $? -ne 0 ] && press_enter_to_continue && return
    local subnet_id=$SELECTOR_RESULT

    # Select Security Group from the chosen VPC
    echo -e "\nNow, select a security group from VPC '$vpc_id'."
    select_security_group "$vpc_id"
    [ $? -ne 0 ] && press_enter_to_continue && return
    local sg_id=$SELECTOR_RESULT

    # Select IAM Role (Instance Profile)
    echo -e "\nNow, select an IAM Role (Instance Profile) to attach (optional)."
    select_iam_role
    local iam_profile=""
    if [ $? -eq 0 ]; then
        iam_profile=$SELECTOR_RESULT
    fi

    # Get remaining text-based inputs
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

# CloudFormation Runner
run_get_stack_events() {
    clear; echo -e "${BLUE}--- Get CloudFormation Stack Events ---${NC}"
    read -p "Enter Stack Name: " stack_name
    [ -z "$stack_name" ] && { echo -e "${RED}Stack name is required.${NC}"; press_enter_to_continue; return; }
    ./cloudformation/get-stack-events.sh "$stack_name"
    press_enter_to_continue
}

# CloudWatch Runners
run_get_latest_logs() {
    clear; echo -e "${BLUE}--- Get Latest CloudWatch Logs ---${NC}"
    select_log_group
    [ $? -ne 0 ] && press_enter_to_continue && return
    local log_group=$SELECTOR_RESULT

    read -p "Enter number of lines to show (default 10): " limit

    local args="--log-group-name $log_group"
    if [ -n "$limit" ]; then
        args="$args --limit $limit"
    fi
    ./cloudwatch/get-latest-logs.sh $args
    press_enter_to_continue
}

run_filter_logs() {
    clear; echo -e "${BLUE}--- Filter CloudWatch Logs ---${NC}"
    select_log_group
    [ $? -ne 0 ] && press_enter_to_continue && return
    local log_group=$SELECTOR_RESULT

    read -p "Enter Filter Pattern (e.g., ERROR or '{$.level = \"error\"}'): " pattern
    [ -z "$pattern" ] && { echo -e "${RED}Filter pattern is required.${NC}"; press_enter_to_continue; return; }

    ./cloudwatch/filter-logs.sh --log-group-name "$log_group" --filter-pattern "$pattern"
    press_enter_to_continue
}

# Utility Runners
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


# --- Menus ---
vpc_menu() {
    local options=("Create a simple VPC" "Create a full VPC (Public/Private Subnets, GWs, etc.)" "Create a Security Group and add rules" "Get VPC Info" "Get Subnet's Route Table" "Back to Main Menu")
    while true; do
        clear; echo -e "${YELLOW}--- VPC Management ---${NC}"
        select opt in "${options[@]}"; do
            case $opt in
                "Create a simple VPC") run_create_vpc; break ;;
                "Create a full VPC (Public/Private Subnets, GWs, etc.)") run_create_full_vpc; break ;;
                "Create a Security Group and add rules") run_create_sg; break ;;
                "Get VPC Info") run_get_vpc_info; break ;;
                "Get Subnet's Route Table") run_get_subnet_route_table; break ;;
                "Back to Main Menu") return ;;
                *) echo -e "${RED}Invalid option $REPLY${NC}"; press_enter_to_continue; break ;;
            esac
        done
    done
}

ec2_menu() {
    local options=("Launch EC2 Instance" "Create Launch Template" "Get Instance Details" "Get Instance IP by Name" "List Instances by Tag" "Get Instance Security Groups" "Back to Main Menu")
    while true; do
        clear; echo -e "${YELLOW}--- EC2 Management ---${NC}"
        select opt in "${options[@]}"; do
            case $opt in
                "Launch EC2 Instance") run_launch_ec2; break ;;
                "Create Launch Template") run_create_launch_template; break ;;
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

cloudformation_menu() {
    run_get_stack_events
}

cloudwatch_menu() {
    local options=("Get Latest Logs" "Filter Logs" "Back to Main Menu")
    while true; do
        clear; echo -e "${YELLOW}--- CloudWatch Management ---${NC}"
        select opt in "${options[@]}"; do
            case $opt in
                "Get Latest Logs") run_get_latest_logs; break ;;
                "Filter Logs") run_filter_logs; break ;;
                "Back to Main Menu") return ;;
                *) echo -e "${RED}Invalid option $REPLY${NC}"; press_enter_to_continue; break ;;
            esac
        done
    done
}

utility_menu() {
    local options=("Find Resources by Tag" "Get Resource ARN" "Back to Main Menu")
    while true; do
        clear; echo -e "${YELLOW}--- Utility Scripts ---${NC}"
        select opt in "${options[@]}"; do
            case $opt in
                "Find Resources by Tag") run_find_by_tag; break ;;
                "Get Resource ARN") run_get_arn; break ;;
                "Back to Main Menu") return ;;
                *) echo -e "${RED}Invalid option $REPLY${NC}"; press_enter_to_continue; break ;;
            esac
        done
    done
}

main_menu() {
    local options=("VPC Management" "EC2 Management" "S3 Management" "IAM Management" "CloudFormation Diagnosis" "CloudWatch Logs" "Utilities" "Exit")
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
                "CloudFormation Diagnosis") cloudformation_menu; break ;;
                "CloudWatch Logs") cloudwatch_menu; break ;;
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
