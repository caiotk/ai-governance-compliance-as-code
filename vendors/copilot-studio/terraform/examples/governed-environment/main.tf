# ─────────────────────────────────────────────────────────────────────────────
# OPTIONAL example: a governed agent environment with cross-region data
# movement and Bing search turned off.
#
# allow_moving_data_across_regions and allow_bing_search are arguments of
# powerplatform_environment, which manages the WHOLE environment (display
# name, type, location, Dataverse). They cannot be set on an existing
# environment without bringing it under Terraform management, so they live
# here rather than in the root pack. To govern an existing environment, import
# it first:  terraform import powerplatform_environment.agents <environment-guid>
# and make the arguments below match its current values before applying.
#
# Verified against the microsoft/power-platform v4.2.0 schema.
# ─────────────────────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.6"

  required_providers {
    powerplatform = {
      source  = "microsoft/power-platform"
      version = "~> 4.2"
    }
  }
}

provider "powerplatform" {}

variable "display_name" {
  description = "Display name of the agent environment."
  type        = string
}

variable "location" {
  description = "Power Platform location (e.g. europe, unitedstates, australia). Choose one that satisfies residency (AIG-08/AIG-18). Query with data.powerplatform_locations."
  type        = string
}

variable "security_group_id" {
  description = "Entra security group (GUID) whose members can access the environment."
  type        = string
}

variable "language_code" {
  description = "Dataverse language LCID."
  type        = number
  default     = 1033
}

variable "currency_code" {
  description = "Dataverse currency code."
  type        = string
  default     = "USD"
}

# AIG-08 AIG-18
resource "powerplatform_environment" "agents" {
  display_name     = var.display_name
  location         = var.location
  environment_type = "Production"

  # Keep generative AI processing in the environment's region and do not send
  # prompts to Bing.
  allow_moving_data_across_regions = false
  allow_bing_search                = false

  dataverse = {
    language_code     = var.language_code
    currency_code     = var.currency_code
    security_group_id = var.security_group_id
  }

  lifecycle {
    prevent_destroy = true
  }
}

output "environment_id" {
  description = "Pass this to the root pack's environment_id."
  value       = powerplatform_environment.agents.id
}
