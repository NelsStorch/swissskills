#!/bin/bash

# Script to configure various advanced features on a DynamoDB table.
# Usage: ./set-dynamodb-features.sh --table-name <TABLE> [options]
# Options:
#   --enable-ttl --attribute-name <ATTRIBUTE>
#   --enable-autoscaling --min-read <NUM> --max-read <NUM> --min-write <NUM> --max-write <NUM>
#   --enable-deletion-protection
#   --create-backup --backup-name <BACKUP_NAME> (Outputs Backup ARN on success)

# --- Argument Parsing ---
TABLE_NAME=""
ACTION=""
TTL_ATTRIBUTE=""
MIN_READ=0
MAX_READ=0
MIN_WRITE=0
MAX_WRITE=0
BACKUP_NAME=""

# A bit of a hacky way to parse dependent arguments
for arg in "$@"; do
    case $arg in
        --enable-ttl) ACTION="ttl" ;;
        --enable-autoscaling) ACTION="autoscaling" ;;
        --enable-deletion-protection) ACTION="protection" ;;
        --create-backup) ACTION="backup" ;;
    esac
done

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --table-name) TABLE_NAME="$2"; shift ;;
        --attribute-name) TTL_ATTRIBUTE="$2"; shift ;;
        --min-read) MIN_READ="$2"; shift ;;
        --max-read) MAX_READ="$2"; shift ;;
        --min-write) MIN_WRITE="$2"; shift ;;
        --max-write) MAX_WRITE="$2"; shift ;;
        --backup-name) BACKUP_NAME="$2"; shift ;;
        # Ignore action flags we already processed
        --enable-ttl|--enable-autoscaling|--enable-deletion-protection|--create-backup) ;;
        *) echo "Unknown parameter passed: $1" >&2; exit 1 ;;
    esac
    shift
done

if [ -z "$TABLE_NAME" ] || [ -z "$ACTION" ]; then
  echo "Error: --table-name and an action flag are required." >&2
  exit 1
fi

echo "Configuring table '$TABLE_NAME'..." >&2

case $ACTION in
    ttl)
        if [ -z "$TTL_ATTRIBUTE" ]; then echo "Error: --attribute-name is required for TTL." >&2; exit 1; fi
        echo "Enabling TTL on attribute '$TTL_ATTRIBUTE'..." >&2
        aws dynamodb update-time-to-live --table-name "$TABLE_NAME" \
            --time-to-live-specification "Enabled=true, AttributeName=$TTL_ATTRIBUTE" >/dev/null
        ;;
    autoscaling)
        echo "Enabling autoscaling for table '$TABLE_NAME'..." >&2
        if [ "$MIN_READ" -eq 0 ] || [ "$MAX_READ" -eq 0 ] || [ "$MIN_WRITE" -eq 0 ] || [ "$MAX_WRITE" -eq 0 ]; then
            echo "Error: For autoscaling, --min-read, --max-read, --min-write, and --max-write are required." >&2; exit 1; fi

        aws application-autoscaling register-scalable-target --service-namespace dynamodb --scalable-dimension dynamodb:table:ReadCapacityUnits --resource-id "table/$TABLE_NAME" --min-capacity "$MIN_READ" --max-capacity "$MAX_READ" >/dev/null
        aws application-autoscaling put-scaling-policy --service-namespace dynamodb --scalable-dimension dynamodb:table:ReadCapacityUnits --resource-id "table/$TABLE_NAME" --policy-name "${TABLE_NAME}-Read-ScalingPolicy" --policy-type TargetTrackingScaling --target-tracking-scaling-policy-configuration '{"TargetValue":70.0,"PredefinedMetricSpecification":{"PredefinedMetricType":"DynamoDBReadCapacityUtilization"}}' >/dev/null
        aws application-autoscaling register-scalable-target --service-namespace dynamodb --scalable-dimension dynamodb:table:WriteCapacityUnits --resource-id "table/$TABLE_NAME" --min-capacity "$MIN_WRITE" --max-capacity "$MAX_WRITE" >/dev/null
        aws application-autoscaling put-scaling-policy --service-namespace dynamodb --scalable-dimension dynamodb:table:WriteCapacityUnits --resource-id "table/$TABLE_NAME" --policy-name "${TABLE_NAME}-Write-ScalingPolicy" --policy-type TargetTrackingScaling --target-tracking-scaling-policy-configuration '{"TargetValue":70.0,"PredefinedMetricSpecification":{"PredefinedMetricType":"DynamoDBWriteCapacityUtilization"}}' >/dev/null
        ;;
    protection)
        echo "Enabling deletion protection..." >&2
        aws dynamodb update-table --table-name "$TABLE_NAME" --deletion-protection-enabled >/dev/null
        ;;
    backup)
        if [ -z "$BACKUP_NAME" ]; then echo "Error: --backup-name is required for backup." >&2; exit 1; fi
        echo "Creating backup '$BACKUP_NAME'..." >&2
        backup_arn=$(aws dynamodb create-backup --table-name "$TABLE_NAME" --backup-name "$BACKUP_NAME" --query 'BackupDetails.BackupArn' --output text 2>&1)
        if [ $? -ne 0 ]; then echo "Error creating backup. AWS Error: $backup_arn" >&2; exit 1; fi
        echo "$backup_arn" # Output ARN to stdout
        ;;
esac

if [ $? -eq 0 ]; then
    echo "Operation initiated successfully." >&2
else
    echo "An error occurred during the operation." >&2
    exit 1
fi
