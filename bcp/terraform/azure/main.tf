# ─────────────────────────────────────────────────────────────────────────────
# BCP/DR on Microsoft Foundry: the same model deployed in two regions with the
# same content-filter policy, fronted by the APIM backend pool in
# finops/iac/gateway/apim/backends.bicep (priority 1 → 2). Controls: AIG-17, AIG-10.
#
# Verified 2026-10-13 (docs/sources/finops-bcp-dr.md §2): Foundry "doesn't provide
# automatic failover or disaster recovery"; Global/Data Zone routing "doesn't
# replace application-level regional failover"; recommended pattern is an API
# gateway with backend pool + circuit breaker. azurerm_cognitive_deployment:
# model{format,name,version}, sku{name,capacity}, rai_policy_name,
# version_upgrade_option.
# ─────────────────────────────────────────────────────────────────────────────

# AIG-17 AIG-10
resource "azurerm_cognitive_deployment" "primary" {
  name                 = "${var.workload_id}-primary"
  cognitive_account_id = var.primary_account_id
  rai_policy_name      = var.rai_policy_name
  # Pin the version in production so a vendor auto-upgrade is a change you choose (AIG-15).
  version_upgrade_option = "NoAutoUpgrade"

  model {
    format  = "OpenAI"
    name    = var.model_name
    version = var.model_version == "" ? null : var.model_version
  }

  sku {
    name     = var.primary_sku
    capacity = var.capacity_thousands_tpm
  }
}

# AIG-17 AIG-10
resource "azurerm_cognitive_deployment" "secondary" {
  name                   = "${var.workload_id}-secondary"
  cognitive_account_id   = var.secondary_account_id
  rai_policy_name        = var.rai_policy_name
  version_upgrade_option = "NoAutoUpgrade"

  model {
    format  = "OpenAI"
    name    = var.model_name
    version = var.model_version == "" ? null : var.model_version
  }

  sku {
    name     = var.secondary_sku
    capacity = var.secondary_capacity_thousands_tpm
  }
}
