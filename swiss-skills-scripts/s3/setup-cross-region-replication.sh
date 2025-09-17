#!/bin/bash

# Script to configure Cross-Region Replication (CRR) for an S3 bucket.
# Assumes the destination bucket and a suitable IAM role already exist.
# Usage: ./setup-cross-region-replication.sh --source-bucket <BUCKET> --destination-bucket <BUCKET> --role-arn <ARN>
# Example: ./setup-cross-region-replication.sh --source-bucket my-source-bucket-us --destination-bucket my-dest-bucket-eu --role-arn arn:aws:iam::123456789012:role/S3-Replication-Role

# Initialize variables
SOURCE_BUCKET=""
DEST_BUCKET=""
ROLE_ARN=""

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --source-bucket) SOURCE_BUCKET="$2"; shift ;;
        --destination-bucket) DEST_BUCKET="$2"; shift ;;
        --role-arn) ROLE_ARN="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Validate arguments
if [ -z "$SOURCE_BUCKET" ] || [ -z "$DEST_BUCKET" ] || [ -z "$ROLE_ARN" ]; then
  echo "Error: All arguments are required."
  echo "Usage: $0 --source-bucket <BUCKET> --destination-bucket <BUCKET> --role-arn <ARN>"
  exit 1
fi

# Step 1: Enable versioning on the source bucket
echo "Enabling versioning on source bucket '$SOURCE_BUCKET'..."
aws s3api put-bucket-versioning --bucket "$SOURCE_BUCKET" --versioning-configuration Status=Enabled
if [ $? -ne 0 ]; then echo "Error enabling versioning on source bucket. Exiting."; exit 1; fi

# Step 2: Enable versioning on the destination bucket
echo "Enabling versioning on destination bucket '$DEST_BUCKET'..."
aws s3api put-bucket-versioning --bucket "$DEST_BUCKET" --versioning-configuration Status=Enabled
if [ $? -ne 0 ]; then echo "Error enabling versioning on destination bucket. Exiting."; exit 1; fi

echo "Versioning enabled on both buckets."

# Step 3: Define the replication configuration
REPLICATION_CONFIG=$(cat <<EOF
{
    "Role": "$ROLE_ARN",
    "Rules": [
        {
            "ID": "ReplicateAll",
            "Priority": 1,
            "Status": "Enabled",
            "DeleteMarkerReplication": { "Status": "Disabled" },
            "Filter" : { "Prefix": ""},
            "Destination": {
                "Bucket": "arn:aws:s3:::$DEST_BUCKET"
            }
        }
    ]
}
EOF
)

# Step 4: Apply the replication configuration
echo "Applying replication configuration to source bucket..."
aws s3api put-bucket-replication --bucket "$SOURCE_BUCKET" --replication-configuration "$REPLICATION_CONFIG"

if [ $? -eq 0 ]; then
    echo "Cross-Region Replication configured successfully from '$SOURCE_BUCKET' to '$DEST_BUCKET'."
else
    echo "Error applying replication configuration. Please check the role permissions and bucket policies."
    exit 1
fi

echo "Script finished."
