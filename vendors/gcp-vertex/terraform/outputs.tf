output "org_policy_names" {
  description = "Organization policies managed by this pack."
  value = compact(concat(
    [google_org_policy_policy.vertexai_allowed_models.name, google_org_policy_policy.disable_google_search_grounding.name],
    google_org_policy_policy.resource_locations[*].name,
    google_org_policy_policy.require_cmek_vertex[*].name,
    google_org_policy_policy.allowed_partner_model_features[*].name,
  ))
}

output "model_armor_floor_setting" {
  description = "Resource name of the Model Armor floor setting."
  value       = google_model_armor_floorsetting.baseline.name
}

output "model_armor_template" {
  description = "Template name to pass as prompt_template_name / response_template_name in model_armor_config."
  value       = google_model_armor_template.baseline.name
}

output "vertex_service_agent" {
  description = "Vertex AI service agent that was granted roles/modelarmor.user."
  value       = local.vertex_service_agent
}

output "data_access_audit_services" {
  description = "Services with DATA_READ and DATA_WRITE audit logs enabled."
  value       = keys(google_project_iam_audit_config.data_access)
}

output "service_perimeter" {
  description = "VPC Service Controls perimeter name (null when disabled)."
  value       = try(google_access_context_manager_service_perimeter.vertex_ai[0].name, null)
}
