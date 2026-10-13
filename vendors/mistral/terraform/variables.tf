variable "mistral_admin_api_key" {
  description = "Mistral Admin API key, created in Backoffice (backoffice.mistral.ai → API keys). Enterprise plans only; access is not self-serve. Pass via TF_VAR_mistral_admin_api_key; never commit it."
  type        = string
  sensitive   = true
}

variable "mistral_api_key" {
  description = "A Workspace-scoped Mistral API key used ONLY for the moderation-endpoint smoke test (POST /v1/moderations). Required when moderation_smoke_test = true."
  type        = string
  sensitive   = true
  default     = ""
}

variable "moderation_smoke_test" {
  description = "Run the POST /v1/moderations smoke test with mistral_api_key (AIG-10 evidence). Set false to skip."
  type        = bool
  default     = true
}

variable "api_base_url" {
  description = "Mistral API base URL (La Plateforme)."
  type        = string
  default     = "https://api.mistral.ai"
}

variable "admin_auth_scheme" {
  description = "Header used to authenticate to the Admin API. The authentication page documents `x-api-key`; the audit-logs reference page shows `Authorization: Bearer`. Default follows the authentication page; switch to \"bearer\" if your tenant rejects x-api-key."
  type        = string
  default     = "x-api-key"

  validation {
    condition     = contains(["x-api-key", "bearer"], var.admin_auth_scheme)
    error_message = "admin_auth_scheme must be \"x-api-key\" or \"bearer\"."
  }
}

variable "max_org_admins" {
  description = "Upper bound on members holding the organization_admin role (full access to every Workspace, security, billing and audit logs)."
  type        = number
  default     = 3

  validation {
    condition     = var.max_org_admins > 0
    error_message = "max_org_admins must be positive."
  }
}

variable "users_page_size" {
  description = "Page size for GET /v1/admin/users (the documented example uses page=1&page_size=50). Only the first page is read; posture is reported incomplete if it is full."
  type        = number
  default     = 50
}

variable "require_audit_logs" {
  description = "Require GET /v1/admin/audit-logs to succeed (audit logs are enabled automatically on Enterprise plans; a 4xx here means the plan or key cannot evidence AIG-13)."
  type        = bool
  default     = true
}

variable "moderation_model" {
  description = "Moderation model used for the smoke test."
  type        = string
  default     = "mistral-moderation-latest"
}

variable "required_moderation_categories" {
  description = "Category keys that must be present in the moderation response. The 9 keys below are from the API reference; newer model versions add e.g. `jailbreaking` — verify against a live response before tightening."
  type        = list(string)
  default     = ["sexual", "hate_and_discrimination", "violence_and_threats", "dangerous_and_criminal_content", "selfharm", "health", "financial", "law", "pii"]
}

variable "fail_on_violation" {
  description = "When true, any posture violation fails `terraform plan` (CI gate). When false, violations are reported only as `check` warnings and in the posture_violations output."
  type        = bool
  default     = true
}
