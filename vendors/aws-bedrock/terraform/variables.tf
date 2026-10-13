# ─────────────────────────────────────────────────────────────────────────────
# General
# ─────────────────────────────────────────────────────────────────────────────

variable "aws_region" {
  description = "Region where the guardrail, invocation logging and VPC endpoints are created. Bedrock invocation logging is per Region, so apply this pack once per Region you use."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for every resource name created by this pack."
  type        = string
  default     = "aigov"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,20}$", var.name_prefix))
    error_message = "name_prefix must be 1-20 characters of lowercase letters, digits and hyphens."
  }
}

variable "tags" {
  description = "Tags applied to every taggable resource (provider default_tags)."
  type        = map(string)
  default = {
    "managed-by" = "terraform"
    "aigov-pack" = "aws-bedrock"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Guardrail (AIG-05, AIG-09, AIG-10)
# ─────────────────────────────────────────────────────────────────────────────

variable "blocked_input_messaging" {
  description = "Message returned to the caller when the guardrail blocks a prompt."
  type        = string
  default     = "This request was blocked by your organisation's AI usage policy."
}

variable "blocked_outputs_messaging" {
  description = "Message returned to the caller when the guardrail blocks a model response."
  type        = string
  default     = "The response was blocked by your organisation's AI usage policy."
}

variable "content_filter_strength" {
  description = "Input and output strength for the HATE, INSULTS, SEXUAL, VIOLENCE and MISCONDUCT content filters."
  type        = string
  default     = "HIGH"

  validation {
    condition     = contains(["NONE", "LOW", "MEDIUM", "HIGH"], var.content_filter_strength)
    error_message = "content_filter_strength must be one of NONE, LOW, MEDIUM, HIGH."
  }
}

variable "prompt_attack_strength" {
  description = "Input strength for the PROMPT_ATTACK filter (output strength is always NONE)."
  type        = string
  default     = "HIGH"

  validation {
    condition     = contains(["NONE", "LOW", "MEDIUM", "HIGH"], var.prompt_attack_strength)
    error_message = "prompt_attack_strength must be one of NONE, LOW, MEDIUM, HIGH."
  }
}

variable "guardrail_tier" {
  description = "Safeguard tier for content filters and denied topics: CLASSIC or STANDARD. STANDARD needs guardrail_profile_identifier (cross-Region guardrail inference)."
  type        = string
  default     = "CLASSIC"

  validation {
    condition     = contains(["CLASSIC", "STANDARD"], var.guardrail_tier)
    error_message = "guardrail_tier must be CLASSIC or STANDARD."
  }
}

variable "guardrail_profile_identifier" {
  description = "System-defined guardrail profile ID or ARN for cross-Region guardrail inference. Required when guardrail_tier = STANDARD. Prompts may leave the source Region inside the profile's geography."
  type        = string
  default     = null
}

variable "baseline_pii_entities" {
  description = "Baseline PII entity types and actions (BLOCK, ANONYMIZE or NONE)."
  type = list(object({
    type   = string
    action = string
  }))
  default = [
    { type = "EMAIL", action = "ANONYMIZE" },
    { type = "PHONE", action = "ANONYMIZE" },
    { type = "NAME", action = "ANONYMIZE" },
    { type = "ADDRESS", action = "ANONYMIZE" },
    { type = "CREDIT_DEBIT_CARD_NUMBER", action = "BLOCK" },
    { type = "CREDIT_DEBIT_CARD_CVV", action = "BLOCK" },
    { type = "PASSWORD", action = "BLOCK" },
    { type = "AWS_ACCESS_KEY", action = "BLOCK" },
    { type = "AWS_SECRET_KEY", action = "BLOCK" },
  ]

  validation {
    condition     = alltrue([for e in var.baseline_pii_entities : contains(["BLOCK", "ANONYMIZE", "NONE"], e.action)])
    error_message = "Each PII entity action must be BLOCK, ANONYMIZE or NONE."
  }
}

variable "additional_pii_entities" {
  description = "Extra PII entity types for your jurisdiction (for example US_SOCIAL_SECURITY_NUMBER, UK_NATIONAL_INSURANCE_NUMBER, INTERNATIONAL_BANK_ACCOUNT_NUMBER)."
  type = list(object({
    type   = string
    action = string
  }))
  default = []

  validation {
    condition     = alltrue([for e in var.additional_pii_entities : contains(["BLOCK", "ANONYMIZE", "NONE"], e.action)])
    error_message = "Each PII entity action must be BLOCK, ANONYMIZE or NONE."
  }
}

variable "pii_regexes" {
  description = "Custom regex sensitive-information filters (for identifiers with no managed PII type, such as a national tax number)."
  type = list(object({
    name        = string
    description = string
    pattern     = string
    action      = string
  }))
  default = []

  validation {
    condition     = alltrue([for r in var.pii_regexes : contains(["BLOCK", "ANONYMIZE", "NONE"], r.action)])
    error_message = "Each regex action must be BLOCK, ANONYMIZE or NONE."
  }
}

variable "denied_topics" {
  description = "Denied topics. Definitions are limited to 200 characters on the CLASSIC tier (1,000 on STANDARD); up to 5 examples of at most 100 characters each."
  type = list(object({
    name       = string
    definition = string
    examples   = list(string)
  }))
  default = [
    {
      name       = "Legal advice"
      definition = "Requests for, or responses giving, specific legal advice or legal opinions about an individual's own circumstances."
      examples = [
        "Should I sign this contract?",
        "Can I sue my landlord over this?",
      ]
    },
  ]
}

variable "enable_profanity_filter" {
  description = "Enable the AWS-managed PROFANITY word list."
  type        = bool
  default     = true
}

variable "blocked_words" {
  description = "Custom words or phrases the guardrail blocks."
  type        = list(string)
  default     = []
}

variable "enable_contextual_grounding" {
  description = "Enable contextual grounding checks (GROUNDING and RELEVANCE). They only evaluate requests that supply a grounding source and query."
  type        = bool
  default     = true
}

variable "grounding_threshold" {
  description = "Confidence threshold for the GROUNDING check (0 to 0.99)."
  type        = number
  default     = 0.75

  validation {
    condition     = var.grounding_threshold >= 0 && var.grounding_threshold < 1
    error_message = "grounding_threshold must be between 0 and 0.99."
  }
}

variable "relevance_threshold" {
  description = "Confidence threshold for the RELEVANCE check (0 to 0.99)."
  type        = number
  default     = 0.75

  validation {
    condition     = var.relevance_threshold >= 0 && var.relevance_threshold < 1
    error_message = "relevance_threshold must be between 0 and 0.99."
  }
}

variable "guardrail_kms_key_arn" {
  description = "Customer managed KMS key ARN that encrypts the guardrail. Null uses an AWS owned key. Callers then need kms:Decrypt on this key."
  type        = string
  default     = null
}

# ─────────────────────────────────────────────────────────────────────────────
# Model invocation logging (AIG-09, AIG-13)
# ─────────────────────────────────────────────────────────────────────────────

variable "enable_invocation_logging" {
  description = "Turn on Bedrock model invocation logging for this account and Region (it is off by default in AWS)."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention for invocation logs, in days. Must be a value CloudWatch accepts."
  type        = number
  default     = 400

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.log_retention_days)
    error_message = "log_retention_days must be a CloudWatch Logs retention value (for example 365, 400, 731, 2557)."
  }
}

variable "log_bucket_name" {
  description = "Name of the S3 bucket for invocation logs. Null generates <name_prefix>-bedrock-logs-<account>-<region>."
  type        = string
  default     = null
}

variable "log_key_prefix" {
  description = "S3 key prefix for invocation log objects (no leading or trailing slash). Empty string writes at the bucket root."
  type        = string
  default     = "bedrock"

  validation {
    condition     = !startswith(var.log_key_prefix, "/") && !endswith(var.log_key_prefix, "/")
    error_message = "log_key_prefix must not start or end with a slash."
  }
}

variable "logging_kms_key_arn" {
  description = "Customer managed KMS key ARN for the log bucket (SSE-KMS) and the CloudWatch log group. Null uses SSE-S3 and the CloudWatch default encryption. The key policy must allow bedrock.amazonaws.com kms:GenerateDataKey and logs.<region>.amazonaws.com to use the key."
  type        = string
  default     = null
}

variable "log_bucket_force_destroy" {
  description = "Allow terraform destroy to delete a non-empty log bucket. Keep false to protect evidence."
  type        = bool
  default     = false
}

variable "log_text_data" {
  description = "Include text prompts and completions in invocation logs."
  type        = bool
  default     = true
}

variable "log_image_data" {
  description = "Include image inputs and outputs in invocation logs."
  type        = bool
  default     = true
}

variable "log_embedding_data" {
  description = "Include embeddings in invocation logs (large volume, low audit value)."
  type        = bool
  default     = false
}

variable "log_video_data" {
  description = "Include video inputs and outputs in invocation logs."
  type        = bool
  default     = true
}

# ─────────────────────────────────────────────────────────────────────────────
# AWS Organizations policies (AIG-06, AIG-07, AIG-08, AIG-10)
# Apply from the management account (or a delegated policy administrator).
# ─────────────────────────────────────────────────────────────────────────────

variable "manage_organization_policies" {
  description = "Create and attach the Bedrock SCP and the BEDROCK_POLICY. Requires running in the Organizations management account with the SERVICE_CONTROL_POLICY and BEDROCK_POLICY policy types enabled on the root."
  type        = bool
  default     = false
}

variable "organization_policy_target_ids" {
  description = "Root, OU or account IDs to attach the organization policies to (placeholders such as ou-xxxx-xxxxxxxx)."
  type        = list(string)
  default     = []
}

variable "approved_foundation_model_ids" {
  description = "Foundation model IDs that may be invoked (for example amazon.titan-embed-text-v2:0). Everything else is denied by the SCP. Required when manage_organization_policies = true."
  type        = list(string)
  default     = []
}

variable "approved_inference_profile_ids" {
  description = "System-defined inference profile IDs that may be invoked (for example us.<model-id> or apac.<model-id>). Include the matching foundation model in approved_foundation_model_ids too."
  type        = list(string)
  default     = []
}

variable "additional_approved_model_resource_arns" {
  description = "Extra Bedrock resource ARNs exempt from the model allow-list (provisioned models, custom models, application inference profiles). Wildcards allowed."
  type        = list(string)
  default     = []
}

variable "enforce_guardrail_in_scp" {
  description = "Add an SCP statement that denies InvokeModel and InvokeModelWithResponseStream unless the request names the approved guardrail (bedrock:GuardrailIdentifier)."
  type        = bool
  default     = true
}

variable "required_guardrail_identifiers" {
  description = "Guardrail identifiers (ARN:version) accepted by the SCP guardrail statement. Null uses this pack's guardrail and version."
  type        = list(string)
  default     = null
}

variable "guardrail_exempt_resource_arns" {
  description = "Model resource ARNs exempt from the SCP guardrail statement, such as embedding models that cannot take a guardrail. Empty means every model needs the guardrail."
  type        = list(string)
  default     = []
}

variable "allowed_regions" {
  description = "Regions where Bedrock may be called. Null allows only aws_region. Geographic cross-Region inference needs every destination Region of the profile in this list."
  type        = list(string)
  default     = null
}

variable "allow_global_cross_region_inference" {
  description = "Allow global cross-Region inference (aws:RequestedRegion = unspecified). Off keeps inference inside the allowed Regions."
  type        = bool
  default     = false
}

variable "enforce_guardrail_via_bedrock_policy" {
  description = "Create the declarative BEDROCK_POLICY that enforces the guardrail on every Bedrock inference call in the targets for aws_region."
  type        = bool
  default     = true
}

variable "bedrock_policy_system_guarding" {
  description = "selective_content_guarding.system for BEDROCK_POLICY: comprehensive evaluates all system prompt content; selective evaluates only tagged content."
  type        = string
  default     = "comprehensive"

  validation {
    condition     = contains(["comprehensive", "selective"], var.bedrock_policy_system_guarding)
    error_message = "Must be comprehensive or selective."
  }
}

variable "bedrock_policy_messages_guarding" {
  description = "selective_content_guarding.messages for BEDROCK_POLICY: comprehensive or selective."
  type        = string
  default     = "comprehensive"

  validation {
    condition     = contains(["comprehensive", "selective"], var.bedrock_policy_messages_guarding)
    error_message = "Must be comprehensive or selective."
  }
}

variable "bedrock_policy_excluded_models" {
  description = "Model IDs excluded from organization-level guardrail enforcement (for example embedding models)."
  type        = list(string)
  default     = []
}

variable "invocation_logging_admin_role_arns" {
  description = "IAM role ARNs (wildcards allowed) that may change or delete Bedrock invocation logging in member accounts. Empty omits the protection statement."
  type        = list(string)
  default     = []
}

# ─────────────────────────────────────────────────────────────────────────────
# Private connectivity (AIG-08)
# ─────────────────────────────────────────────────────────────────────────────

variable "enable_vpc_endpoints" {
  description = "Create interface VPC endpoints (PrivateLink) for Bedrock with private DNS."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC for the interface endpoints. Required when enable_vpc_endpoints = true."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Private subnet IDs for the endpoint network interfaces (one per AZ)."
  type        = list(string)
  default     = []
}

variable "endpoint_allowed_cidrs" {
  description = "CIDR blocks allowed to reach the endpoints on TCP 443."
  type        = list(string)
  default     = []
}

variable "vpc_endpoint_services" {
  description = "Bedrock endpoint service suffixes (com.amazonaws.<region>.<suffix>)."
  type        = list(string)
  default     = ["bedrock", "bedrock-runtime", "bedrock-agent-runtime"]

  validation {
    condition = alltrue([for s in var.vpc_endpoint_services : contains(
      ["bedrock", "bedrock-runtime", "bedrock-mantle", "bedrock-agent", "bedrock-agent-runtime", "bedrock-fips", "bedrock-runtime-fips"], s
    )])
    error_message = "Unsupported Bedrock endpoint service suffix."
  }
}
