output "policy_assignment_ids" {
  description = "IDs of the management group policy assignments, keyed by assignment name."
  value = merge(
    { for k, v in azurerm_management_group_policy_assignment.simple : k => v.id },
    {
      (azurerm_management_group_policy_assignment.cmk.name)             = azurerm_management_group_policy_assignment.cmk.id
      (azurerm_management_group_policy_assignment.approved_models.name) = azurerm_management_group_policy_assignment.approved_models.id
    },
    { for a in azurerm_management_group_policy_assignment.eu_ai_act : a.name => a.id },
  )
}

output "foundry_account_id" {
  description = "Resource ID of the reference Foundry (AIServices) account, or null if not deployed."
  value       = one(azurerm_cognitive_account.this[*].id)
}

output "foundry_account_endpoint" {
  description = "Endpoint of the reference Foundry account (reachable only through the private endpoint or allowed networks)."
  value       = one(azurerm_cognitive_account.this[*].endpoint)
}

output "foundry_account_principal_id" {
  description = "Object ID of the account's system-assigned managed identity, for RBAC to downstream data (AIG-07)."
  value       = one(azurerm_cognitive_account.this[*].identity[0].principal_id)
}

output "rai_policy_name" {
  description = "Name of the content filter (RAI) policy to reference from other deployments via rai_policy_name."
  value       = one(azurerm_cognitive_account_rai_policy.this[*].name)
}

output "sample_deployment_id" {
  description = "Resource ID of the sample model deployment, or null."
  value       = one(azurerm_cognitive_deployment.sample[*].id)
}

output "defender_for_ai_pricing_id" {
  description = "Resource ID of the Defender for AI services pricing setting, or null."
  value       = one(azurerm_security_center_subscription_pricing.ai[*].id)
}
