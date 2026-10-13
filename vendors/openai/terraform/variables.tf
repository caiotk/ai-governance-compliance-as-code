variable "projects" {
  description = <<-EOT
    Governed OpenAI projects, one per environment (key = environment name, e.g. "dev", "prod").
    - name:                         project display name (appears in usage and cost reports).
    - geography:                    optional data-residency region, fixed at project creation. Requires an
                                    OpenAI sales eligibility check. UNVERIFIED: the provider docs do not list
                                    accepted values (the Admin API marks `geography` deprecated in favour of
                                    `residency`, which the provider does not expose). Leave null unless OpenAI
                                    has confirmed the value for your organization.
    - approved_model_ids:           model IDs the project may call (allow-list). Must be visible to the org.
    - model_permission_mode:        "allow_list" (default, secure) or "deny_list".
    - data_retention_type:          project retention override. Default "organization_default" (inherit).
                                    ZDR / MAM values only work once OpenAI has approved them for the org.
    - hosted_tools:                 hosted tools to ENABLE. All default to false (disabled). Disabling a tool
                                    per project requires the org-level tool policy to be "allow selected projects".
    - monthly_spend_limit_cents:    hard monthly spend limit in cents (API returns 429 once reached).
    - spend_alert_threshold_cents:  monthly spend alert threshold in cents (notification only).
    - workload_permissions:         permissions granted to the project's workload service account through a
                                    custom project role (least privilege).
  EOT
  type = map(object({
    name                  = string
    geography             = optional(string)
    approved_model_ids    = list(string)
    model_permission_mode = optional(string, "allow_list")
    data_retention_type   = optional(string, "organization_default")
    hosted_tools = optional(object({
      web_search       = optional(bool, false)
      mcp              = optional(bool, false)
      code_interpreter = optional(bool, false)
      file_search      = optional(bool, false)
      image_generation = optional(bool, false)
    }), {})
    monthly_spend_limit_cents   = number
    spend_alert_threshold_cents = number
    workload_permissions        = optional(list(string), ["api.responses.write"])
  }))

  validation {
    condition     = length(var.projects) > 0
    error_message = "Define at least one governed project."
  }

  validation {
    condition     = alltrue([for p in values(var.projects) : length(p.approved_model_ids) > 0])
    error_message = "Every project needs at least one approved model ID (an empty allow-list is not a governance decision)."
  }

  validation {
    condition     = alltrue([for p in values(var.projects) : contains(["allow_list", "deny_list"], p.model_permission_mode)])
    error_message = "model_permission_mode must be allow_list or deny_list."
  }

  validation {
    condition = alltrue([for p in values(var.projects) : contains([
      "organization_default",
      "none",
      "zero_data_retention",
      "modified_abuse_monitoring",
      "enhanced_zero_data_retention",
      "enhanced_modified_abuse_monitoring",
    ], p.data_retention_type)])
    error_message = "data_retention_type must be one of the values the openai/openai provider accepts."
  }

  validation {
    condition     = alltrue([for p in values(var.projects) : p.monthly_spend_limit_cents > 0 && p.spend_alert_threshold_cents > 0])
    error_message = "Spend limit and spend alert thresholds must be greater than zero (cents)."
  }

  validation {
    condition     = alltrue([for p in values(var.projects) : p.spend_alert_threshold_cents < p.monthly_spend_limit_cents])
    error_message = "The spend alert threshold must be below the hard spend limit so the alert fires before requests start failing."
  }
}

variable "rate_limits" {
  description = <<-EOT
    Project rate limits for approved models, keyed by any unique label (e.g. "prod/gpt-5.4-mini").
    OpenAI creates the rate-limit records; Terraform only updates them. Discover `rate_limit_id`
    with the `openai_project_rate_limits` data source or GET /v1/organization/projects/{id}/rate_limits.
    `project` must be a key of var.projects. Unset limits keep their current remote value.
  EOT
  type = map(object({
    project                          = string
    rate_limit_id                    = string
    max_requests_per_1_minute        = optional(number)
    max_tokens_per_1_minute          = optional(number)
    max_images_per_1_minute          = optional(number)
    max_requests_per_1_day           = optional(number)
    max_audio_megabytes_per_1_minute = optional(number)
    batch_1_day_max_input_tokens     = optional(number)
  }))
  default = {}
}

variable "spend_alert_recipients" {
  description = "Email recipients for project spend alerts (the provider only supports the email channel)."
  type        = list(string)

  validation {
    condition     = length(var.spend_alert_recipients) > 0
    error_message = "Provide at least one spend-alert recipient."
  }
}

variable "create_workload_service_accounts" {
  description = "Create a project service account per project for workloads, so applications do not run on personal user keys."
  type        = bool
  default     = true
}

variable "organization_spend_limit_cents" {
  description = "Optional organization-wide hard monthly spend limit in cents. null = not managed by this module."
  type        = number
  default     = null
}

variable "organization_data_retention_type" {
  description = <<-EOT
    Optional organization-level data-retention setting. null = not managed by this module (recommended unless
    Terraform owns it). This resource changes an existing setting; it does not enrol the organization in ZDR/MAM,
    which remain subject to prior approval by OpenAI.
  EOT
  type        = string
  default     = null

  validation {
    condition = var.organization_data_retention_type == null || contains([
      "zero_data_retention",
      "modified_abuse_monitoring",
      "enhanced_zero_data_retention",
      "enhanced_modified_abuse_monitoring",
    ], coalesce(var.organization_data_retention_type, "zero_data_retention"))
    error_message = "organization_data_retention_type must be null or a documented retention_type value."
  }
}
