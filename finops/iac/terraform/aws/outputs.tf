output "application_inference_profile_arn" {
  description = "Use this ARN as the modelId in your Bedrock calls so cost lands on the workload tag."
  value       = aws_bedrock_inference_profile.workload.arn
}

output "budget_name" {
  value = aws_budgets_budget.bedrock.name
}
