# AIG-02
output "member_inventory" {
  description = "Organization members with their additive role names (evidence for AIG-02 / AIG-07)."
  value = [
    for u in local.users : {
      id         = try(u.id, null)
      email      = try(u.email, null)
      role_names = try(u.role_names, [try(u.role_name, null)])
    }
  ]
}

# AIG-07
output "organization_admins" {
  description = "Members holding organization_admin."
  value       = local.org_admins
}

# AIG-07
output "available_roles" {
  description = "Role names returned by GET /v1/admin/roles (predefined; no custom roles)."
  value       = local.role_names
}

# AIG-13
output "audit_log_sample_event_types" {
  description = "Distinct event_type values seen in the audit-log response (proves the pipeline is live)."
  value       = distinct([for e in local.audit_logs : try(e.event_type, "")])
}

# AIG-10
output "moderation_categories" {
  description = "Category keys returned by the moderation smoke test (empty when skipped)."
  value       = local.moderation_categories
}

# AIG-02 AIG-07 AIG-10 AIG-13
# CI gate: fails the plan when violations exist and fail_on_violation = true.
output "posture_violations" {
  description = "All governance posture violations found. Empty list = compliant."
  value       = local.violations

  precondition {
    condition     = !var.fail_on_violation || length(local.violations) == 0
    error_message = "Mistral governance posture violations:\n- ${join("\n- ", local.violations)}"
  }
}
