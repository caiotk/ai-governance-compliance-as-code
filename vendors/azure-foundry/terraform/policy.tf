# ─────────────────────────────────────────────────────────────────────────────
# Azure Policy guardrails for Microsoft Foundry / Azure OpenAI / Azure AI
# services, assigned at a management group.
#
# Every definition is a Microsoft built-in. GUIDs, display names, effects and
# parameter names were checked against the definition JSON in
# github.com/Azure/azure-policy (built-in-policies/policyDefinitions) on
# 2026-10-13. Assignment names are limited to 24 characters by the provider.
# ─────────────────────────────────────────────────────────────────────────────

locals {
  builtin = "/providers/Microsoft.Authorization/policyDefinitions"

  # Definitions that take only an `effect` parameter.
  simple_assignments = {
    # AIG-07: "Azure AI Services resources should have key access disabled (disable local authentication)" v1.1.0
    "aigov-ai-no-local-auth" = {
      definition = "71ef260a-8f18-47b7-abcb-62d0673d94dc"
      display    = "AIGov: AI Services key access disabled"
      effect     = "Deny"
      message    = "AI Services accounts must disable key (local) authentication. Use Microsoft Entra ID."
    }
    # AIG-08: "Azure AI Services resources should restrict network access" v3.3.0
    # Evaluates publicNetworkAccess and networkAcls.defaultAction.
    "aigov-ai-restrict-net" = {
      definition = "037eea7a-bd0a-46c5-9a66-03aea78705d3"
      display    = "AIGov: AI Services restrict network access"
      effect     = "Deny"
      message    = "AI Services accounts must disable public network access or set networkAcls.defaultAction to Deny."
    }
    # AIG-08: "Azure AI Services resources should use Azure Private Link" v1.0.0 (Audit/Disabled only)
    "aigov-ai-private-link" = {
      definition = "d6759c02-b87f-42b7-892e-71b3f471d782"
      display    = "AIGov: AI Services use Private Link"
      effect     = "Audit"
      message    = "AI Services accounts should be reached through a private endpoint."
    }
    # AIG-13: "Diagnostic logs in Azure AI services resources should be enabled" v1.0.0 (AuditIfNotExists/Disabled)
    "aigov-ai-diag-logs" = {
      definition = "1b4d1c4e-934c-4703-944c-27c82c06bebb"
      display    = "AIGov: AI Services diagnostic logs"
      effect     = "AuditIfNotExists"
      message    = "AI Services accounts must send resource logs to a diagnostic setting."
    }
    # AIG-07: "Cognitive Services accounts should use a managed identity" v1.0.0
    "aigov-ai-managed-id" = {
      definition = "fe3fd216-4f83-4fc1-8984-2bbec80a3418"
      display    = "AIGov: Cognitive Services managed identity"
      effect     = var.managed_identity_policy_effect
      message    = "Cognitive Services accounts must have a managed identity."
    }
  }
}

# AIG-07 AIG-08 AIG-13
resource "azurerm_management_group_policy_assignment" "simple" {
  for_each = local.simple_assignments

  name                 = each.key
  display_name         = each.value.display
  management_group_id  = var.management_group_id
  policy_definition_id = "${local.builtin}/${each.value.definition}"
  enforce              = var.policy_enforce
  location             = var.policy_assignment_location

  parameters = jsonencode({
    effect = { value = each.value.effect }
  })

  non_compliance_message {
    content = each.value.message
  }
}

# AIG-09
# "Azure AI Services resources should encrypt data at rest with a
# customer-managed key (CMK)" v2.2.0. Parameters: effect, excludedKinds.
# NOTE: the built-in default for excludedKinds excludes "AIServices" (Foundry)
# among others, so the assignment overrides it; see var.cmk_policy_excluded_kinds.
resource "azurerm_management_group_policy_assignment" "cmk" {
  name                 = "aigov-ai-cmk"
  display_name         = "AIGov: AI Services encrypt with CMK"
  management_group_id  = var.management_group_id
  policy_definition_id = "${local.builtin}/67121cc7-ff39-4ab8-b7e3-95b84dab487d"
  enforce              = var.policy_enforce
  location             = var.policy_assignment_location

  parameters = jsonencode({
    effect        = { value = var.cmk_policy_effect }
    excludedKinds = { value = var.cmk_policy_excluded_kinds }
  })

  non_compliance_message {
    content = "AI Services accounts holding regulated data must use a customer-managed key (encryption.keySource = Microsoft.KeyVault)."
  }
}

# AIG-06
# "Foundry model deployments should only use approved models" v1.0.2.
# Policy mode Microsoft.CognitiveServices.Data; evaluates
# model.publisher (notin allowedPublishers) AND model.assetId (contains none of
# allowedAssetIds). Parameters: effect, allowedPublishers, allowedAssetIds.
resource "azurerm_management_group_policy_assignment" "approved_models" {
  name                 = "aigov-approved-models"
  display_name         = "AIGov: Foundry approved models only"
  management_group_id  = var.management_group_id
  policy_definition_id = "${local.builtin}/aafe3651-cb78-4f68-9f81-e7e41509110f"
  enforce              = var.policy_enforce
  location             = var.policy_assignment_location

  parameters = jsonencode({
    effect            = { value = var.approved_models_policy_effect }
    allowedPublishers = { value = var.approved_model_publishers }
    allowedAssetIds   = { value = var.approved_model_asset_ids }
  })

  non_compliance_message {
    content = "Only models on the approved-model register can be deployed. Request approval through the AI governance process."
  }
}

# AIG-13 AIG-08 (and evidence for the EU AI Act profile)
# Built-in initiative "EU AI Act 2024 1689" v1.0.1 (6 policies). Its
# parameters are per-member effects named effect-<definition GUID>; their
# defaults are Audit / AuditIfNotExists, so the initiative is assigned with
# default parameters (audit mode).
resource "azurerm_management_group_policy_assignment" "eu_ai_act" {
  count = var.assign_eu_ai_act_initiative ? 1 : 0

  name                 = "aigov-eu-ai-act"
  display_name         = "AIGov: EU AI Act 2024 1689 (audit)"
  management_group_id  = var.management_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/1308bccf-446a-4283-a4e0-0c983fe7a572"
  enforce              = var.policy_enforce
  location             = var.policy_assignment_location
}
