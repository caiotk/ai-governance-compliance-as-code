# ─────────────────────────────────────────────────────────────────────────────
# Copilot Studio / Power Platform agent governance baseline.
# Resource and argument names verified against the microsoft/power-platform
# v4.2.0 provider schema; enum values against the provider's validators.
# ─────────────────────────────────────────────────────────────────────────────

# AIG-06 AIG-07 AIG-08
# Connector catalogue used to resolve connector IDs by display name and to
# find unblockable connectors (which must sit in Non-business).
data "powerplatform_connectors" "all" {
  environment_id = var.connector_lookup_environment_id
}

locals {
  connectors = data.powerplatform_connectors.all.connectors

  # display name => connector ID. Overrides win; otherwise the first connector
  # whose display_name matches exactly. UNVERIFIED: that every Copilot Studio
  # governance connector is returned by the connectors API under the
  # admin-center display name. Unresolved names are reported by the check block.
  resolved_blocked = {
    for name in var.blocked_connector_display_names :
    name => lookup(
      var.blocked_connector_id_overrides,
      name,
      try([for c in local.connectors : c.id if c.display_name == name][0], null)
    )
  }

  unresolved_blocked = [for name, id in local.resolved_blocked : name if id == null]

  # Optional HTTP endpoint filtering: when http_allowed_endpoints is set, HTTP
  # moves to Business with endpoint rules (Allow each entry, then Deny "*").
  http_id         = lookup(local.resolved_blocked, "HTTP", null)
  http_allow_list = length(var.http_allowed_endpoints) > 0 && local.http_id != null
  http_endpoint_rules = concat(
    [for i, e in var.http_allowed_endpoints : { behavior = "Allow", endpoint = e, order = i + 1 }],
    [{ behavior = "Deny", endpoint = "*", order = length(var.http_allowed_endpoints) + 1 }],
  )

  blocked_ids = distinct(concat(
    [for name, id in local.resolved_blocked : id if id != null && !(name == "HTTP" && local.http_allow_list)],
    var.additional_blocked_connector_ids,
  ))

  business_ids = distinct(concat(
    [for id in var.business_connector_ids : id if !contains(local.blocked_ids, id)],
    local.http_allow_list ? [local.http_id] : [],
  ))

  business = [
    for id in local.business_ids : {
      id                           = id
      default_action_rule_behavior = ""
      action_rules                 = []
      endpoint_rules               = local.http_allow_list && id == local.http_id ? local.http_endpoint_rules : []
    }
  ]

  # Unblockable connectors must be in Non-business.
  non_business = [
    for c in local.connectors : {
      id                           = c.id
      default_action_rule_behavior = ""
      action_rules                 = []
      endpoint_rules               = []
    } if c.unblockable && !contains(local.business_ids, c.id)
  ]

  blocked = [
    for id in local.blocked_ids : {
      id                           = id
      default_action_rule_behavior = ""
      action_rules                 = []
      endpoint_rules               = []
    }
  ]

  custom_patterns = concat(
    [for i, p in var.custom_connector_business_host_patterns : { order = i + 1, host_url_pattern = p, data_group = "Business" }],
    [{ order = length(var.custom_connector_business_host_patterns) + 1, host_url_pattern = "*", data_group = "Blocked" }],
  )
}

# AIG-06 AIG-07 AIG-08
# Warns when a high-risk connector could not be resolved to an ID.
check "copilot_studio_connectors_resolved" {
  assert {
    condition     = length(local.unresolved_blocked) == 0
    error_message = "These connectors did not resolve to an ID and are only blocked by the default classification: ${join(", ", local.unresolved_blocked)}. Set blocked_connector_id_overrides."
  }
}

# AIG-05 AIG-06 AIG-07 AIG-08
# Tenant-wide data policy. New and unlisted connectors default to Blocked;
# the high-risk Copilot Studio connectors are also blocked explicitly:
#   - HTTP (unless an endpoint allow-list is supplied)
#   - Chat without Microsoft Entra ID authentication in Copilot Studio
#     (blocking it forces agents to require Entra ID authentication)
#   - Knowledge source with public websites and data in Copilot Studio
#   - Facebook channel / WhatsApp channel in Copilot Studio
# Copilot Studio enforces data policies in real time and disables Publish on
# violation; blocking connectors also blocks tools in connected MCP servers.
resource "powerplatform_data_loss_prevention_policy" "agent_baseline" {
  display_name                      = var.dlp_policy_display_name
  default_connectors_classification = "Blocked"
  environment_type                  = "AllEnvironments"
  environments                      = []

  business_connectors        = toset(local.business)
  non_business_connectors    = toset(local.non_business)
  blocked_connectors         = toset(local.blocked)
  custom_connectors_patterns = toset(local.custom_patterns)
}

# AIG-02 AIG-07 AIG-15
# Production environment becomes a Managed Environment: no security-group
# sharing, capped individual sharing, no Editor grants when agents are shared,
# solution-aware flow sharing off, solution checker blocks risky imports.
resource "powerplatform_managed_environment" "production" {
  environment_id = var.environment_id

  is_usage_insights_disabled = false
  is_group_sharing_disabled  = true
  limit_sharing_mode         = "ExcludeSharingToSecurityGroups"
  max_limit_user_sharing     = var.canvas_max_limit_user_sharing
  solution_checker_mode      = var.solution_checker_mode
  suppress_validation_emails = false

  power_automate_is_sharing_disabled                 = true
  copilot_allow_grant_editor_permissions_when_shared = false
  copilot_limit_sharing_mode                         = var.copilot_limit_sharing_mode
  copilot_max_limit_user_sharing                     = var.copilot_limit_sharing_mode == "NoLimit" ? -1 : var.copilot_max_limit_user_sharing
}

# AIG-06 AIG-13
# Environment settings: no preview/experimental AI models for agents, prompts,
# apps and flows; Dataverse auditing on with a retention period.
resource "powerplatform_environment_settings" "production" {
  environment_id = var.environment_id

  audit_and_logs = {
    audit_settings = {
      is_audit_enabled             = true
      is_user_access_audit_enabled = true
      log_retention_period_in_days = var.dataverse_audit_retention_days
    }
  }

  product = {
    features = {
      enable_preview_and_experimental_ai_models = false
    }
  }

  depends_on = [powerplatform_managed_environment.production]
}

# AIG-08 AIG-18
# Tenant isolation: blocks inbound and outbound cross-tenant connections for
# Entra-authenticated connectors except to the allowed tenants. Tenant-wide
# singleton; Off by default in Power Platform.
# allowed-tenants.json: [{ "tenant_id": "<guid or *>", "inbound": bool, "outbound": bool }]
# At least one of inbound/outbound must be true per entry.
resource "powerplatform_tenant_isolation_policy" "this" {
  count = var.enable_tenant_isolation ? 1 : 0

  is_disabled = false
  allowed_tenants = toset([
    for t in jsondecode(file("${path.module}/allowed-tenants.json")) : {
      tenant_id = t.tenant_id
      inbound   = t.inbound
      outbound  = t.outbound
    }
  ])
}
