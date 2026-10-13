# ─────────────────────────────────────────────────────────────────────────────
# Claude (Anthropic) governance POSTURE VERIFICATION.
#
# There is no official Anthropic Terraform provider, so this module does not
# create or change anything. It reads the Claude Admin API with hashicorp/http
# data sources during `terraform plan` and asserts governance expectations with
# `check` blocks (warnings) and an output precondition (hard fail when
# var.fail_on_violation = true). Apply changes with ../native/admin-api.sh or
# in the Claude Console, then re-run `terraform plan` to verify.
#
# Endpoints and fields verified 2026-10-13 against platform.claude.com:
#   GET /v1/organizations/workspaces?limit=1000&include_archived=false
#   GET /v1/organizations/api_keys?status=active&limit=1000
#   GET /v1/organizations/workspaces/{workspace_id}/rate_limits
# Headers: x-api-key (Admin key), anthropic-version: 2023-06-01.
# `terraform validate` makes no network calls; data sources run at plan time.
# ─────────────────────────────────────────────────────────────────────────────

locals {
  headers = {
    "x-api-key"         = var.anthropic_admin_api_key
    "anthropic-version" = var.anthropic_version
  }
}

# AIG-02
# Workspace inventory (the Default Workspace is only listed with
# include_default=true and is not needed here).
data "http" "workspaces" {
  url             = "${var.api_base_url}/v1/organizations/workspaces?limit=1000&include_archived=false"
  request_headers = local.headers

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Admin API GET /v1/organizations/workspaces returned HTTP ${self.status_code}. Check the Admin key (sk-ant-admin...) and that the org is not an individual account."
    }
  }
}

# AIG-02 AIG-07
# Active API key inventory.
data "http" "active_api_keys" {
  url             = "${var.api_base_url}/v1/organizations/api_keys?status=active&limit=1000"
  request_headers = local.headers

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Admin API GET /v1/organizations/api_keys returned HTTP ${self.status_code}."
    }
  }
}

locals {
  workspaces_response = jsondecode(data.http.workspaces.response_body)
  keys_response       = jsondecode(data.http.active_api_keys.response_body)

  workspaces        = local.workspaces_response.data
  workspace_by_name = { for w in local.workspaces : w.name => w... }
  # Names are not guaranteed unique; keep the first non-archived match.
  workspace_id_by_name = { for name, ws in local.workspace_by_name : name => ws[0].id }
  workspace_name_by_id = { for w in local.workspaces : w.id => w.name }

  active_keys = local.keys_response.data

  # AIG-02 required workspaces present.
  missing_workspaces = [for n in var.required_workspaces : n if !contains(keys(local.workspace_id_by_name), n)]

  # AIG-17 Default Workspace keys: the deprecated top-level workspace_id is null
  # for both Default Workspace keys and org-scoped keys; `scope` tells them apart
  # (scope.type == "workspace" with the Default Workspace's real ID).
  default_workspace_keys = [
    for k in local.active_keys : k.id
    if try(k.workspace_id, null) == null && try(k.scope.type, "") == "workspace"
  ]

  # AIG-07 key hygiene.
  stale_keys = [
    for k in local.active_keys : k.id
    if timecmp(timeadd(k.created_at, "${var.max_key_age_days * 24}h"), plantimestamp()) < 0
  ]
  keys_without_expiry = [for k in local.active_keys : k.id if try(k.expires_at, null) == null]

  service_account_only_ids = [for n in var.service_account_only_workspaces : local.workspace_id_by_name[n] if contains(keys(local.workspace_id_by_name), n)]
  personal_keys_in_restricted_workspaces = [
    for k in local.active_keys : k.id
    if try(k.principal.type, "") == "user_actor" && contains(local.service_account_only_ids, try(k.scope.workspace_id, ""))
  ]

  # AIG-08 AIG-18 data residency on US-only workspaces.
  us_only_noncompliant = [
    for n in var.us_only_workspaces : n
    if !contains(keys(local.workspace_by_name), n) || (
      jsonencode(try(local.workspace_by_name[n][0].data_residency.allowed_inference_geos, "unrestricted")) != jsonencode(["us"]) ||
      try(local.workspace_by_name[n][0].data_residency.default_inference_geo, "global") != "us"
    )
  ]

  required_workspace_ids = { for n in var.required_workspaces : n => local.workspace_id_by_name[n] if contains(keys(local.workspace_id_by_name), n) }
}

# AIG-17
# Workspace rate-limit overrides for each required workspace (the Default
# Workspace cannot have overrides; the endpoint returns 404 for it).
data "http" "workspace_rate_limits" {
  for_each = var.require_workspace_rate_limits ? local.required_workspace_ids : {}

  url             = "${var.api_base_url}/v1/organizations/workspaces/${each.value}/rate_limits"
  request_headers = local.headers

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Admin API GET .../workspaces/{id}/rate_limits returned HTTP ${self.status_code}."
    }
  }
}

locals {
  workspaces_without_rate_limits = [
    for n, r in data.http.workspace_rate_limits : n
    if length(try(jsondecode(r.response_body).data, [])) == 0
  ]

  violations = concat(
    [for n in local.missing_workspaces : "AIG-02 required workspace missing or archived: ${n}"],
    local.workspaces_response.has_more ? ["AIG-02 workspace list truncated at 1000; posture incomplete"] : [],
    local.keys_response.has_more ? ["AIG-07 API key list truncated at 1000; posture incomplete"] : [],
    var.allow_default_workspace_keys ? [] : [for id in local.default_workspace_keys : "AIG-17 active API key in Default Workspace (no workspace spend/rate limits possible): ${id}"],
    length(local.active_keys) > var.max_active_api_keys ? ["AIG-07 ${length(local.active_keys)} active API keys exceeds max_active_api_keys=${var.max_active_api_keys}"] : [],
    [for id in local.stale_keys : "AIG-07 active API key older than ${var.max_key_age_days} days: ${id}"],
    var.require_key_expiry ? [for id in local.keys_without_expiry : "AIG-07 active API key without expiry: ${id}"] : [],
    [for id in local.personal_keys_in_restricted_workspaces : "AIG-07 personal (user_actor) key in service-account-only workspace: ${id}"],
    [for n in local.us_only_noncompliant : "AIG-08 workspace ${n} does not enforce allowed_inference_geos=[\"us\"] and default_inference_geo=\"us\""],
    [for n in local.workspaces_without_rate_limits : "AIG-17 workspace ${n} has no workspace rate-limit overrides"],
  )
}

# ── check blocks: reported as warnings on every plan/apply ──────────────────

# AIG-02
check "required_workspaces_exist" {
  assert {
    condition     = length(local.missing_workspaces) == 0
    error_message = "Missing or archived required workspaces: ${join(", ", local.missing_workspaces)}. Create them with native/admin-api.sh create-workspace."
  }
}

# AIG-17 AIG-07
check "no_keys_in_default_workspace" {
  assert {
    condition     = var.allow_default_workspace_keys || length(local.default_workspace_keys) == 0
    error_message = "Active API keys in the Default Workspace (spend/rate limits cannot be set there): ${join(", ", local.default_workspace_keys)}."
  }
}

# AIG-07
check "active_key_count_below_threshold" {
  assert {
    condition     = length(local.active_keys) <= var.max_active_api_keys
    error_message = "${length(local.active_keys)} active API keys exceeds the threshold of ${var.max_active_api_keys}."
  }
}

# AIG-07
check "no_stale_keys" {
  assert {
    condition     = length(local.stale_keys) == 0
    error_message = "Active API keys older than ${var.max_key_age_days} days: ${join(", ", local.stale_keys)}. Rotate in the Console, then disable with native/admin-api.sh disable-key."
  }
}

# AIG-07
check "keys_have_expiry" {
  assert {
    condition     = !var.require_key_expiry || length(local.keys_without_expiry) == 0
    error_message = "Active API keys without expiry: ${join(", ", local.keys_without_expiry)}."
  }
}

# AIG-07
check "no_personal_keys_in_service_account_workspaces" {
  assert {
    condition     = length(local.personal_keys_in_restricted_workspaces) == 0
    error_message = "Personal API keys in service-account-only workspaces: ${join(", ", local.personal_keys_in_restricted_workspaces)}."
  }
}

# AIG-08 AIG-18
check "us_only_inference_geo" {
  assert {
    condition     = length(local.us_only_noncompliant) == 0
    error_message = "Workspaces not restricted to US inference: ${join(", ", local.us_only_noncompliant)}. Fix with native/admin-api.sh set-us-only <workspace_id>."
  }
}

# AIG-17
check "workspace_rate_limits_configured" {
  assert {
    condition     = length(local.workspaces_without_rate_limits) == 0
    error_message = "Required workspaces without rate-limit overrides: ${join(", ", local.workspaces_without_rate_limits)}. Set them in the Console (Rate limits page)."
  }
}
