#!/bin/bash

# Script to create or update (upsert) a DNS record in Route 53.
# On success, this script produces no output on stdout.
# Usage: ./manage-route53-records.sh --zone-id <id> --name <record_name> --type <type> --value <value>
# Example: ./manage-route53-records.sh --zone-id Z123 --name mail.example.com --type A --value 1.2.3.4
# Example: ./manage-route53-records.sh --zone-id Z123 --name www.example.com --type CNAME --value server.example.com

# --- Argument Parsing ---
ZONE_ID=""
RECORD_NAME=""
RECORD_TYPE=""
RECORD_VALUE=""
TTL=300 # Default TTL

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --zone-id) ZONE_ID="$2"; shift ;;
        --name) RECORD_NAME="$2"; shift ;;
        --type) RECORD_TYPE="$2"; shift ;;
        --value) RECORD_VALUE="$2"; shift ;;
        --ttl) TTL="$2"; shift ;;
        *) echo "Unknown parameter passed: $1" >&2; exit 1 ;;
    esac
    shift
done

# Validate arguments
if [ -z "$ZONE_ID" ] || [ -z "$RECORD_NAME" ] || [ -z "$RECORD_TYPE" ] || [ -z "$RECORD_VALUE" ]; then
  echo "Error: --zone-id, --name, --type, and --value are required." >&2
  exit 1
fi

# --- Main Logic ---
echo "Preparing to upsert record '$RECORD_NAME' of type '$RECORD_TYPE' in zone '$ZONE_ID'..." >&2

# For TXT records, the value needs to be quoted.
if [[ "$RECORD_TYPE" == "TXT" && ! ("$RECORD_VALUE" =~ ^\".*\"$) ]]; then
    # If the type is TXT and the value is not already quoted, quote it.
    RECORD_VALUE="\"$RECORD_VALUE\""
fi

# Construct the change batch JSON
CHANGE_BATCH_JSON=$(cat <<EOF
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$RECORD_NAME",
        "Type": "$RECORD_TYPE",
        "TTL": $TTL,
        "ResourceRecords": [
          {
            "Value": $RECORD_VALUE
          }
        ]
      }
    }
  ]
}
EOF
)

echo "Submitting change to Route 53..." >&2
aws_output=$(aws route53 change-resource-record-sets \
    --hosted-zone-id "$ZONE_ID" \
    --change-batch "$CHANGE_BATCH_JSON" 2>&1)

if [ $? -eq 0 ]; then
    echo "Record set for '$RECORD_NAME' submitted successfully." >&2
else
    echo "Error submitting record set change to Route 53." >&2
    echo "AWS CLI Error: $aws_output" >&2
    exit 1
fi
