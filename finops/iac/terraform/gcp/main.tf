# ─────────────────────────────────────────────────────────────────────────────
# AI FinOps on Google Cloud (Vertex AI / Gemini Enterprise Agent Platform) —
# AIG-22 budgets and token alerts, AIG-13.
#
# Verified 2026-10-13 (docs/sources/finops-tooling.md §3.5–3.6):
#   google_billing_budget: billing_account, display_name, budget_filter
#   {projects, services, calendar_period}, amount.specified_amount, threshold_rules
#   {threshold_percent, spend_basis}, all_updates_rule {monitoring_notification_channels,
#   pubsub_topic, schema_version}.
#   google_monitoring_alert_policy: condition_threshold {filter, duration, comparison,
#   threshold_value, aggregations}; Vertex publisher-model metric
#   aiplatform.googleapis.com/publisher/online_serving/token_count on resource
#   aiplatform.googleapis.com/PublisherModel (labels type input|output, request_type
#   dedicated|spillover|shared).
# UNVERIFIED: the Vertex AI billing service id (variables.tf).
# ─────────────────────────────────────────────────────────────────────────────

locals {
  labels = merge(var.labels, { "aigov-workload" = var.workload_id, "aigov-control" = "aig-22" })
}

# AIG-22
resource "google_pubsub_topic" "budget" {
  name   = "aigov-${var.workload_id}-budget"
  labels = local.labels
}

# AIG-22
resource "google_billing_budget" "workload" {
  billing_account = var.billing_account
  display_name    = "aigov ${var.workload_id} monthly"

  budget_filter {
    projects               = ["projects/${var.project_number}"]
    services               = var.vertex_service_id == "" ? null : [var.vertex_service_id]
    calendar_period        = "MONTH"
    credit_types_treatment = "EXCLUDE_ALL_CREDITS"
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = tostring(floor(var.monthly_budget_usd))
    }
  }

  threshold_rules {
    threshold_percent = 0.5
  }
  threshold_rules {
    threshold_percent = 0.8
  }
  threshold_rules {
    threshold_percent = 1.0
  }
  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "FORECASTED_SPEND"
  }

  all_updates_rule {
    pubsub_topic                     = google_pubsub_topic.budget.id
    schema_version                   = "1.0"
    monitoring_notification_channels = var.notification_channel_ids
    disable_default_iam_recipients   = false
  }
}

# AIG-22 AIG-13
# Token-consumption alert on Gemini / partner publisher models (input + output).
resource "google_monitoring_alert_policy" "tokens_per_hour" {
  display_name = "aigov ${var.workload_id} tokens per hour"
  combiner     = "OR"
  severity     = "WARNING"
  user_labels  = local.labels

  conditions {
    display_name = "publisher model tokens > ceiling (1h)"
    condition_threshold {
      filter          = "metric.type=\"aiplatform.googleapis.com/publisher/online_serving/token_count\" AND resource.type=\"aiplatform.googleapis.com/PublisherModel\""
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.tokens_per_hour_alert
      aggregations {
        alignment_period     = "3600s"
        per_series_aligner   = "ALIGN_SUM"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["resource.label.model_user_id"]
      }
      trigger {
        count = 1
      }
    }
  }

  notification_channels = var.notification_channel_ids

  documentation {
    content   = "Workload ${var.workload_id}: Gemini/publisher-model token consumption exceeded the hourly ceiling set in the finops profile (OWASP LLM06 unbounded consumption guard). Check litellm spend metrics and the budget."
    mime_type = "text/markdown"
  }
}

# AIG-17 AIG-13
# Spillover from Provisioned Throughput to pay-as-you-go is a cost and capacity signal.
resource "google_monitoring_alert_policy" "pt_spillover" {
  display_name = "aigov ${var.workload_id} provisioned-throughput spillover"
  combiner     = "OR"
  severity     = "WARNING"
  user_labels  = local.labels

  conditions {
    display_name = "spillover requests present"
    condition_threshold {
      filter          = "metric.type=\"aiplatform.googleapis.com/publisher/online_serving/model_invocation_count\" AND resource.type=\"aiplatform.googleapis.com/PublisherModel\" AND metric.label.request_type=\"spillover\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }

  notification_channels = var.notification_channel_ids
}
