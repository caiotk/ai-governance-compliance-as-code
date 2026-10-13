# ─────────────────────────────────────────────────────────────────────────────
# Mistral AI (La Plateforme) governance POSTURE VERIFICATION.
#
# There is no official Mistral Terraform provider, so this module does not
# create or change anything. During `terraform plan` it reads the Mistral Admin
# API (Enterprise plans only) and the Moderation API with hashicorp/http data
# sources and asserts governance expectations with `check` blocks (warnings)
# and an output precondition (hard fail when var.fail_on_violation = true).
# Apply changes with ../native/admin-api.sh or in the Admin Panel
# (admin.mistral.ai), then re-run `terraform plan` to verify.
#
# Endpoints verified 2026-10-13 against docs.mistral.ai:
#   GET  /v1/admin/users?page=1&page_size=50     (documented example, verbatim)
#   GET  /v1/admin/audit-logs                    AuditLogOut[]: log_id, created_at,
#                                                actor_type, event_type, target_type …
#   GET  /v1/admin/roles                         authoritative role list / UUIDs
#   POST /v1/moderations                         {"model","input"} → results[].categories
# Admin auth header: x-api-key (authentication page). The audit-logs reference
# page shows Authorization: Bearer instead — var.admin_auth_scheme covers both.
# Response envelopes for the Admin API are not documented in detail; locals
# below accept either a bare array or a {"data": [...]} object.
# `terraform validate` makes no network calls; data sources run at plan time.
# ─────────────────────────────────────────────────────────────────────────────

locals {
  admin_headers = var.admin_auth_scheme == "bearer" ? {
    "Authorization" = "Bearer ${var.mistral_admin_api_key}"
    } : {
    "x-api-key" = var.mistral_admin_api_key
  }
}

# AIG-02 AIG-07
# Organization member inventory with their (additive) roles.
data "http" "admin_users" {
  url             = "${var.api_base_url}/v1/admin/users?page=1&page_size=${var.users_page_size}"
  request_headers = local.admin_headers

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Admin API GET /v1/admin/users returned HTTP ${self.status_code}. The Admin API is Enterprise-only and the key must be an Admin API key from Backoffice (not a Workspace key)."
    }
  }
}

# AIG-13
# Audit log reachability: Enterprise plans have audit logs enabled automatically;
# the API is the only documented export path (the Admin Panel has no UI export).
data "http" "audit_logs" {
  count = var.require_audit_logs ? 1 : 0

  url             = "${var.api_base_url}/v1/admin/audit-logs"
  request_headers = local.admin_headers

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Admin API GET /v1/admin/audit-logs returned HTTP ${self.status_code}; audit-log evidence for AIG-13 is unavailable."
    }
  }
}

# AIG-07
# Role catalogue (predefined roles only; no custom roles are documented).
data "http" "roles" {
  url             = "${var.api_base_url}/v1/admin/roles"
  request_headers = local.admin_headers

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Admin API GET /v1/admin/roles returned HTTP ${self.status_code}."
    }
  }
}

# AIG-10
# Moderation endpoint smoke test with a Workspace key: proves the guardrail
# model is reachable from this Workspace and that the category keys the gate
# relies on are present. Skipped when var.moderation_smoke_test = false.
data "http" "moderation_smoke" {
  count = var.moderation_smoke_test ? 1 : 0

  url    = "${var.api_base_url}/v1/moderations"
  method = "POST"
  request_headers = {
    "Authorization" = "Bearer ${var.mistral_api_key}"
    "Content-Type"  = "application/json"
  }
  request_body = jsonencode({
    model = var.moderation_model
    input = ["governance smoke test: benign text"]
  })

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "POST /v1/moderations returned HTTP ${self.status_code}; moderation guardrails cannot be evidenced for this Workspace."
    }
  }
}

locals {
  users_raw       = jsondecode(data.http.admin_users.response_body)
  users           = try(local.users_raw.data, local.users_raw)
  roles_raw       = jsondecode(data.http.roles.response_body)
  roles           = try(local.roles_raw.data, local.roles_raw)
  role_names      = [for r in local.roles : try(r.name, r.role_name, "")]
  audit_raw       = var.require_audit_logs ? jsondecode(data.http.audit_logs[0].response_body) : []
  audit_logs      = try(local.audit_raw.data, local.audit_raw)
  users_page_full = length(local.users) >= var.users_page_size

  # AIG-07 organization_admin holders (role_names is the documented plural
  # field; the singular role_name is deprecated but still accepted here).
  org_admins = [
    for u in local.users : try(u.email, u.id, "unknown")
    if contains(try(u.role_names, [try(u.role_name, "")]), "organization_admin")
  ]

  moderation_categories = var.moderation_smoke_test ? keys(try(jsondecode(data.http.moderation_smoke[0].response_body).results[0].categories, {})) : []
  missing_categories    = var.moderation_smoke_test ? [for c in var.required_moderation_categories : c if !contains(local.moderation_categories, c)] : []

  violations = concat(
    length(local.org_admins) > var.max_org_admins ? ["AIG-07 ${length(local.org_admins)} organization_admin members exceeds max_org_admins=${var.max_org_admins}: ${join(", ", local.org_admins)}"] : [],
    local.users_page_full ? ["AIG-02 user list reached page_size=${var.users_page_size}; only the first page was evaluated, posture incomplete"] : [],
    var.require_audit_logs && length(local.audit_logs) == 0 ? ["AIG-13 audit log returned no entries; confirm audit logging is active for this Organization"] : [],
    [for c in local.missing_categories : "AIG-10 moderation response lacks category '${c}' for model ${var.moderation_model}"],
  )
}

# ── check blocks: reported as warnings on every plan/apply ──────────────────

# AIG-07
check "org_admin_count_below_threshold" {
  assert {
    condition     = length(local.org_admins) <= var.max_org_admins
    error_message = "${length(local.org_admins)} organization_admin members exceeds the threshold of ${var.max_org_admins}: ${join(", ", local.org_admins)}. Demote to member/workspace roles in the Admin Panel."
  }
}

# AIG-02
check "user_inventory_complete" {
  assert {
    condition     = !local.users_page_full
    error_message = "User inventory truncated at page_size=${var.users_page_size}; raise users_page_size or page through native/admin-api.sh list-users."
  }
}

# AIG-13
check "audit_logs_have_entries" {
  assert {
    condition     = !var.require_audit_logs || length(local.audit_logs) > 0
    error_message = "GET /v1/admin/audit-logs returned no entries."
  }
}

# AIG-10
check "moderation_categories_present" {
  assert {
    condition     = length(local.missing_categories) == 0
    error_message = "Moderation response is missing categories: ${join(", ", local.missing_categories)}. The key set is model-version dependent; align required_moderation_categories and native/moderation-gate.sh."
  }
}
