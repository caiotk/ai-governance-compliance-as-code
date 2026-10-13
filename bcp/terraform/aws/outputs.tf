output "primary_model_id" {
  description = "Use as modelId for the primary route."
  value       = aws_bedrock_inference_profile.primary.arn
}

output "secondary_model_id" {
  value = aws_bedrock_inference_profile.secondary.arn
}

output "system_profiles_visible" {
  value = [for p in data.aws_bedrock_inference_profiles.system.inference_profile_summaries : p.inference_profile_id]
}
