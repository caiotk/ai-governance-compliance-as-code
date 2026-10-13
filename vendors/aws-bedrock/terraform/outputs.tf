output "guardrail_id" {
  description = "ID of the baseline guardrail."
  value       = aws_bedrock_guardrail.baseline.guardrail_id
}

output "guardrail_arn" {
  description = "ARN of the baseline guardrail."
  value       = aws_bedrock_guardrail.baseline.guardrail_arn
}

output "guardrail_version" {
  description = "Numbered guardrail version to pass as guardrailVersion on Converse / InvokeModel."
  value       = aws_bedrock_guardrail_version.baseline.version
}

output "guardrail_identifier" {
  description = "ARN:version string used by bedrock:GuardrailIdentifier conditions and BEDROCK_POLICY."
  value       = local.guardrail_identifier
}

output "invocation_log_group_name" {
  description = "CloudWatch log group receiving model invocation logs."
  value       = try(aws_cloudwatch_log_group.invocations[0].name, null)
}

output "invocation_log_bucket" {
  description = "S3 bucket receiving model invocation logs and large payloads."
  value       = try(aws_s3_bucket.invocations[0].id, null)
}

output "invocation_logging_role_arn" {
  description = "IAM role Bedrock assumes to write to CloudWatch Logs."
  value       = try(aws_iam_role.bedrock_logging[0].arn, null)
}

output "scp_policy_id" {
  description = "ID of the Bedrock service control policy (null when organization policies are off)."
  value       = try(aws_organizations_policy.bedrock_scp[0].id, null)
}

output "bedrock_policy_id" {
  description = "ID of the BEDROCK_POLICY organization policy (null when off)."
  value       = try(aws_organizations_policy.bedrock_guardrail_enforcement[0].id, null)
}

output "scp_content" {
  description = "Rendered SCP JSON, for review before attachment."
  value       = local.scp_content
}

output "bedrock_policy_content" {
  description = "Rendered BEDROCK_POLICY JSON, for review before attachment."
  value       = local.bedrock_policy_content
}

output "vpc_endpoint_ids" {
  description = "Map of Bedrock endpoint service suffix to VPC endpoint ID."
  value       = { for k, v in aws_vpc_endpoint.bedrock : k => v.id }
}
