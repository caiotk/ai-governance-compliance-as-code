variable "workload_id" {
  description = "Workload id from the finops profile (used in names and tags)."
  type        = string
}

variable "resource_group_id" {
  description = "Resource group that holds the Microsoft Foundry / Azure OpenAI account(s) for this workload."
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "cognitive_account_ids" {
  description = "Resource IDs of the Foundry/Azure OpenAI accounts the budget and token alerts cover. Filtering the budget on ResourceId avoids the unverified ServiceName/MeterCategory value strings."
  type        = list(string)
}

variable "monthly_budget_usd" {
  description = "Monthly budget for the workload (from finops profile budget.monthly_usd)."
  type        = number
}

variable "budget_start_date" {
  description = "First day of the month the budget starts, RFC3339 (e.g. 2026-11-01T00:00:00Z). Must be the first of a month."
  type        = string
}

variable "alert_thresholds_percent" {
  description = "Actual-spend alert thresholds as percentages of the budget."
  type        = list(number)
  default     = [50, 80, 100]
}

variable "forecast_threshold_percent" {
  description = "Forecasted-spend alert threshold (percentage)."
  type        = number
  default     = 100
}

variable "contact_emails" {
  type = list(string)
}

variable "tokens_per_hour_alert" {
  description = "Alert when processed inference tokens (prompt + generated) in a 1h window exceed this count (TokenTransaction metric)."
  type        = number
}

variable "model_deployment_names" {
  description = "Deployment names to scope token alerts to (dimension ModelDeploymentName). Empty = all deployments."
  type        = list(string)
  default     = []
}

variable "location" {
  description = "Azure region of the Foundry/Azure OpenAI accounts (required with multi-resource scopes, e.g. westeurope)."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
