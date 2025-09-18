#!/bin/bash

# Script to diagnose the configuration of an S3 bucket for public website hosting.
# Usage: ./check-public-website.sh <BUCKET_NAME>
# Example: ./check-public-website.sh my-website-bucket

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- Helper Functions ---
check_ok() { echo -e "  [${GREEN}OK${NC}] $1"; }
check_fail() { echo -e "  [${RED}FAIL${NC}] $1"; }
info() { echo -e "  - $1"; }

# --- Argument Parsing ---
if [ -z "$1" ]; then
  echo -e "${RED}Error: No bucket name provided.${NC}"
  echo "Usage: $0 <BUCKET_NAME>"
  exit 1
fi
BUCKET_NAME=$1

echo -e "${YELLOW}--- Diagnosing S3 Website Configuration for Bucket: $BUCKET_NAME ---${NC}"

# --- Check 1: Static Website Hosting ---
echo "1. Checking for Static Website Hosting configuration..."
WEBSITE_CONFIG=$(aws s3api get-bucket-website --bucket "$BUCKET_NAME" 2>/dev/null)
if [ -n "$WEBSITE_CONFIG" ]; then
    INDEX_DOC=$(echo "$WEBSITE_CONFIG" | jq -r '.IndexDocument.Suffix')
    check_ok "Static website hosting is ENABLED."
    info "Index Document: $INDEX_DOC"
else
    check_fail "Static website hosting is NOT enabled."
fi

# --- Check 2: Public Access Block ---
echo "2. Checking Public Access Block settings..."
PAB_JSON=$(aws s3api get-public-access-block --bucket "$BUCKET_NAME" 2>/dev/null)
if [ -z "$PAB_JSON" ]; then
    check_ok "No Public Access Block is explicitly set (good)."
else
    IS_BLOCKING=$(echo "$PAB_JSON" | jq '.PublicAccessBlockConfiguration | if .BlockPublicAcls or .IgnorePublicAcls or .BlockPublicPolicy or .RestrictPublicBuckets then "true" else "false" end')
    if [ "$IS_BLOCKING" == "false" ]; then
        check_ok "Public Access Block is configured but does not block public access."
    else
        check_fail "Public Access Block is ENABLED and is blocking public access."
        info "The following settings should be false: $(echo "$PAB_JSON" | jq -c '.PublicAccessBlockConfiguration')"
    fi
fi

# --- Check 3: Bucket Policy ---
echo "3. Checking for a public-read Bucket Policy..."
POLICY_JSON=$(aws s3api get-bucket-policy --bucket "$BUCKET_NAME" --query 'Policy' --output text 2>/dev/null)
if [ -z "$POLICY_JSON" ]; then
    check_fail "No bucket policy found."
else
    PUBLIC_POLICY=$(echo "$POLICY_JSON" | jq '.Statement[] | select(.Effect == "Allow" and (.Principal == "*" or .Principal.AWS == "*") and (.Action == "s3:GetObject" or .Action[] == "s3:GetObject"))')
    if [ -n "$PUBLIC_POLICY" ]; then
        check_ok "A public-read policy statement was found."
    else
        check_fail "No policy statement found allowing public 's3:GetObject'."
        info "The policy must allow Effect='Allow', Principal='*', and Action='s3:GetObject'."
    fi
fi

echo -e "${YELLOW}--- Diagnosis Complete ---${NC}"
