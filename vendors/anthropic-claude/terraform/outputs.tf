# AIG-02
output "workspace_inventory" {
  description = "Non-archived workspaces with their data-residency settings (evidence for AIG-02 / AIG-08)."
  value = [
    for w in local.workspaces : {
      id                     = w.id
      name                   = w.name
      workspace_geo          = try(w.data_residency.workspace_geo, null)
      allowed_inference_geos = try(jsonencode(w.data_residency.allowed_inference_geos), null)
      default_inference_geo  = try(w.data_residency.default_inference_geo, null)
    }
  ]
}

# AIG-07
output "active_api_key_count" {
  description = "Number of active API keys in the organization."
  value       = length(local.active_keys)
}

# AIG-02 AIG-07 AIG-08 AIG-17
# CI gate: fails the plan when violations exist and fail_on_violation = true.
output "posture_violations" {
  description = "All governance posture violations found. Empty list = compliant."
  value       = local.violations

  precondition {
    condition     = !var.fail_on_violation || length(local.violations) == 0
    error_message = "Claude governance posture violations:\n- ${join("\n- ", local.violations)}"
  }
}
