terraform {
  required_version = ">= 1.6"

  required_providers {
    powerplatform = {
      source = "microsoft/power-platform"
      # Verified against the v4.2.0 provider schema on 2026-10-13.
      version = "~> 4.2"
    }
  }
}

# Authenticate with the Azure CLI (use_cli), OIDC or a service principal via
# the provider's POWER_PLATFORM_* environment variables. The identity needs the
# Power Platform administrator role. No credentials are stored here.
provider "powerplatform" {}
