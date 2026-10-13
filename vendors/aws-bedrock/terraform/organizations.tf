# ─────────────────────────────────────────────────────────────────────────────
# AWS Organizations policies. Apply from the management account.
# SCPs never restrict the management account itself.
# ─────────────────────────────────────────────────────────────────────────────

locals {
  org_enabled = var.manage_organization_policies

  allowed_regions = coalesce(var.allowed_regions, [var.aws_region])

  # Foundation-model ARNs have no account segment. The Region wildcard covers
  # every Region a geographic inference profile can route to.
  approved_model_arns = concat(
    [for m in var.approved_foundation_model_ids : "arn:${local.partition}:bedrock:*::foundation-model/${m}"],
    # Global cross-Region inference evaluates a Region-less foundation-model ARN.
    var.allow_global_cross_region_inference ? [for m in var.approved_foundation_model_ids : "arn:${local.partition}:bedrock:::foundation-model/${m}"] : [],
    [for p in var.approved_inference_profile_ids : "arn:${local.partition}:bedrock:*:*:inference-profile/${p}"],
    var.additional_approved_model_resource_arns,
  )

  required_guardrails = coalesce(var.required_guardrail_identifiers, [local.guardrail_identifier])

  scp_statements = concat(
    [
      # AIG-06: deny inference on any model that is not on the allow-list.
      # Denying InvokeModel also blocks Converse and StartAsyncInvoke.
      {
        Sid         = "AIG06DenyUnapprovedBedrockModels"
        Effect      = "Deny"
        Action      = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
        NotResource = local.approved_model_arns
      },
      # AIG-08: Bedrock may only be called in approved Regions.
      {
        Sid      = "AIG08DenyBedrockOutsideApprovedRegions"
        Effect   = "Deny"
        Action   = ["bedrock:*"]
        Resource = ["*"]
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = concat(local.allowed_regions, var.allow_global_cross_region_inference ? ["unspecified"] : [])
          }
        }
      },
    ],
    var.enforce_guardrail_in_scp ? [
      # AIG-07 AIG-10: InvokeModel / Converse calls must name the approved guardrail.
      merge(
        {
          Sid    = "AIG07AIG10DenyInvokeWithoutApprovedGuardrail"
          Effect = "Deny"
          Action = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
          Condition = {
            StringNotEquals = { "bedrock:GuardrailIdentifier" = local.required_guardrails }
          }
        },
        length(var.guardrail_exempt_resource_arns) > 0 ? { NotResource = var.guardrail_exempt_resource_arns } : { Resource = ["*"] },
      )
    ] : [],
    length(var.invocation_logging_admin_role_arns) > 0 ? [
      # AIG-13: only named admin roles may change or delete invocation logging.
      {
        Sid      = "AIG07AIG13ProtectBedrockInvocationLogging"
        Effect   = "Deny"
        Action   = ["bedrock:PutModelInvocationLoggingConfiguration", "bedrock:DeleteModelInvocationLoggingConfiguration"]
        Resource = ["*"]
        Condition = {
          ArnNotLike = { "aws:PrincipalArn" = var.invocation_logging_admin_role_arns }
        }
      }
    ] : [],
  )

  scp_content = jsonencode({
    Version   = "2012-10-17"
    Statement = local.scp_statements
  })

  # Declarative BEDROCK_POLICY: organization-level guardrail enforcement.
  # Shape from https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_bedrock_syntax.html
  bedrock_policy_content = jsonencode({
    bedrock = {
      guardrail_inference = {
        (var.aws_region) = {
          aig10_baseline = {
            identifier = { "@@assign" = local.guardrail_identifier }
            selective_content_guarding = {
              system   = { "@@assign" = var.bedrock_policy_system_guarding }
              messages = { "@@assign" = var.bedrock_policy_messages_guarding }
            }
            model_enforcement = {
              included_models = { "@@assign" = ["ALL"] }
              excluded_models = { "@@assign" = var.bedrock_policy_excluded_models }
            }
          }
        }
      }
    }
  })

  scp_attachments = local.org_enabled ? toset(var.organization_policy_target_ids) : toset([])
  bp_attachments  = local.org_enabled && var.enforce_guardrail_via_bedrock_policy ? toset(var.organization_policy_target_ids) : toset([])
}

# AIG-06 AIG-07 AIG-08 AIG-10 AIG-13
resource "aws_organizations_policy" "bedrock_scp" {
  count = local.org_enabled ? 1 : 0

  name        = "${var.name_prefix}-bedrock-guardrails"
  description = "Bedrock model allow-list, Region restriction, guardrail requirement and logging protection."
  type        = "SERVICE_CONTROL_POLICY"
  content     = local.scp_content

  lifecycle {
    precondition {
      condition     = length(var.approved_foundation_model_ids) + length(var.approved_inference_profile_ids) + length(var.additional_approved_model_resource_arns) > 0
      error_message = "Set approved_foundation_model_ids (and inference profiles) before enabling organization policies, or every model will be denied."
    }
    precondition {
      condition     = length(local.scp_content) <= 10240
      error_message = "The SCP exceeds the 10,240-character limit. Shorten the model lists or split the policy."
    }
  }
}

# AIG-06 AIG-07 AIG-08 AIG-10 AIG-13
resource "aws_organizations_policy_attachment" "bedrock_scp" {
  for_each = local.scp_attachments

  policy_id = aws_organizations_policy.bedrock_scp[0].id
  target_id = each.value
}

# AIG-10
# Organization-level guardrail enforcement. Prerequisites (not managed here):
# BEDROCK_POLICY enabled on the root, and a resource-based policy on the guardrail
# that lets the organization call bedrock:ApplyGuardrail
# (native/cloudformation/guardrail.yaml, OrganizationId parameter; no Terraform resource exists for it).
resource "aws_organizations_policy" "bedrock_guardrail_enforcement" {
  count = local.org_enabled && var.enforce_guardrail_via_bedrock_policy ? 1 : 0

  name        = "${var.name_prefix}-bedrock-guardrail-enforcement"
  description = "Enforces the baseline Bedrock guardrail on all inference in ${var.aws_region}."
  type        = "BEDROCK_POLICY"
  content     = local.bedrock_policy_content
}

# AIG-10
resource "aws_organizations_policy_attachment" "bedrock_guardrail_enforcement" {
  for_each = local.bp_attachments

  policy_id = aws_organizations_policy.bedrock_guardrail_enforcement[0].id
  target_id = each.value
}
