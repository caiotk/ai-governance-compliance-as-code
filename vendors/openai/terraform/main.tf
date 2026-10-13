# ─────────────────────────────────────────────────────────────────────────────
# OpenAI API Platform governance baseline (openai/openai ~> 1.3).
# Every argument below was checked against `terraform providers schema -json`
# for openai/openai 1.3.1 and the OpenAI Terraform guides
# (developers.openai.com/api/docs/guides/terraform/*).
# ─────────────────────────────────────────────────────────────────────────────

locals {
  # Flatten rate limits so each can reference its governed project.
  rate_limits = {
    for k, rl in var.rate_limits : k => merge(rl, { project_id = openai_project.this[rl.project].id })
  }
}

# AIG-02 AIG-08 AIG-18
# One governed project per environment. Destroying an openai_project ARCHIVES it
# (irreversible), so production projects should be protected in your pipeline.
# `geography` (data residency) can only be chosen at creation and needs OpenAI
# sales eligibility; regional traffic then goes to the regional prefix
# (e.g. eu.api.openai.com).
resource "openai_project" "this" {
  for_each = var.projects

  name      = each.value.name
  geography = each.value.geography
}

# AIG-06
# Approved-model allow-list per project ("allow_list" = only these models).
resource "openai_project_model_permissions" "this" {
  for_each = var.projects

  project_id = openai_project.this[each.key].id
  mode       = each.value.model_permission_mode
  model_ids  = each.value.approved_model_ids
}

# AIG-10 AIG-04
# Hosted tools off by default (web search, remote MCP, Code Interpreter, file
# search, image generation). Prerequisite: the org-level tool policy for each
# tool must be "allow selected projects", otherwise setting false fails.
resource "openai_project_hosted_tool_permissions" "this" {
  for_each = var.projects

  project_id               = openai_project.this[each.key].id
  web_search_enabled       = each.value.hosted_tools.web_search
  mcp_enabled              = each.value.hosted_tools.mcp
  code_interpreter_enabled = each.value.hosted_tools.code_interpreter
  file_search_enabled      = each.value.hosted_tools.file_search
  image_generation_enabled = each.value.hosted_tools.image_generation
}

# AIG-05 AIG-18
# Project data retention. Default "organization_default" (inherit the org policy)
# because zero_data_retention / modified_abuse_monitoring are subject to prior
# approval by OpenAI; set them only once approved for your organization.
# Note: removing this resource from config leaves the remote setting unchanged.
resource "openai_project_data_retention" "this" {
  for_each = var.projects

  project_id = openai_project.this[each.key].id
  type       = each.value.data_retention_type
}

# AIG-05 AIG-18
# Optional organization-level retention (only when Terraform owns the setting).
resource "openai_organization_data_retention" "this" {
  count = var.organization_data_retention_type == null ? 0 : 1

  type = var.organization_data_retention_type
}

# AIG-17
# Project rate limits for approved models (updates existing OpenAI records).
resource "openai_project_rate_limit" "this" {
  for_each = local.rate_limits

  project_id                       = each.value.project_id
  rate_limit_id                    = each.value.rate_limit_id
  max_requests_per_1_minute        = each.value.max_requests_per_1_minute
  max_tokens_per_1_minute          = each.value.max_tokens_per_1_minute
  max_images_per_1_minute          = each.value.max_images_per_1_minute
  max_requests_per_1_day           = each.value.max_requests_per_1_day
  max_audio_megabytes_per_1_minute = each.value.max_audio_megabytes_per_1_minute
  batch_1_day_max_input_tokens     = each.value.batch_1_day_max_input_tokens
}

# AIG-17
# Hard monthly spend limit per project: requests return 429 once reached.
# Limits the blast radius of a leaked key or runaway agent loop.
resource "openai_project_spend_limit" "this" {
  for_each = var.projects

  project_id       = openai_project.this[each.key].id
  threshold_amount = each.value.monthly_spend_limit_cents
  currency         = "USD"
  interval         = "month"
}

# AIG-17 AIG-13
# Monthly spend alert (notification only, fires before the hard limit).
resource "openai_project_spend_alert" "this" {
  for_each = var.projects

  project_id                          = openai_project.this[each.key].id
  threshold_amount                    = each.value.spend_alert_threshold_cents
  currency                            = "USD"
  interval                            = "month"
  notification_channel_type           = "email"
  notification_channel_recipients     = var.spend_alert_recipients
  notification_channel_subject_prefix = "OpenAI spend [${each.key}]"
}

# AIG-17
# Optional organization-wide hard spend limit.
resource "openai_organization_spend_limit" "this" {
  count = var.organization_spend_limit_cents == null ? 0 : 1

  threshold_amount = var.organization_spend_limit_cents
  currency         = "USD"
  interval         = "month"
}

# AIG-07 AIG-02
# Non-human workload identity per project. The provider creates the service
# account with NO role and NO API key (create_service_account_only=true).
# Create its scoped API key out of band (native/admin-api.sh) or use workload
# identity federation where supported.
resource "openai_project_service_account" "workload" {
  for_each = var.create_workload_service_accounts ? var.projects : {}

  project_id = openai_project.this[each.key].id
  name       = "${each.value.name}-workload"
}

# AIG-07
# Least-privilege custom project role for the workload (instead of the built-in
# member/owner roles).
resource "openai_project_role" "workload" {
  for_each = var.create_workload_service_accounts ? var.projects : {}

  project_id  = openai_project.this[each.key].id
  role_name   = "${each.value.name} workload"
  description = "Least-privilege role for the ${each.key} workload service account"
  permissions = each.value.workload_permissions
}

# AIG-07
resource "openai_group" "workload" {
  for_each = var.create_workload_service_accounts ? var.projects : {}

  name = "${each.value.name}-workload-access"
}

# AIG-07
resource "openai_group_user" "workload" {
  for_each = var.create_workload_service_accounts ? var.projects : {}

  group_id = openai_group.workload[each.key].group_id
  user_id  = openai_project_service_account.workload[each.key].id
}

# AIG-07
resource "openai_project_group_role" "workload" {
  for_each = var.create_workload_service_accounts ? var.projects : {}

  project_id = openai_project.this[each.key].id
  group_id   = openai_group.workload[each.key].group_id
  role_id    = openai_project_role.workload[each.key].role_id
}
