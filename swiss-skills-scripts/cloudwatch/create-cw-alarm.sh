#!/bin/bash

# Script to create a CloudWatch alarm.
# On success, this script produces no output on stdout.
# Usage: ./create-cw-alarm.sh --name <ALARM_NAME> --metric <METRIC> --namespace <NAMESPACE> --statistic <STAT> \
#   --period <SECONDS> --evaluation-periods <NUM> --threshold <VALUE> --comparison-operator <OPERATOR> \
#   [--dimensions Name=...,Value=...] [--sns-topic-arn <ARN>]
# Example: ./create-cw-alarm.sh --name "High-CPU-Utilization" --metric CPUUtilization --namespace AWS/EC2 --statistic Average \
#   --period 300 --evaluation-periods 1 --threshold 80 --comparison-operator GreaterThanThreshold \
#   --dimensions Name=InstanceId,Value=i-0123456789

# --- Argument Parsing ---
ALARM_NAME=""
METRIC_NAME=""
NAMESPACE=""
STATISTIC=""
PERIOD=""
EVAL_PERIODS=""
THRESHOLD=""
COMPARISON_OP=""
DIMENSIONS=""
SNS_TOPIC_ARN=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --name) ALARM_NAME="$2"; shift ;;
        --metric) METRIC_NAME="$2"; shift ;;
        --namespace) NAMESPACE="$2"; shift ;;
        --statistic) STATISTIC="$2"; shift ;;
        --period) PERIOD="$2"; shift ;;
        --evaluation-periods) EVAL_PERIODS="$2"; shift ;;
        --threshold) THRESHOLD="$2"; shift ;;
        --comparison-operator) COMPARISON_OP="$2"; shift ;;
        --dimensions) DIMENSIONS="$2"; shift ;;
        --sns-topic-arn) SNS_TOPIC_ARN="$2"; shift ;;
        *) echo "Unknown parameter passed: $1" >&2; exit 1 ;;
    esac
    shift
done

# Basic validation
if [ -z "$ALARM_NAME" ] || [ -z "$METRIC_NAME" ] || [ -z "$NAMESPACE" ] || [ -z "$STATISTIC" ] || [ -z "$PERIOD" ] || [ -z "$EVAL_PERIODS" ] || [ -z "$THRESHOLD" ] || [ -z "$COMPARISON_OP" ]; then
  echo "Error: Missing one or more required arguments." >&2
  exit 1
fi

# --- Main Logic ---
# Build the command dynamically using an array for safety
CLI_ARGS=(
    --alarm-name "$ALARM_NAME"
    --metric-name "$METRIC_NAME"
    --namespace "$NAMESPACE"
    --statistic "$STATISTIC"
    --period "$PERIOD"
    --evaluation-periods "$EVAL_PERIODS"
    --threshold "$THRESHOLD"
    --comparison-operator "$COMPARISON_OP"
)

if [ -n "$DIMENSIONS" ]; then
    CLI_ARGS+=(--dimensions "$DIMENSIONS")
fi

if [ -n "$SNS_TOPIC_ARN" ]; then
    CLI_ARGS+=(--alarm-actions "$SNS_TOPIC_ARN")
fi

echo "Creating alarm '$ALARM_NAME'..." >&2
aws_output=$(aws cloudwatch put-metric-alarm "${CLI_ARGS[@]}" 2>&1)

if [ $? -eq 0 ]; then
    echo "CloudWatch alarm '$ALARM_NAME' created successfully." >&2
else
    echo "Error creating CloudWatch alarm." >&2
    echo "AWS CLI Error: $aws_output" >&2
    exit 1
fi
