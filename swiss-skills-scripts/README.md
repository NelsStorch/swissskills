# SwissSkills 2025 - AWS CLI Script Repertoire

This repository contains a powerful, menu-driven shell script suite designed to automate and speed up common AWS tasks for the SwissSkills 2025 Cloud Computing competition.

## Main Usage: The Interactive Launcher

The primary way to use this toolkit is through the interactive main script. It provides a user-friendly, menu-based interface that guides you through every action, and even lets you select existing resources like VPCs and EC2 instances from a dynamic list, reducing errors and saving time.

**To start, simply run:**
```bash
cd swiss-skills-scripts
./main.sh
```

## Available Functionality

The launcher provides a wide range of functions to help you build, diagnose, and manage your AWS environment quickly.

### I. VPC Management
- Create a simple VPC with a specified CIDR and name.
- **Create a complete VPC architecture**, including public/private subnets, an Internet Gateway, a NAT Gateway, and all necessary route tables.
- Create a new Security Group within a chosen VPC and interactively add ingress rules.
- Get detailed information about a selected VPC and its components.
- Inspect the route table associated with a selected subnet.

### II. EC2 Management
- **Launch a new EC2 instance** with a guided selection of VPC, subnet, security group, and IAM role.
- Create an EC2 Launch Template with a specified AMI, instance type, and key pair.
- Get detailed information for a selected running EC2 instance.
- Find the public IP address of an instance by its `Name` tag.
- List all running instances that match a specific tag.
- Display the security group rules for a selected EC2 instance.

### III. S3 Management
- Create a new S3 bucket in a specific region.
- Enable static website hosting on a bucket.
- Apply a public-read bucket policy for website access.
- Configure Cross-Region Replication between two buckets (requires a pre-existing IAM role).
- List the contents of an S3 bucket.

### IV. IAM Management
- Create a new IAM user, with options to generate an access key and add the user to a group.
- Create a new IAM role with a trust policy for EC2.
- Attach a managed policy to a selected IAM role or a user.
- List the policies attached to a specific user.
- Simulate if a user has permission for a specific API action.

### V. Troubleshooting & Diagnosis
- **CloudFormation:** Display the event history for a CloudFormation stack to debug failures.
- **CloudWatch:**
    - Get the latest log events from a selected CloudWatch Log Group.
    - Filter logs in a selected Log Group for a specific pattern.
- **General Utilities:**
    - Find any AWS resource across your account by tag.
    - Get the ARN for common resources like S3 buckets and IAM users/roles.

## Advanced Usage

While `main.sh` is the recommended interface, every function is backed by a standalone, executable script in the corresponding subdirectory (e.g., `vpc/`, `ec2/`). These can be run directly from the command line if you prefer. See the comments within each script for usage instructions.
