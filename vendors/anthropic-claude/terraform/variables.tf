variable "anthropic_admin_api_key" {
  description = "Claude Admin API key (sk-ant-admin...). Pass via TF_VAR_anthropic_admin_api_key; never commit it. Only the admin role can create one; the Admin API is unavailable for individual accounts."
  type        = string
  sensitive   = true
}

variable "api_base_url" {
  description = "Claude API base URL."
  type        = string
  default     = "https://api.anthropic.com"
}

variable "anthropic_version" {
  description = "Value of the anthropic-version header sent on every Admin API request."
  type        = string
  default     = "2023-06-01"
}

variable "required_workspaces" {
  description = "Workspace names that must exist (and not be archived), e.g. one per environment or business unit."
  type        = list(string)
  default     = ["production", "staging", "development"]
}

variable "allow_default_workspace_keys" {
  description = "Whether active API keys may live in the Default Workspace. Default false: the Default Workspace cannot have workspace spend or rate limits, so workloads belong in named workspaces."
  type        = bool
  default     = false
}

variable "max_active_api_keys" {
  description = "Upper bound on active API keys across the organization (key-sprawl guard)."
  type        = number
  default     = 50

  validation {
    condition     = var.max_active_api_keys > 0
    error_message = "max_active_api_keys must be positive."
  }
}

variable "max_key_age_days" {
  description = "Active API keys older than this many days are reported as stale (rotate them, then disable the old key with native/admin-api.sh). The Admin API does not expose last-used time, so age is the available proxy."
  type        = number
  default     = 90
}

variable "require_key_expiry" {
  description = "Report active API keys that have no expiration (expires_at = null)."
  type        = bool
  default     = true
}

variable "service_account_only_workspaces" {
  description = "Workspace names in which personal (user_actor) API keys are not allowed; only service-account or workspace keys may be active."
  type        = list(string)
  default     = ["production"]
}

variable "us_only_workspaces" {
  description = "Workspace names that must restrict inference to the US: data_residency.allowed_inference_geos = [\"us\"] and default_inference_geo = \"us\"."
  type        = list(string)
  default     = []
}

variable "require_workspace_rate_limits" {
  description = "Require every required workspace to have at least one workspace rate-limit override (read from GET /v1/organizations/workspaces/{id}/rate_limits)."
  type        = bool
  default     = true
}

variable "fail_on_violation" {
  description = "When true, any posture violation fails `terraform plan` (CI gate). When false, violations are reported only as `check` warnings and in the posture_violations output."
  type        = bool
  default     = true
}
