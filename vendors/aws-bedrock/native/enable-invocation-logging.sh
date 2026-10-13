#!/usr/bin/env bash
# AIG-13 AIG-09 AIG-07
# Turns on Amazon Bedrock model invocation logging for one account and Region.
# There is no CloudFormation resource for invocation logging, so this script
# calls PutModelInvocationLoggingConfiguration through the AWS CLI.
#
# It creates (idempotently where the CLI allows):
#   - an S3 bucket: versioned, public access blocked, bucket-owner-enforced,
#     SSE-S3 or SSE-KMS, TLS-only, with the Bedrock write policy from the docs
#   - a CloudWatch log group with a retention period (default 400 days)
#   - an IAM role that bedrock.amazonaws.com assumes to write to the log group
# and then sets the invocation logging configuration.
#
# Source: https://docs.aws.amazon.com/bedrock/latest/userguide/model-invocation-logging.html
#
# Usage:
#   AWS_REGION=ap-southeast-2 ./enable-invocation-logging.sh
# Optional environment variables:
#   NAME_PREFIX (aigov)  LOG_BUCKET  LOG_KEY_PREFIX (bedrock)  RETENTION_DAYS (400)
#   KMS_KEY_ARN (empty = SSE-S3; the key policy must allow bedrock.amazonaws.com
#                kms:GenerateDataKey and logs.<region>.amazonaws.com to use it)
#
# Requires: AWS CLI v2 with a current Bedrock command set, python3.
# Permissions: s3:CreateBucket and Put* bucket configuration, logs:CreateLogGroup,
# logs:PutRetentionPolicy, iam:CreateRole, iam:PutRolePolicy, iam:PassRole,
# bedrock:PutModelInvocationLoggingConfiguration.

set -euo pipefail

: "${AWS_REGION:?Set AWS_REGION}"
NAME_PREFIX="${NAME_PREFIX:-aigov}"
LOG_KEY_PREFIX="${LOG_KEY_PREFIX:-bedrock}"
RETENTION_DAYS="${RETENTION_DAYS:-400}"
KMS_KEY_ARN="${KMS_KEY_ARN:-}"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
PARTITION="$(aws sts get-caller-identity --query Arn --output text | cut -d: -f2)"
LOG_BUCKET="${LOG_BUCKET:-${NAME_PREFIX}-bedrock-logs-${ACCOUNT_ID}-${AWS_REGION}}"
LOG_GROUP="/aws/bedrock/${NAME_PREFIX}/model-invocations"
ROLE_NAME="${NAME_PREFIX}-bedrock-invocation-logging"
SOURCE_ARN="arn:${PARTITION}:bedrock:${AWS_REGION}:${ACCOUNT_ID}:*"
if [[ -n "${LOG_KEY_PREFIX}" ]]; then
  OBJECT_PATH="${LOG_KEY_PREFIX}/AWSLogs/${ACCOUNT_ID}/BedrockModelInvocationLogs/*"
else
  OBJECT_PATH="AWSLogs/${ACCOUNT_ID}/BedrockModelInvocationLogs/*"
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT

echo "==> S3 bucket ${LOG_BUCKET}"
if ! aws s3api head-bucket --bucket "${LOG_BUCKET}" 2>/dev/null; then
  if [[ "${AWS_REGION}" == "us-east-1" ]]; then
    aws s3api create-bucket --bucket "${LOG_BUCKET}" --region "${AWS_REGION}"
  else
    aws s3api create-bucket --bucket "${LOG_BUCKET}" --region "${AWS_REGION}" \
      --create-bucket-configuration "LocationConstraint=${AWS_REGION}"
  fi
fi
aws s3api put-public-access-block --bucket "${LOG_BUCKET}" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
aws s3api put-bucket-ownership-controls --bucket "${LOG_BUCKET}" \
  --ownership-controls 'Rules=[{ObjectOwnership=BucketOwnerEnforced}]'
aws s3api put-bucket-versioning --bucket "${LOG_BUCKET}" \
  --versioning-configuration Status=Enabled

if [[ -n "${KMS_KEY_ARN}" ]]; then
  ENCRYPTION="{\"Rules\":[{\"ApplyServerSideEncryptionByDefault\":{\"SSEAlgorithm\":\"aws:kms\",\"KMSMasterKeyID\":\"${KMS_KEY_ARN}\"},\"BucketKeyEnabled\":true}]}"
else
  ENCRYPTION='{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
fi
aws s3api put-bucket-encryption --bucket "${LOG_BUCKET}" \
  --server-side-encryption-configuration "${ENCRYPTION}"

cat > "${WORKDIR}/bucket-policy.json" <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AmazonBedrockLogsWrite",
      "Effect": "Allow",
      "Principal": { "Service": "bedrock.amazonaws.com" },
      "Action": ["s3:PutObject"],
      "Resource": ["arn:${PARTITION}:s3:::${LOG_BUCKET}/${OBJECT_PATH}"],
      "Condition": {
        "StringEquals": { "aws:SourceAccount": "${ACCOUNT_ID}" },
        "ArnLike": { "aws:SourceArn": "${SOURCE_ARN}" }
      }
    },
    {
      "Sid": "DenyInsecureTransport",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:${PARTITION}:s3:::${LOG_BUCKET}",
        "arn:${PARTITION}:s3:::${LOG_BUCKET}/*"
      ],
      "Condition": { "Bool": { "aws:SecureTransport": "false" } }
    }
  ]
}
JSON
aws s3api put-bucket-policy --bucket "${LOG_BUCKET}" --policy "file://${WORKDIR}/bucket-policy.json"

echo "==> CloudWatch log group ${LOG_GROUP} (retention ${RETENTION_DAYS} days)"
if [[ -n "${KMS_KEY_ARN}" ]]; then
  aws logs create-log-group --log-group-name "${LOG_GROUP}" --kms-key-id "${KMS_KEY_ARN}" 2>/dev/null || true
else
  aws logs create-log-group --log-group-name "${LOG_GROUP}" 2>/dev/null || true
fi
aws logs put-retention-policy --log-group-name "${LOG_GROUP}" --retention-in-days "${RETENTION_DAYS}"

echo "==> IAM role ${ROLE_NAME}"
cat > "${WORKDIR}/trust.json" <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "bedrock.amazonaws.com" },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": { "aws:SourceAccount": "${ACCOUNT_ID}" },
        "ArnLike": { "aws:SourceArn": "${SOURCE_ARN}" }
      }
    }
  ]
}
JSON
cat > "${WORKDIR}/role-policy.json" <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["logs:CreateLogStream", "logs:PutLogEvents"],
      "Resource": "arn:${PARTITION}:logs:${AWS_REGION}:${ACCOUNT_ID}:log-group:${LOG_GROUP}:log-stream:aws/bedrock/modelinvocations"
    }
  ]
}
JSON
if ! aws iam get-role --role-name "${ROLE_NAME}" >/dev/null 2>&1; then
  aws iam create-role --role-name "${ROLE_NAME}" \
    --assume-role-policy-document "file://${WORKDIR}/trust.json" \
    --description "Lets Amazon Bedrock write model invocation logs to CloudWatch Logs."
else
  aws iam update-assume-role-policy --role-name "${ROLE_NAME}" \
    --policy-document "file://${WORKDIR}/trust.json"
fi
aws iam put-role-policy --role-name "${ROLE_NAME}" \
  --policy-name cloudwatch-logs-delivery \
  --policy-document "file://${WORKDIR}/role-policy.json"
ROLE_ARN="arn:${PARTITION}:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"

# New IAM roles can take a few seconds to become assumable.
sleep 10

echo "==> Bedrock invocation logging configuration"
cat > "${WORKDIR}/logging-config.json" <<JSON
{
  "cloudWatchConfig": {
    "logGroupName": "${LOG_GROUP}",
    "roleArn": "${ROLE_ARN}",
    "largeDataDeliveryS3Config": {
      "bucketName": "${LOG_BUCKET}",
      "keyPrefix": "${LOG_KEY_PREFIX}"
    }
  },
  "s3Config": {
    "bucketName": "${LOG_BUCKET}",
    "keyPrefix": "${LOG_KEY_PREFIX}"
  },
  "textDataDeliveryEnabled": true,
  "imageDataDeliveryEnabled": true,
  "embeddingDataDeliveryEnabled": false,
  "videoDataDeliveryEnabled": true
}
JSON
python3 -m json.tool "${WORKDIR}/logging-config.json" >/dev/null

aws bedrock put-model-invocation-logging-configuration \
  --region "${AWS_REGION}" \
  --logging-config "file://${WORKDIR}/logging-config.json"

echo "==> Evidence (AIG-13): current configuration"
aws bedrock get-model-invocation-logging-configuration --region "${AWS_REGION}"
