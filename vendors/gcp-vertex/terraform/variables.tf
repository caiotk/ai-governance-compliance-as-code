# ─────────────────────────────────────────────────────────────────────────────
# Scope
# ─────────────────────────────────────────────────────────────────────────────

variable "project_id" {
  description = "Project that runs Vertex AI (Gemini Enterprise Agent Platform) workloads. Hosts the Model Armor template and Data Access audit config, and is the quota project for API calls."
  type        = string
}

variable "policy_parent" {
  description = "Where the organization policies are set: organizations/ORG_ID, folders/FOLDER_ID or projects/PROJECT_ID. Setting them at the organization or folder is recommended."
  type        = string

  validation {
    condition     = can(regex("^(organizations/[0-9]+|folders/[0-9]+|projects/[a-z][a-z0-9-]{4,28}[a-z0-9])$", var.policy_parent))
    error_message = "policy_parent must be organizations/<number>, folders/<number> or projects/<project-id>."
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Organization policy constraints (AIG-06, AIG-08, AIG-09, AIG-10)
# ─────────────────────────────────────────────────────────────────────────────

variable "allowed_models" {
  description = "constraints/vertexai.allowedModels allow-list, format publishers/PUBLISHER/models/MODEL:ACTION (ACTION = predict, deploy or tune). Models must be listed individually (no group wildcards); at most 500 values. Applies to Model Garden models only."
  type        = list(string)
  default     = ["publishers/google/models/gemini-3.5-flash:predict"]

  validation {
    condition     = length(var.allowed_models) > 0 && length(var.allowed_models) <= 500
    error_message = "allowed_models must contain between 1 and 500 entries. An empty list would leave every model allowed."
  }

  validation {
    condition     = alltrue([for m in var.allowed_models : can(regex("^publishers/[^/]+/models/[^/:]+:(predict|deploy|tune)$", m))])
    error_message = "Each allowed model must look like publishers/PUBLISHER/models/MODEL:predict|deploy|tune."
  }
}

variable "allowed_resource_locations" {
  description = "constraints/gcp.resourceLocations allowed values (prefixes in: for value groups, is: for single locations), e.g. [\"in:australia-locations\"] or [\"in:eu-locations\"]. NOTE: this constraint applies to EVERY location-bound GCP service under policy_parent, not only Vertex AI. No default — choose your residency requirement deliberately."
  type        = list(string)

  validation {
    condition     = length(var.allowed_resource_locations) > 0
    error_message = "Set at least one allowed location."
  }
}

variable "enforce_resource_locations" {
  description = "Set constraints/gcp.resourceLocations. Turn off only if location is already governed higher in the hierarchy."
  type        = bool
  default     = true
}

variable "require_cmek" {
  description = "Set constraints/gcp.restrictNonCmekServices to deny aiplatform.googleapis.com, so Vertex AI resources must be created with a customer-managed encryption key."
  type        = bool
  default     = true
}

variable "disable_google_search_grounding" {
  description = "Enforce constraints/vertexai.disableGenAIGoogleSearchGrounding (disables Grounding with Google Search)."
  type        = bool
  default     = true
}

variable "allowed_partner_model_features" {
  description = "constraints/vertexai.allowedPartnerModelFeatures allowed values (for example publishers/anthropic/models/MODEL:web_search). Empty sets no policy, which keeps Google's default for projects in an organization: partner web_search and structured_outputs are blocked."
  type        = list(string)
  default     = []
}

# ─────────────────────────────────────────────────────────────────────────────
# Model Armor (AIG-05, AIG-10)
# ─────────────────────────────────────────────────────────────────────────────

variable "model_armor_floor_setting_parent" {
  description = "Parent of the Model Armor floor setting. Null uses projects/<project_id>; the Vertex AI integration docs say to set Vertex floor settings at project level. folders/ID and organizations/ID are accepted by the API."
  type        = string
  default     = null
}

variable "model_armor_confidence_level" {
  description = "Confidence level for the four Responsible AI filters and the prompt-injection/jailbreak filter: LOW_AND_ABOVE, MEDIUM_AND_ABOVE or HIGH."
  type        = string
  default     = "MEDIUM_AND_ABOVE"

  validation {
    condition     = contains(["LOW_AND_ABOVE", "MEDIUM_AND_ABOVE", "HIGH"], var.model_armor_confidence_level)
    error_message = "Must be LOW_AND_ABOVE, MEDIUM_AND_ABOVE or HIGH."
  }
}

variable "model_armor_block" {
  description = "true = inspect and block requests that trip a filter; false = inspect only (log, do not block)."
  type        = bool
  default     = true
}

variable "model_armor_template_location" {
  description = "Location of the per-request Model Armor template. It must be the same region the Vertex AI request is routed to, or the request fails with 'Template not found'."
  type        = string
  default     = "us-central1"
}

variable "model_armor_template_id" {
  description = "ID of the per-request Model Armor template."
  type        = string
  default     = "aigov-baseline"
}

variable "enable_model_armor_api" {
  description = "Enable modelarmor.googleapis.com in project_id."
  type        = bool
  default     = true
}

variable "grant_model_armor_user_to_vertex_agent" {
  description = "Grant roles/modelarmor.user to the Vertex AI service agent (service-PROJECT_NUMBER@gcp-sa-aiplatform.iam.gserviceaccount.com) so floor settings and templates can screen Vertex AI traffic. The agent exists once the Vertex AI API has been used in the project."
  type        = bool
  default     = true
}

# ─────────────────────────────────────────────────────────────────────────────
# Audit logging (AIG-13)
# ─────────────────────────────────────────────────────────────────────────────

variable "data_access_audit_services" {
  description = "Services that get DATA_READ and DATA_WRITE Data Access audit logs in project_id. Data Access logs are off by default."
  type        = list(string)
  default     = ["aiplatform.googleapis.com"]
}

variable "audit_log_exempted_members" {
  description = "Principals exempt from Data Access logging (for example a high-volume batch service account). Keep empty unless cost requires it."
  type        = list(string)
  default     = []
}

# ─────────────────────────────────────────────────────────────────────────────
# VPC Service Controls (AIG-08)
# ─────────────────────────────────────────────────────────────────────────────

variable "enable_vpc_service_controls" {
  description = "Create a VPC Service Controls perimeter around the Vertex AI projects."
  type        = bool
  default     = false
}

variable "access_policy_name" {
  description = "Access Context Manager policy, as accessPolicies/POLICY_NUMBER. Required when enable_vpc_service_controls = true."
  type        = string
  default     = null
}

variable "perimeter_name" {
  description = "Short name of the service perimeter (letters, digits and underscores)."
  type        = string
  default     = "aigov_vertex_ai"
}

variable "perimeter_project_numbers" {
  description = "Project numbers inside the perimeter. Empty uses project_id's number."
  type        = list(string)
  default     = []
}

variable "perimeter_restricted_services" {
  description = "Services restricted by the perimeter."
  type        = list(string)
  default     = ["aiplatform.googleapis.com", "modelarmor.googleapis.com"]
}

variable "perimeter_access_levels" {
  description = "Access levels (accessPolicies/N/accessLevels/NAME) allowed to reach restricted services from outside the perimeter."
  type        = list(string)
  default     = []
}

variable "perimeter_dry_run" {
  description = "Create the perimeter in dry-run mode (violations are logged, not blocked). Use for first rollout, then set false."
  type        = bool
  default     = false
}
