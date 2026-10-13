output "project_ids" {
  description = "Governed project IDs by environment."
  value       = { for k, p in openai_project.this : k => p.id }
}

output "approved_models" {
  description = "Model permission mode and model IDs per project (evidence for AIG-06)."
  value = {
    for k, m in openai_project_model_permissions.this : k => {
      mode      = m.mode
      model_ids = m.model_ids
    }
  }
}

output "data_retention" {
  description = "Data-retention type per project (evidence for AIG-05)."
  value       = { for k, r in openai_project_data_retention.this : k => r.type }
}

output "spend_limit_enforcement_status" {
  description = "Hard spend-limit enforcement status per project (evidence for AIG-17)."
  value       = { for k, s in openai_project_spend_limit.this : k => s.enforcement_status }
}

output "workload_service_account_ids" {
  description = "Workload service-account IDs per project. Create their scoped API keys out of band; never pass keys through Terraform."
  value       = { for k, sa in openai_project_service_account.workload : k => sa.service_account_id }
}
