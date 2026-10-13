output "dlp_policy_id" {
  description = "Unique name (ID) of the agent baseline data policy."
  value       = powerplatform_data_loss_prevention_policy.agent_baseline.id
}

output "resolved_blocked_connectors" {
  description = "Copilot Studio high-risk connectors: display name => resolved connector ID (null = not resolved; blocked only by the default classification)."
  value       = local.resolved_blocked
}

output "unresolved_blocked_connectors" {
  description = "Display names that did not resolve to a connector ID. Populate blocked_connector_id_overrides for these."
  value       = local.unresolved_blocked
}

output "managed_environment_protection_level" {
  description = "Protection level reported for the production environment (Standard = Managed Environment)."
  value       = powerplatform_managed_environment.production.protection_level
}

output "tenant_isolation_policy_id" {
  description = "ID of the tenant isolation policy, or null if not managed here."
  value       = one(powerplatform_tenant_isolation_policy.this[*].id)
}
