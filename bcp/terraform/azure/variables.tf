variable "workload_id" {
  type = string
}

variable "primary_account_id" {
  description = "Foundry / Azure OpenAI account in the primary region."
  type        = string
}

variable "secondary_account_id" {
  description = "Foundry / Azure OpenAI account in the secondary region (different Azure region; same data zone if residency requires it)."
  type        = string
}

variable "model_name" {
  type    = string
  default = "gpt-6-luna"
}

variable "model_version" {
  description = "Model version; empty = default version at deploy time."
  type        = string
  default     = ""
}

variable "primary_sku" {
  description = "Deployment type: GlobalStandard (any region), DataZoneStandard (US/EU/APAC zone), Standard (customer geography), *ProvisionedManaged."
  type        = string
  default     = "DataZoneStandard"
  validation {
    condition     = contains(["Standard", "DataZoneStandard", "GlobalStandard", "ProvisionedManaged", "DataZoneProvisionedManaged", "GlobalProvisionedManaged", "DataZoneBatch", "GlobalBatch"], var.primary_sku)
    error_message = "Unknown deployment SKU."
  }
}

variable "secondary_sku" {
  type    = string
  default = "DataZoneStandard"
}

variable "capacity_thousands_tpm" {
  description = "Capacity in thousands of tokens per minute (sku.capacity)."
  type        = number
  default     = 100
}

variable "secondary_capacity_thousands_tpm" {
  description = "Warm-standby capacity in the secondary region (hot/warm topology)."
  type        = number
  default     = 50
}

variable "rai_policy_name" {
  description = "Content-filter (RAI) policy applied to both deployments (AIG-10)."
  type        = string
  default     = "Microsoft.DefaultV2"
}
