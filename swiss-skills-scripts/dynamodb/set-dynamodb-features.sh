#!/bin/bash

# Script to configure various advanced features on a DynamoDB table.
# Usage: ./set-dynamodb-features.sh --table-name <TABLE> [options]
# Options:
#   --enable-ttl --attribute-name <ATTRIBUTE>
#   --enable-autoscaling --min-read <NUM> --max-read <NUM> --min-write <NUM> --max-write <NUM>
#   --enable-deletion-protection
#   --create-backup --backup-name <BACKUP_NAME>

# --- Argument Parsing ---
TABLE_NAME=""
ACTION=""
TTL_ATTRIBUTE=""
MIN_READ=0
MAX_READ=0
MIN_WRITE=0
MAX_WRITE=0
BACKUP_NAME=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --table-name) TABLE_NAME="$2"; shift ;;
        --enable-ttl) ACTION="ttl"; TTL_ATTRIBUTE="$2"; shift ;;
        --enable-autoscaling) ACTION="autoscaling"; ;;
        --min-read) MIN_READ="$2"; shift ;;
        --max-read) MAX_READ="$2"; shift ;;
        --min-write) MIN_WRITE="$2"; shift ;;
        --max-write) MAX_WRITE="$2"; shift ;;
        --enable-deletion-protection) ACTION="protection"; ;;
        --create-backup) ACTION="backup"; BACKUP_NAME="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [ -z "$TABLE_NAME" ] || [ -z "$ACTION" ]; then
  echo "Error: Table name and an action flag are required."
  exit 1
fi

echo "Configuring table '$TABLE_NAME'..."

case $ACTION in
    ttl)
        echo "Enabling TTL on attribute '$TTL_ATTRIBUTE'..."
        aws dynamodb update-time-to-live --table-name "$TABLE_NAME" \
            --time-to-live-specification "Enabled=true, AttributeName=$TTL_ATTRIBUTE"
        ;;
    autoscaling)
        echo "Enabling autoscaling for table '$TABLE_NAME'..."
        echo "Min Read: $MIN_READ, Max Read: $MAX_READ"
        echo "Min Write: $MIN_WRITE, Max Write: $MAX_WRITE"

        if [ "$MIN_READ" -eq 0 ] || [ "$MAX_READ" -eq 0 ] || [ "$MIN_WRITE" -eq 0 ] || [ "$MAX_WRITE" -eq 0 ]; then
            echo "Error: For autoscaling, --min-read, --max-read, --min-write, and --max-write are required."
            exit 1
        fi

        # Register Read Capacity as a scalable target
        aws application-autoscaling register-scalable-target \
            --service-namespace dynamodb \
            --scalable-dimension dynamodb:table:ReadCapacityUnits \
            --resource-id "table/$TABLE_NAME" \
            --min-capacity "$MIN_READ" \
            --max-capacity "$MAX_READ"

        # Define Read Capacity scaling policy
        aws application-autoscaling put-scaling-policy \
            --service-namespace dynamodb \
            --scalable-dimension dynamodb:table:ReadCapacityUnits \
            --resource-id "table/$TABLE_NAME" \
            --policy-name "${TABLE_NAME}-Read-ScalingPolicy" \
            --policy-type TargetTrackingScaling \
            --target-tracking-scaling-policy-configuration '{
                "TargetValue": 70.0,
                "PredefinedMetricSpecification": { "PredefinedMetricType": "DynamoDBReadCapacityUtilization" },
                "ScaleInCooldown": 60,
                "ScaleOutCooldown": 60
            }'

        # Register Write Capacity as a scalable target
        aws application-autoscaling register-scalable-target \
            --service-namespace dynamodb \
            --scalable-dimension dynamodb:table:WriteCapacityUnits \
            --resource-id "table/$TABLE_NAME" \
            --min-capacity "$MIN_WRITE" \
            --max-capacity "$MAX_WRITE"

        # Define Write Capacity scaling policy
        aws application-autoscaling put-scaling-policy \
            --service-namespace dynamodb \
            --scalable-dimension dynamodb:table:WriteCapacityUnits \
            --resource-id "table/$TABLE_NAME" \
            --policy-name "${TABLE_NAME}-Write-ScalingPolicy" \
            --policy-type TargetTrackingScaling \
            --target-tracking-scaling-policy-configuration '{
                "TargetValue": 70.0,
                "PredefinedMetricSpecification": { "PredefinedMetricType": "DynamoDBWriteCapacityUtilization" },
                "ScaleInCooldown": 60,
                "ScaleOutCooldown": 60
            }'
        ;;
    protection)
        echo "Enabling deletion protection..."
        aws dynamodb update-table --table-name "$TABLE_NAME" --deletion-protection-enabled
        ;;
    backup)
        echo "Creating backup '$BACKUP_NAME'..."
        aws dynamodb create-backup --table-name "$TABLE_NAME" --backup-name "$BACKUP_NAME"
        ;;
esac

echo "Operation initiated."
