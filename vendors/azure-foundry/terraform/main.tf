# ─────────────────────────────────────────────────────────────────────────────
# Reference hardened Microsoft Foundry account (kind AIServices), content
# filter (RAI) policy, sample model deployment, private endpoint and
# diagnostic setting. Arguments verified against the hashicorp/azurerm v5.9.0
# provider schema.
# ─────────────────────────────────────────────────────────────────────────────

locals {
  account_count = var.deploy_reference_account ? 1 : 0

  # Hate, Sexual, Violence and Selfharm are blocked at the configured severity
  # on both prompts and completions; Jailbreak (prompt shield) on prompts;
  # Protected Material Text/Code on completions. Filter names come from the
  # RAI Policies REST sample and the built-in content-filter policy JSON.
  harm_categories = ["Hate", "Sexual", "Violence", "Selfharm"]

  severity_filters = flatten([
    for category in local.harm_categories : [
      for source in ["Prompt", "Completion"] : {
        name               = category
        source             = source
        severity_threshold = var.rai_severity_threshold
      }
    ]
  ])

  binary_filters = [
    { name = "Jailbreak", source = "Prompt" },
    { name = "Protected Material Text", source = "Completion" },
    { name = "Protected Material Code", source = "Completion" },
  ]

  identity_type = var.user_assigned_identity_id == null ? "SystemAssigned" : "SystemAssigned, UserAssigned"
}

# AIG-07 AIG-08 AIG-09
resource "azurerm_cognitive_account" "this" {
  count = local.account_count

  name                = var.account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "AIServices"
  sku_name            = "S0"

  # AIG-07: Entra ID only; no API keys.
  local_auth_enabled = false
  # AIG-08: no public endpoint; firewall default deny; outbound allow-list.
  public_network_access_enabled      = false
  custom_subdomain_name              = var.custom_subdomain_name
  outbound_network_access_restricted = var.outbound_network_access_restricted
  fqdns                              = var.allowed_fqdns
  project_management_enabled         = var.project_management_enabled

  network_acls {
    default_action = "Deny"
    bypass         = var.network_acls_bypass
    ip_rules       = var.allowed_ip_ranges

    dynamic "virtual_network_rules" {
      for_each = var.allowed_subnet_ids
      content {
        subnet_id = virtual_network_rules.value
      }
    }
  }

  # AIG-07: workload identity for downstream data access (no stored secrets).
  identity {
    type         = local.identity_type
    identity_ids = var.user_assigned_identity_id == null ? null : [var.user_assigned_identity_id]
  }

  # AIG-09: optional customer-managed key.
  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key == null ? [] : [var.customer_managed_key]
    content {
      key_vault_key_id   = customer_managed_key.value.key_vault_key_id
      identity_client_id = customer_managed_key.value.identity_client_id
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition = alltrue([
        var.resource_group_name != null,
        var.location != null,
        var.account_name != null,
        var.custom_subdomain_name != null,
      ])
      error_message = "resource_group_name, location, account_name and custom_subdomain_name are required when deploy_reference_account = true."
    }
    precondition {
      condition     = var.customer_managed_key == null || var.user_assigned_identity_id != null
      error_message = "customer_managed_key needs user_assigned_identity_id: the key must be readable by an identity that exists before the account is created."
    }
  }
}

# AIG-08
# Private endpoint for the account. Subresource "account"; DNS zones
# privatelink.cognitiveservices.azure.com, privatelink.openai.azure.com and
# privatelink.services.ai.azure.com (Microsoft Learn: private endpoint DNS).
resource "azurerm_private_endpoint" "account" {
  count = var.deploy_reference_account && var.private_endpoint_subnet_id != null ? 1 : 0

  name                = "${var.account_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.account_name}-psc"
    private_connection_resource_id = azurerm_cognitive_account.this[0].id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }

  tags = var.tags
}

# AIG-10
resource "azurerm_cognitive_account_rai_policy" "this" {
  count = local.account_count

  name                 = var.rai_policy_name
  cognitive_account_id = azurerm_cognitive_account.this[0].id
  base_policy_name     = var.rai_base_policy_name
  mode                 = var.rai_policy_mode

  dynamic "content_filter" {
    for_each = local.severity_filters
    content {
      name               = content_filter.value.name
      source             = content_filter.value.source
      severity_threshold = content_filter.value.severity_threshold
      filter_enabled     = true
      block_enabled      = true
    }
  }

  dynamic "content_filter" {
    for_each = local.binary_filters
    content {
      name           = content_filter.value.name
      source         = content_filter.value.source
      filter_enabled = true
      block_enabled  = true
    }
  }

  tags = var.tags
}

# AIG-06 AIG-10 AIG-15
# Sample deployment pinned to a model version with auto-upgrade off, so model
# changes go through change management, and bound to the RAI policy above.
resource "azurerm_cognitive_deployment" "sample" {
  count = var.deploy_reference_account && var.deploy_sample_model ? 1 : 0

  name                   = var.sample_deployment.name
  cognitive_account_id   = azurerm_cognitive_account.this[0].id
  rai_policy_name        = azurerm_cognitive_account_rai_policy.this[0].name
  version_upgrade_option = "NoAutoUpgrade"

  model {
    format  = var.sample_deployment.model_format
    name    = var.sample_deployment.model_name
    version = var.sample_deployment.model_version
  }

  sku {
    name     = var.sample_deployment.sku_name
    capacity = var.sample_deployment.capacity
  }
}

# AIG-13
# All resource log categories (Audit, RequestResponse, Trace,
# AzureOpenAIRequestUsage, ManagedNetworkEvent) via the allLogs category
# group, plus metrics, to Log Analytics.
resource "azurerm_monitor_diagnostic_setting" "account" {
  count = var.deploy_reference_account && var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "aigov-to-log-analytics"
  target_resource_id         = azurerm_cognitive_account.this[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
