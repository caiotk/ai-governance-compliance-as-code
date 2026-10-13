# ─── DLP (data policy) ───────────────────────────────────────────────────────

variable "dlp_policy_display_name" {
  description = "Display name of the tenant-wide agent baseline data policy."
  type        = string
  default     = "AIGov agent baseline"
}

variable "business_connector_ids" {
  description = "Connector IDs (/providers/Microsoft.PowerApps/apis/shared_...) allowed in the Business data group. Everything not listed is Blocked by default, apart from unblockable connectors, which go to Non-business."
  type        = list(string)
  default     = []
}

variable "blocked_connector_display_names" {
  description = "Exact admin-center display names of high-risk Copilot Studio connectors to block. Their IDs are resolved with data.powerplatform_connectors by display_name."
  type        = list(string)
  default = [
    "HTTP",
    "Chat without Microsoft Entra ID authentication in Copilot Studio",
    "Knowledge source with public websites and data in Copilot Studio",
    "Facebook channel in Copilot Studio",
    "WhatsApp channel in Copilot Studio",
  ]
}

variable "blocked_connector_id_overrides" {
  description = "Map of display name => connector ID. Use it when a display name does not resolve through data.powerplatform_connectors (the Copilot Studio connector IDs are UNVERIFIED). Overrides win over the lookup."
  type        = map(string)
  default     = {}
}

variable "additional_blocked_connector_ids" {
  description = "Extra connector IDs to place explicitly in the Blocked group."
  type        = list(string)
  default     = []
}

variable "http_allowed_endpoints" {
  description = "Optional HTTP endpoint allow-list. Empty (default) blocks the HTTP connector. Non-empty moves HTTP to Business with endpoint rules: Allow each entry, then Deny '*'."
  type        = list(string)
  default     = []
}

variable "custom_connector_business_host_patterns" {
  description = "Host URL patterns of approved custom connectors (e.g. https://*.contoso.com) classified as Business. All other custom connectors are Blocked."
  type        = list(string)
  default     = []
}

variable "connector_lookup_environment_id" {
  description = "Environment used by data.powerplatform_connectors. Null = Default environment (tenant-level connectors)."
  type        = string
  default     = null
}

# ─── Managed Environment ─────────────────────────────────────────────────────

variable "environment_id" {
  description = "ID (GUID) of the production environment that hosts agents. It becomes a Managed Environment with conservative sharing limits."
  type        = string
}

variable "canvas_max_limit_user_sharing" {
  description = "Maximum number of individuals a canvas app can be shared with (group sharing is disabled)."
  type        = number
  default     = 20
}

variable "copilot_limit_sharing_mode" {
  description = "Agent sharing: DisableSharing (no Viewer sharing), ExcludeSharingToSecurityGroups (individuals only, capped) or NoLimit."
  type        = string
  default     = "ExcludeSharingToSecurityGroups"

  validation {
    condition     = contains(["DisableSharing", "ExcludeSharingToSecurityGroups", "NoLimit"], var.copilot_limit_sharing_mode)
    error_message = "copilot_limit_sharing_mode must be DisableSharing, ExcludeSharingToSecurityGroups or NoLimit."
  }
}

variable "copilot_max_limit_user_sharing" {
  description = "Maximum number of viewers per agent when sharing is limited to individuals."
  type        = number
  default     = 20
}

variable "solution_checker_mode" {
  description = "Solution checker enforcement on solution import: None, Warn or Block."
  type        = string
  default     = "Block"

  validation {
    condition     = contains(["None", "Warn", "Block"], var.solution_checker_mode)
    error_message = "solution_checker_mode must be None, Warn or Block."
  }
}

# ─── Environment settings ────────────────────────────────────────────────────

variable "dataverse_audit_retention_days" {
  description = "Dataverse audit log retention in days (31-24855, or -1 for forever)."
  type        = number
  default     = 365

  validation {
    condition     = var.dataverse_audit_retention_days == -1 || (var.dataverse_audit_retention_days >= 31 && var.dataverse_audit_retention_days <= 24855)
    error_message = "dataverse_audit_retention_days must be -1 or between 31 and 24855."
  }
}

# ─── Tenant isolation ────────────────────────────────────────────────────────

variable "enable_tenant_isolation" {
  description = "Turn on Power Platform tenant isolation (tenant-wide singleton). It blocks cross-tenant connections for Entra-authenticated connectors except to allowed_tenants."
  type        = bool
  default     = true
}

# The tenant allow-list is read from allowed-tenants.json (see main.tf), not a
# variable: provider v4.2.0's ValidateConfig for powerplatform_tenant_isolation_policy
# fails when allowed_tenants is unknown, which a variable always is during
# `terraform validate`. Keeping the list in a reviewed data file also gives an
# auditable change history for cross-tenant trust.
