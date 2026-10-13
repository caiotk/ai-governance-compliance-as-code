# ── (a) Google Cloud Vertex AI Model Garden ──────────────────────────────────

variable "enable_vertex_allowed_models" {
  description = "Create a vertexai.allowedModels org policy that allows only approved Llama (and other explicitly approved) Model Garden models."
  type        = bool
  default     = false
}

variable "vertex_policy_parent" {
  description = "Org-policy parent: organizations/ORG_ID, folders/FOLDER_ID or projects/PROJECT_ID."
  type        = string
  default     = "projects/PROJECT_ID"

  validation {
    condition     = can(regex("^(organizations|folders|projects)/[^/]+$", var.vertex_policy_parent))
    error_message = "vertex_policy_parent must be organizations/ID, folders/ID or projects/ID."
  }
}

variable "approved_vertex_llama_models" {
  description = <<-EOT
    Approved Meta models in Model Garden, format publishers/meta/models/MODEL_NAME:ACTION where ACTION is
    predict, deploy or tune (e.g. "publishers/meta/models/llama3:deploy" from the Google docs). Models must be
    listed individually (no wildcards); max 500 allowed + denied values in total. Copy exact Llama 4 model
    names from Model Garden — they are not verified in this pack.
  EOT
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for m in var.approved_vertex_llama_models : can(regex("^publishers/meta/models/[^:/]+:(predict|deploy|tune)$", m))])
    error_message = "Each value must look like publishers/meta/models/MODEL_NAME:predict|deploy|tune."
  }
}

variable "additional_vertex_allowed_models" {
  description = "Other approved (non-Meta) Model Garden models. vertexai.allowedModels is an allow-list for ALL Model Garden models in the scope, so anything not listed (including Gemini) is blocked."
  type        = list(string)
  default     = []
}

# ── (b) Microsoft Foundry (Azure Policy built-in) ────────────────────────────

variable "enable_azure_approved_models" {
  description = "Assign the built-in policy 'Foundry model deployments should only use approved models' (aafe3651-cb78-4f68-9f81-e7e41509110f) restricted to approved Meta models."
  type        = bool
  default     = false
}

variable "azure_management_group_id" {
  description = "Management group resource ID for the assignment, e.g. /providers/Microsoft.Management/managementGroups/MG_NAME."
  type        = string
  default     = "/providers/Microsoft.Management/managementGroups/MG_NAME"
}

variable "azure_policy_effect" {
  description = "Policy effect: Deny (default, secure), Audit or Disabled."
  type        = string
  default     = "Deny"

  validation {
    condition     = contains(["Audit", "Deny", "Disabled"], var.azure_policy_effect)
    error_message = "azure_policy_effect must be Audit, Deny or Disabled."
  }
}

variable "azure_allowed_publishers" {
  description = "Publishers whose models are allowed (model.publisher). UNVERIFIED: the exact publisher string Foundry uses for Meta models — read it from an existing deployment before enforcing. Leave empty to allow only specific asset IDs. Add \"Microsoft\" if you use model router."
  type        = list(string)
  default     = []
}

variable "azure_allowed_asset_ids" {
  description = "Allowed model asset IDs (model.assetId), matched as a case-sensitive prefix; a trailing '/' limits the match to one model and '/versions/N' pins a version. UNVERIFIED: registry paths for Llama models — copy them from the Foundry model catalog."
  type        = list(string)
  default     = []
}

# ── (c) Amazon Bedrock (Service Control Policy) ─────────────────────────────

variable "enable_bedrock_scp" {
  description = "Create and attach an SCP that denies Bedrock inference on any foundation model / inference profile not in the approved list."
  type        = bool
  default     = false
}

variable "approved_bedrock_model_arns" {
  description = <<-EOT
    Approved foundation-model ARNs, format arn:aws:bedrock:REGION::foundation-model/MODEL_ID (no account segment;
    REGION may be *), e.g. arn:aws:bedrock:*::foundation-model/meta.<model-id>. The SCP is an allow-list for ALL
    foundation models, so include approved non-Meta models too.
  EOT
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for a in var.approved_bedrock_model_arns : can(regex("^arn:aws:bedrock:[^:]*::foundation-model/.+$", a))])
    error_message = "Use arn:aws:bedrock:REGION::foundation-model/MODEL_ID."
  }
}

variable "approved_bedrock_inference_profile_arns" {
  description = "Approved inference-profile ARNs (arn:aws:bedrock:REGION:ACCOUNT:inference-profile/ID or application-inference-profile/ID). Restrictions on foundation-model ARNs alone may not cover calls made through an inference profile."
  type        = list(string)
  default     = []
}

variable "bedrock_scp_target_ids" {
  description = "AWS Organizations root, OU or account IDs to attach the SCP to."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to taggable resources."
  type        = map(string)
  default = {
    "aig-pack" = "meta-llama"
  }
}
