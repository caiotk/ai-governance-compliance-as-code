terraform {
  required_version = ">= 1.6"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # Verified against the v5.9.0 provider schema on 2026-10-13.
      version = "~> 5.9"
    }
  }
}

provider "azurerm" {
  features {}

  # Supply credentials through the environment (ARM_*), Azure CLI or OIDC.
  # The subscription is the one that holds the reference Foundry account and
  # the Defender for AI services plan.
  subscription_id = var.subscription_id
}
