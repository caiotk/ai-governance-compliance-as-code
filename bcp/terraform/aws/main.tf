# ─────────────────────────────────────────────────────────────────────────────
# BCP/DR on Amazon Bedrock: application inference profiles for the primary and
# secondary routes, each wrapping a system-defined geo/global profile so a single
# modelId already spans several Regions, and tagged for cost allocation.
# Controls: AIG-17, AIG-18, AIG-22.
#
# Verified 2026-10-13 (docs/sources/finops-bcp-dr.md §1): geo profiles (us., eu.,
# apac., au., jp., in.) route across Regions within a geography; global. routes
# worldwide (no residency); "don't rely on the geographic prefix alone" — call
# GetInferenceProfile from every source Region. Inference profiles don't support
# Provisioned Throughput. aws_bedrock_inference_profile: model_source.copy_from,
# name, description, tags. Data source aws_bedrock_inference_profiles (type).
# ─────────────────────────────────────────────────────────────────────────────

locals {
  tags = merge(var.tags, { "aigov-workload" = var.workload_id, "aigov-control" = "AIG-17" })
}

# AIG-17 AIG-18
# Evidence: the system-defined profiles visible from this source Region.
data "aws_bedrock_inference_profiles" "system" {
  type = "SYSTEM_DEFINED"
}

# AIG-17 AIG-22
resource "aws_bedrock_inference_profile" "primary" {
  name        = "aigov-${var.workload_id}-primary"
  description = "Primary route for ${var.workload_id} (geo cross-Region profile)"
  tags        = merge(local.tags, { "aigov-route" = "primary" })

  model_source {
    copy_from = var.primary_profile_arn
  }
}

# AIG-17 AIG-22
resource "aws_bedrock_inference_profile" "secondary" {
  name        = "aigov-${var.workload_id}-secondary"
  description = "Secondary route for ${var.workload_id} (activated by tools/dr.py failover)"
  tags        = merge(local.tags, { "aigov-route" = "secondary" })

  model_source {
    copy_from = var.secondary_profile_arn
  }
}

# AIG-17
check "primary_profile_is_visible_here" {
  assert {
    condition     = contains([for p in data.aws_bedrock_inference_profiles.system.inference_profile_summaries : p.inference_profile_arn], var.primary_profile_arn)
    error_message = "The primary inference profile is not listed from ${var.region}. Verify destination Regions with GetInferenceProfile from this source Region (data-residency rule)."
  }
}
