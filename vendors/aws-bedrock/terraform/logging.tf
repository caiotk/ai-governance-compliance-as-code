# ─────────────────────────────────────────────────────────────────────────────
# Model invocation logging: CloudWatch Logs plus S3 (large and binary payloads).
# Invocation logging is off by default, per account and per Region.
# Source: https://docs.aws.amazon.com/bedrock/latest/userguide/model-invocation-logging.html
# ─────────────────────────────────────────────────────────────────────────────

locals {
  log_bucket_name = coalesce(var.log_bucket_name, "${var.name_prefix}-bedrock-logs-${local.account_id}-${var.aws_region}")
  log_group_name  = "/aws/bedrock/${var.name_prefix}/model-invocations"
  log_object_path = var.log_key_prefix == "" ? "AWSLogs/${local.account_id}/BedrockModelInvocationLogs/*" : "${var.log_key_prefix}/AWSLogs/${local.account_id}/BedrockModelInvocationLogs/*"
  bedrock_src_arn = "arn:${local.partition}:bedrock:${var.aws_region}:${local.account_id}:*"
}

# AIG-13 AIG-09
resource "aws_cloudwatch_log_group" "invocations" {
  count = var.enable_invocation_logging ? 1 : 0

  name              = local.log_group_name
  retention_in_days = var.log_retention_days
  kms_key_id        = var.logging_kms_key_arn
}

# AIG-13
resource "aws_s3_bucket" "invocations" {
  count = var.enable_invocation_logging ? 1 : 0

  bucket        = local.log_bucket_name
  force_destroy = var.log_bucket_force_destroy
}

# AIG-13
resource "aws_s3_bucket_ownership_controls" "invocations" {
  count = var.enable_invocation_logging ? 1 : 0

  bucket = aws_s3_bucket.invocations[0].id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# AIG-13 AIG-08
resource "aws_s3_bucket_public_access_block" "invocations" {
  count = var.enable_invocation_logging ? 1 : 0

  bucket                  = aws_s3_bucket.invocations[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# AIG-13
resource "aws_s3_bucket_versioning" "invocations" {
  count = var.enable_invocation_logging ? 1 : 0

  bucket = aws_s3_bucket.invocations[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# AIG-09
resource "aws_s3_bucket_server_side_encryption_configuration" "invocations" {
  count = var.enable_invocation_logging ? 1 : 0

  bucket = aws_s3_bucket.invocations[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.logging_kms_key_arn == null ? "AES256" : "aws:kms"
      kms_master_key_id = var.logging_kms_key_arn
    }
    bucket_key_enabled = var.logging_kms_key_arn != null
  }
}

# AIG-13
# Bucket policy from the Bedrock user guide: only bedrock.amazonaws.com, acting
# for this account and Region, may write under the invocation-log prefix.
# A second statement denies non-TLS access.
data "aws_iam_policy_document" "log_bucket" {
  count = var.enable_invocation_logging ? 1 : 0

  statement {
    sid     = "AmazonBedrockLogsWrite"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
    resources = ["${aws_s3_bucket.invocations[0].arn}/${local.log_object_path}"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [local.bedrock_src_arn]
    }
  }

  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.invocations[0].arn,
      "${aws_s3_bucket.invocations[0].arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

# AIG-13
resource "aws_s3_bucket_policy" "invocations" {
  count = var.enable_invocation_logging ? 1 : 0

  bucket = aws_s3_bucket.invocations[0].id
  policy = data.aws_iam_policy_document.log_bucket[0].json

  depends_on = [aws_s3_bucket_public_access_block.invocations]
}

# AIG-07 AIG-13
# Role Bedrock assumes to deliver logs to CloudWatch Logs. Trust is limited to
# bedrock.amazonaws.com acting for this account and Region (confused-deputy guard).
data "aws_iam_policy_document" "bedrock_logging_trust" {
  count = var.enable_invocation_logging ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [local.bedrock_src_arn]
    }
  }
}

# AIG-07 AIG-13
resource "aws_iam_role" "bedrock_logging" {
  count = var.enable_invocation_logging ? 1 : 0

  name               = "${var.name_prefix}-bedrock-invocation-logging"
  description        = "Lets Amazon Bedrock write model invocation logs to CloudWatch Logs."
  assume_role_policy = data.aws_iam_policy_document.bedrock_logging_trust[0].json
}

# AIG-07 AIG-13
# Least privilege: create and write only the aws/bedrock/modelinvocations stream.
data "aws_iam_policy_document" "bedrock_logging_permissions" {
  count = var.enable_invocation_logging ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.invocations[0].arn}:log-stream:aws/bedrock/modelinvocations"]
  }
}

# AIG-07 AIG-13
resource "aws_iam_role_policy" "bedrock_logging" {
  count = var.enable_invocation_logging ? 1 : 0

  name   = "cloudwatch-logs-delivery"
  role   = aws_iam_role.bedrock_logging[0].id
  policy = data.aws_iam_policy_document.bedrock_logging_permissions[0].json
}

# AIG-13
# Account- and Region-wide setting. Covers Converse, ConverseStream, InvokeModel
# and InvokeModelWithResponseStream through bedrock-runtime (not bedrock-mantle).
resource "aws_bedrock_model_invocation_logging_configuration" "this" {
  count = var.enable_invocation_logging ? 1 : 0

  logging_config {
    text_data_delivery_enabled      = var.log_text_data
    image_data_delivery_enabled     = var.log_image_data
    embedding_data_delivery_enabled = var.log_embedding_data
    video_data_delivery_enabled     = var.log_video_data

    cloudwatch_config {
      log_group_name = aws_cloudwatch_log_group.invocations[0].name
      role_arn       = aws_iam_role.bedrock_logging[0].arn

      large_data_delivery_s3_config {
        bucket_name = aws_s3_bucket.invocations[0].id
        key_prefix  = var.log_key_prefix
      }
    }

    s3_config {
      bucket_name = aws_s3_bucket.invocations[0].id
      key_prefix  = var.log_key_prefix
    }
  }

  depends_on = [
    aws_s3_bucket_policy.invocations,
    aws_iam_role_policy.bedrock_logging,
  ]
}
