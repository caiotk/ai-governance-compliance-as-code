variable "region" {
  description = "Source Region the application calls (e.g. ap-southeast-2)."
  type        = string
}

variable "workload_id" {
  type = string
}

variable "primary_profile_arn" {
  description = "ARN of the system-defined GEO inference profile for the primary route (e.g. .../inference-profile/au.anthropic.claude-opus-5-5) — keeps data in the geography while routing across its Regions."
  type        = string
}

variable "secondary_profile_arn" {
  description = "ARN of the fallback inference profile (another geo, the global profile where residency allows, or a different model)."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
