output "vertex_allowed_models_policy" {
  description = "Name of the vertexai.allowedModels policy, if created (AIG-06 evidence)."
  value       = try(google_org_policy_policy.vertex_allowed_models[0].name, null)
}

output "azure_policy_assignment_id" {
  description = "ID of the Foundry approved-models policy assignment, if created (AIG-06 evidence)."
  value       = try(azurerm_management_group_policy_assignment.foundry_approved_llama[0].id, null)
}

output "bedrock_scp_id" {
  description = "ID of the Bedrock approved-models SCP, if created (AIG-06 evidence)."
  value       = try(aws_organizations_policy.bedrock_approved_models[0].id, null)
}

output "bedrock_scp_json" {
  description = "Rendered SCP document (review before enabling)."
  value       = local.bedrock_scp
}
