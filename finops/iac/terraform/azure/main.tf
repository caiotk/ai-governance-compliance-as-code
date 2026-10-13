# ─────────────────────────────────────────────────────────────────────────────
# AI FinOps on Azure — AIG-22 (budgets and consumption limits), AIG-13 (telemetry).
#
# Verified 2026-10-13 (docs/sources/finops-tooling.md §3.1–3.2):
#   azurerm_consumption_budget_resource_group: amount, time_grain, time_period,
#   filter.dimension (name ∈ … ResourceId …; operator In), notification
#   (operator, threshold 0–1000, threshold_type Actual|Forecasted, contact_emails).
#   azurerm_monitor_metric_alert on Microsoft.CognitiveServices/accounts metrics:
#   TokenTransaction (= Processed Inference Tokens), ProcessedPromptTokens,
#   GeneratedTokens, AzureOpenAIRequests; dimension ModelDeploymentName.
# The exact ServiceName / MeterCategory value strings for Azure OpenAI were NOT
# verified, so the budget is filtered on the account ResourceId instead.
# ─────────────────────────────────────────────────────────────────────────────

locals {
  tags = merge(var.tags, { "aigov-workload" = var.workload_id, "aigov-control" = "AIG-22" })
}

# AIG-22 AIG-16
resource "azurerm_monitor_action_group" "finops" {
  name                = "ag-${var.workload_id}-finops"
  resource_group_name = var.resource_group_name
  short_name          = substr(replace(var.workload_id, "-", ""), 0, 12)
  tags                = local.tags

  dynamic "email_receiver" {
    for_each = toset(var.contact_emails)
    content {
      name                    = "mail-${replace(email_receiver.value, "/[@.]/", "-")}"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }
}

# AIG-22
# Monthly cost budget scoped to the Foundry/Azure OpenAI accounts of this workload.
resource "azurerm_consumption_budget_resource_group" "workload" {
  name              = "budget-${var.workload_id}"
  resource_group_id = var.resource_group_id
  amount            = var.monthly_budget_usd
  time_grain        = "Monthly"

  time_period {
    start_date = var.budget_start_date
  }

  filter {
    dimension {
      name   = "ResourceId"
      values = var.cognitive_account_ids
    }
  }

  dynamic "notification" {
    for_each = toset([for t in var.alert_thresholds_percent : tostring(t)])
    content {
      enabled        = true
      threshold      = tonumber(notification.value)
      operator       = "GreaterThanOrEqualTo"
      threshold_type = "Actual"
      contact_emails = var.contact_emails
      contact_groups = [azurerm_monitor_action_group.finops.id]
    }
  }

  notification {
    enabled        = true
    threshold      = var.forecast_threshold_percent
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Forecasted"
    contact_emails = var.contact_emails
    contact_groups = [azurerm_monitor_action_group.finops.id]
  }
}

# AIG-22 AIG-13
# Token-consumption alert: processed inference tokens per hour across the accounts.
resource "azurerm_monitor_metric_alert" "tokens_per_hour" {
  name                     = "alert-${var.workload_id}-tokens-1h"
  resource_group_name      = var.resource_group_name
  scopes                   = var.cognitive_account_ids
  description              = "Processed inference tokens (prompt + generated) in the last hour exceeded the workload ceiling (unbounded consumption guard, OWASP LLM06)."
  severity                 = 2
  frequency                = "PT15M"
  window_size              = "PT1H"
  target_resource_type     = "Microsoft.CognitiveServices/accounts"
  target_resource_location = var.location
  tags                     = local.tags

  criteria {
    metric_namespace = "Microsoft.CognitiveServices/accounts"
    metric_name      = "TokenTransaction"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.tokens_per_hour_alert

    dynamic "dimension" {
      for_each = length(var.model_deployment_names) > 0 ? [1] : []
      content {
        name     = "ModelDeploymentName"
        operator = "Include"
        values   = var.model_deployment_names
      }
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.finops.id
  }
}

# AIG-13
# Anomaly guard: dynamic threshold on request volume (catches runaway agents).
resource "azurerm_monitor_metric_alert" "request_anomaly" {
  name                     = "alert-${var.workload_id}-requests-anomaly"
  resource_group_name      = var.resource_group_name
  scopes                   = var.cognitive_account_ids
  description              = "Azure OpenAI request volume deviates from its learned baseline."
  severity                 = 3
  frequency                = "PT5M"
  window_size              = "PT15M"
  target_resource_type     = "Microsoft.CognitiveServices/accounts"
  target_resource_location = var.location
  tags                     = local.tags

  dynamic_criteria {
    metric_namespace  = "Microsoft.CognitiveServices/accounts"
    metric_name       = "AzureOpenAIRequests"
    aggregation       = "Total"
    operator          = "GreaterThan"
    alert_sensitivity = "Medium"
  }

  action {
    action_group_id = azurerm_monitor_action_group.finops.id
  }
}
