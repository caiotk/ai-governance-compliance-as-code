# ─────────────────────────────────────────────────────────────────────────────
# AI FinOps on AWS / Amazon Bedrock — AIG-22 budgets and token alarms, AIG-13.
#
# Verified 2026-10-13 (docs/sources/finops-tooling.md §3.3–3.4, finops-bcp-dr.md §1.4):
#   aws_budgets_budget: budget_type COST, limit_amount/limit_unit, time_unit MONTHLY,
#   cost_filter {name = "Service" | "TagKeyValue"}, notification {comparison_operator,
#   threshold, threshold_type PERCENTAGE, notification_type ACTUAL|FORECASTED,
#   subscriber_email_addresses}.
#   aws_cloudwatch_metric_alarm on namespace AWS/Bedrock: InputTokenCount,
#   OutputTokenCount, InvocationThrottles, Invocations; dimension ModelId.
#   aws_bedrock_inference_profile: model_source.copy_from, name, description, tags —
#   application inference profiles carry cost-allocation tags into Cost Explorer/CUR.
# UNVERIFIED: the exact Cost Explorer "Service" strings for Bedrock model usage and
# the TagKeyValue value format — see variables.tf; tag-based allocation is the
# reliable path (cost per application inference profile).
# ─────────────────────────────────────────────────────────────────────────────

locals {
  tags = merge(var.tags, { (var.cost_allocation_tag) = var.workload_id, "aigov-control" = "AIG-22" })
}

# AIG-22 AIG-02
# Application inference profile: per-workload cost tracking and tagging.
resource "aws_bedrock_inference_profile" "workload" {
  name        = "aigov-${var.workload_id}"
  description = "Application inference profile for workload ${var.workload_id} (cost allocation)."
  tags        = local.tags

  model_source {
    copy_from = var.foundation_model_arn
  }
}

# AIG-22 AIG-16
resource "aws_sns_topic" "finops" {
  name = "aigov-${var.workload_id}-finops"
  tags = local.tags
}

resource "aws_sns_topic_subscription" "email" {
  for_each  = toset(var.subscriber_emails)
  topic_arn = aws_sns_topic.finops.arn
  protocol  = "email"
  endpoint  = each.value
}

# AIG-22
# Monthly budget for Bedrock spend in this account (Service filter — see UNVERIFIED note).
resource "aws_budgets_budget" "bedrock" {
  name         = "aigov-${var.workload_id}-bedrock-monthly"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  tags         = local.tags

  cost_filter {
    name   = "Service"
    values = var.budget_service_filter
  }

  dynamic "notification" {
    for_each = toset([for t in var.alert_thresholds_percent : tostring(t)])
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = tonumber(notification.value)
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = var.subscriber_emails
      subscriber_sns_topic_arns  = [aws_sns_topic.finops.arn]
    }
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.subscriber_emails
  }
}

# AIG-22 AIG-13
resource "aws_cloudwatch_metric_alarm" "input_tokens" {
  alarm_name          = "aigov-${var.workload_id}-input-tokens-1h"
  alarm_description   = "Bedrock input tokens in one hour exceeded the workload ceiling (unbounded consumption guard)."
  namespace           = "AWS/Bedrock"
  metric_name         = "InputTokenCount"
  statistic           = "Sum"
  period              = 3600
  evaluation_periods  = 1
  threshold           = var.input_tokens_per_hour_alert
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  dimensions          = { ModelId = var.model_id_dimension }
  alarm_actions       = [aws_sns_topic.finops.arn]
  tags                = local.tags
}

# AIG-22 AIG-13
resource "aws_cloudwatch_metric_alarm" "output_tokens" {
  alarm_name          = "aigov-${var.workload_id}-output-tokens-1h"
  alarm_description   = "Bedrock output tokens in one hour exceeded the workload ceiling."
  namespace           = "AWS/Bedrock"
  metric_name         = "OutputTokenCount"
  statistic           = "Sum"
  period              = 3600
  evaluation_periods  = 1
  threshold           = var.output_tokens_per_hour_alert
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  dimensions          = { ModelId = var.model_id_dimension }
  alarm_actions       = [aws_sns_topic.finops.arn]
  tags                = local.tags
}

# AIG-17 AIG-13
# Throttling is the leading indicator that quota — not budget — is the binding constraint.
resource "aws_cloudwatch_metric_alarm" "throttles" {
  alarm_name          = "aigov-${var.workload_id}-throttles"
  alarm_description   = "Bedrock invocations are being throttled; capacity or cross-region failover needed."
  namespace           = "AWS/Bedrock"
  metric_name         = "InvocationThrottles"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = 10
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  dimensions          = { ModelId = var.model_id_dimension }
  alarm_actions       = [aws_sns_topic.finops.arn]
  tags                = local.tags
}
