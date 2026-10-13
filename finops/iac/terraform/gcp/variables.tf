variable "project_id" {
  type = string
}

variable "project_number" {
  description = "Numeric project number (budget_filter.projects uses projects/{number})."
  type        = string
}

variable "billing_account" {
  type = string
}

variable "workload_id" {
  type = string
}

variable "monthly_budget_usd" {
  type = number
}

variable "vertex_service_id" {
  description = "Cloud Billing service id for Vertex AI / Gemini Enterprise Agent Platform in the form services/XXXX-XXXX-XXXX. UNVERIFIED in the research notes — obtain with `gcloud billing services list --filter='displayName:Vertex'` (Catalog API services.list) and set it here. Leave empty to budget the whole project."
  type        = string
  default     = ""
}

variable "notification_channel_ids" {
  description = "Monitoring notification channel resource names (projects/{project}/notificationChannels/{id}); max 5 for the budget."
  type        = list(string)
}

variable "tokens_per_hour_alert" {
  description = "Alert when publisher-model input+output tokens in an hour exceed this count."
  type        = number
}

variable "labels" {
  type    = map(string)
  default = {}
}
