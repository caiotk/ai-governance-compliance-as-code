# ─── Scope ───────────────────────────────────────────────────────────────────

variable "subscription_id" {
  description = "Subscription that hosts the reference Foundry account and the Defender for AI services plan."
  type        = string
}

variable "management_group_id" {
  description = "Full resource ID of the management group the policy assignments target, e.g. /providers/Microsoft.Management/managementGroups/<name>."
  type        = string

  validation {
    condition     = can(regex("^/providers/Microsoft.Management/managementGroups/[^/]+$", var.management_group_id))
    error_message = "management_group_id must be the full management group resource ID."
  }
}

variable "policy_assignment_location" {
  description = "Region for the policy assignments' managed identity metadata. Only needed if you later switch to DeployIfNotExists/Modify definitions; the Audit/Deny assignments here do not use an identity."
  type        = string
  default     = null
}

variable "policy_enforce" {
  description = "Enforce the Deny assignments. Set false to roll out in DoNotEnforce mode first and review compliance before switching to true."
  type        = bool
  default     = true
}

# ─── Policy effects ──────────────────────────────────────────────────────────

variable "cmk_policy_effect" {
  description = "Effect for 'Azure AI Services resources should encrypt data at rest with a customer-managed key (CMK)' (67121cc7-…). Allowed: Audit, Deny, Disabled."
  type        = string
  default     = "Audit"

  validation {
    condition     = contains(["Audit", "Deny", "Disabled"], var.cmk_policy_effect)
    error_message = "cmk_policy_effect must be Audit, Deny or Disabled."
  }
}

variable "cmk_policy_excluded_kinds" {
  description = "excludedKinds parameter for the CMK policy. The built-in default excludes AIServices (and other kinds); the pack's default is empty so Foundry (AIServices) and OpenAI accounts are evaluated. Add kinds here to exempt them."
  type        = list(string)
  default     = []
}

variable "managed_identity_policy_effect" {
  description = "Effect for 'Cognitive Services accounts should use a managed identity' (fe3fd216-…). Allowed: Audit, Deny, Disabled."
  type        = string
  default     = "Deny"

  validation {
    condition     = contains(["Audit", "Deny", "Disabled"], var.managed_identity_policy_effect)
    error_message = "managed_identity_policy_effect must be Audit, Deny or Disabled."
  }
}

variable "approved_models_policy_effect" {
  description = "Effect for 'Foundry model deployments should only use approved models' (aafe3651-…). Allowed: Audit, Deny, Disabled."
  type        = string
  default     = "Deny"

  validation {
    condition     = contains(["Audit", "Deny", "Disabled"], var.approved_models_policy_effect)
    error_message = "approved_models_policy_effect must be Audit, Deny or Disabled."
  }
}

variable "approved_model_publishers" {
  description = "allowedPublishers for the approved-models policy. Any model from these publishers is allowed. Include \"Microsoft\" if you use the model router."
  type        = list(string)
  default     = []
}

variable "approved_model_asset_ids" {
  description = "allowedAssetIds for the approved-models policy. Prefix match, case-sensitive: a trailing '/' pins one model, '/versions/N' pins one version."
  type        = list(string)
  default = [
    "azureml://registries/azure-openai/models/gpt-5/",
  ]
}

variable "assign_eu_ai_act_initiative" {
  description = "Assign the built-in 'EU AI Act 2024 1689' initiative (1308bccf-…) in audit mode at the management group."
  type        = bool
  default     = true
}

# ─── Reference Foundry account ───────────────────────────────────────────────

variable "deploy_reference_account" {
  description = "Deploy the reference hardened Foundry (AIServices) account, RAI policy, deployment and diagnostic setting."
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Existing resource group for the reference Foundry account."
  type        = string
  default     = null
}

variable "location" {
  description = "Azure region for the reference Foundry account. Pick a region that satisfies your residency requirement (AIG-08/AIG-18)."
  type        = string
  default     = null
}

variable "account_name" {
  description = "Name of the reference Foundry account."
  type        = string
  default     = null
}

variable "custom_subdomain_name" {
  description = "Globally unique custom subdomain for the account. Required for network_acls and Entra ID (token) authentication."
  type        = string
  default     = null
}

variable "allowed_ip_ranges" {
  description = "Optional IP ranges allowed through the account firewall. Empty keeps the account reachable only through private endpoints."
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "Optional subnet IDs allowed through the account firewall (virtual network rules)."
  type        = list(string)
  default     = []
}

variable "network_acls_bypass" {
  description = "network_acls.bypass: AzureServices lets trusted Azure services reach the account; None blocks them."
  type        = string
  default     = "None"

  validation {
    condition     = contains(["None", "AzureServices"], var.network_acls_bypass)
    error_message = "network_acls_bypass must be None or AzureServices."
  }
}

variable "private_endpoint_subnet_id" {
  description = "Subnet for the account's private endpoint. Null skips the private endpoint (the account is then unreachable unless allowed_ip_ranges/allowed_subnet_ids are set)."
  type        = string
  default     = null
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs for the private endpoint: privatelink.cognitiveservices.azure.com, privatelink.openai.azure.com and privatelink.services.ai.azure.com."
  type        = list(string)
  default     = []
}

variable "outbound_network_access_restricted" {
  description = "Restrict the account's outbound network access to the FQDNs in allowed_fqdns."
  type        = bool
  default     = true
}

variable "allowed_fqdns" {
  description = "FQDNs the account may reach when outbound access is restricted."
  type        = list(string)
  default     = []
}

variable "project_management_enabled" {
  description = "Allow Foundry projects on this AIServices account (new, non-hub Foundry)."
  type        = bool
  default     = true
}

variable "user_assigned_identity_id" {
  description = "Optional user-assigned identity resource ID. When set the account uses SystemAssigned, UserAssigned; required when the CMK key is read through a user-assigned identity."
  type        = string
  default     = null
}

variable "customer_managed_key" {
  description = "Optional customer-managed key. key_vault_key_id is the versionless or versioned Key Vault key ID; identity_client_id is the client ID of the user-assigned identity that can read the key (omit for the system-assigned identity)."
  type = object({
    key_vault_key_id   = string
    identity_client_id = optional(string)
  })
  default = null
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID that receives the account's resource logs (allLogs) and metrics."
  type        = string
  default     = null
}

# ─── Content safety ──────────────────────────────────────────────────────────

variable "rai_policy_name" {
  description = "Name of the content filter (RAI) policy."
  type        = string
  default     = "aigov-baseline"
}

variable "rai_base_policy_name" {
  description = "Base policy the RAI policy derives from."
  type        = string
  default     = "Microsoft.Default"
}

variable "rai_policy_mode" {
  description = "RAI policy mode: Default, Deferred, Blocking or Asynchronous_filter. Blocking holds streamed output until it is filtered."
  type        = string
  default     = "Blocking"

  validation {
    condition     = contains(["Default", "Deferred", "Blocking", "Asynchronous_filter"], var.rai_policy_mode)
    error_message = "rai_policy_mode must be Default, Deferred, Blocking or Asynchronous_filter."
  }
}

variable "rai_severity_threshold" {
  description = "Severity at which Hate, Sexual, Violence and Selfharm are blocked on prompts and completions (Low blocks most, High blocks least)."
  type        = string
  default     = "Medium"

  validation {
    condition     = contains(["Low", "Medium", "High"], var.rai_severity_threshold)
    error_message = "rai_severity_threshold must be Low, Medium or High."
  }
}

# ─── Sample deployment ───────────────────────────────────────────────────────

variable "deploy_sample_model" {
  description = "Create the sample model deployment wired to the RAI policy. The model must also be on the approved-models allow-list."
  type        = bool
  default     = true
}

variable "sample_deployment" {
  description = "Sample deployment. sku_name is a deployment SKU such as Standard, DataZoneStandard or GlobalStandard; pick a data-zone or regional SKU if processing location matters (AIG-08/AIG-18)."
  type = object({
    name          = string
    model_format  = string
    model_name    = string
    model_version = optional(string)
    sku_name      = string
    capacity      = optional(number)
  })
  default = {
    name         = "gpt-5"
    model_format = "OpenAI"
    model_name   = "gpt-5"
    sku_name     = "DataZoneStandard"
    capacity     = 10
  }
}

# ─── Defender for Cloud ──────────────────────────────────────────────────────

variable "enable_defender_for_ai" {
  description = "Enable Defender for Cloud threat protection for AI services (pricing resource_type AI, tier Standard) on the subscription."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to taggable resources."
  type        = map(string)
  default     = {}
}
