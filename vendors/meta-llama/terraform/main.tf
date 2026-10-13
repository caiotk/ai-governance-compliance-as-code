# ─────────────────────────────────────────────────────────────────────────────
# Approved Llama models per host (AIG-06). All three options are off by
# default; enable the ones that match where Llama runs. Resource types and
# arguments were checked against the provider schemas (hashicorp/google 8.6,
# hashicorp/azurerm 5.9, hashicorp/aws 6.68) and the vendor documentation cited in mapping.yaml.
# Self-hosted Llama (vLLM, OGX, SageMaker endpoints in your VPC) is governed by
# the runtime controls in ../native and the zero-trust packs, not here.
# ─────────────────────────────────────────────────────────────────────────────

locals {
  vertex_allowed_values = concat(var.approved_vertex_llama_models, var.additional_vertex_allowed_models)

  bedrock_approved_resources = concat(var.approved_bedrock_model_arns, var.approved_bedrock_inference_profile_arns)

  # Deny Bedrock inference on everything except the approved models/profiles.
  # Denying InvokeModel also blocks Converse and StartAsyncInvoke.
  bedrock_scp = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyUnapprovedBedrockModels"
        Effect = "Deny"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:CreateModelInvocationJob",
        ]
        NotResource = local.bedrock_approved_resources
      }
    ]
  })
}

# AIG-06
# (a) Vertex AI Model Garden: only approved models may be used in this scope.
# If no policy is set, every model is allowed — so set one.
resource "google_org_policy_policy" "vertex_allowed_models" {
  count = var.enable_vertex_allowed_models ? 1 : 0

  name   = "${var.vertex_policy_parent}/policies/vertexai.allowedModels"
  parent = var.vertex_policy_parent

  spec {
    rules {
      values {
        allowed_values = local.vertex_allowed_values
      }
    }
  }

  lifecycle {
    precondition {
      condition     = length(var.approved_vertex_llama_models) > 0
      error_message = "enable_vertex_allowed_models requires at least one approved_vertex_llama_models entry."
    }
    precondition {
      condition     = length(local.vertex_allowed_values) <= 500
      error_message = "vertexai.allowedModels supports at most 500 allowed + denied values."
    }
  }
}

# AIG-06
# (b) Microsoft Foundry: built-in "Foundry model deployments should only use
# approved models" (policy mode Microsoft.CognitiveServices.Data; evaluates
# model.publisher and model.assetId on accounts/deployments).
resource "azurerm_management_group_policy_assignment" "foundry_approved_llama" {
  count = var.enable_azure_approved_models ? 1 : 0

  name                 = "aig-approved-llama"
  display_name         = "AIG-06 Foundry deployments limited to approved Llama models"
  description          = "Only approved Meta Llama models (and explicitly approved publishers) may be deployed."
  management_group_id  = var.azure_management_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/aafe3651-cb78-4f68-9f81-e7e41509110f"
  enforce              = true

  parameters = jsonencode({
    effect            = { value = var.azure_policy_effect }
    allowedPublishers = { value = var.azure_allowed_publishers }
    allowedAssetIds   = { value = var.azure_allowed_asset_ids }
  })

  non_compliance_message {
    content = "AIG-06: only approved Llama models may be deployed. Request approval through the AI model register."
  }

  lifecycle {
    precondition {
      condition     = length(var.azure_allowed_publishers) + length(var.azure_allowed_asset_ids) > 0
      error_message = "enable_azure_approved_models requires azure_allowed_publishers and/or azure_allowed_asset_ids."
    }
  }
}

# AIG-06
# (c) Amazon Bedrock: SCP allow-list for foundation models (Meta model IDs are
# meta.*). AWS documents the deny-inference policy as usable as an SCP.
resource "aws_organizations_policy" "bedrock_approved_models" {
  count = var.enable_bedrock_scp ? 1 : 0

  name        = "aig-bedrock-approved-models"
  description = "AIG-06: deny Bedrock inference on foundation models and inference profiles that are not approved (Llama allow-list)."
  type        = "SERVICE_CONTROL_POLICY"
  content     = local.bedrock_scp
  tags        = var.tags

  lifecycle {
    precondition {
      condition     = length(var.approved_bedrock_model_arns) > 0
      error_message = "enable_bedrock_scp requires at least one approved_bedrock_model_arns entry (an empty allow-list would deny all Bedrock inference)."
    }
  }
}

# AIG-06
resource "aws_organizations_policy_attachment" "bedrock_approved_models" {
  for_each = var.enable_bedrock_scp ? toset(var.bedrock_scp_target_ids) : toset([])

  policy_id = aws_organizations_policy.bedrock_approved_models[0].id
  target_id = each.value
}
