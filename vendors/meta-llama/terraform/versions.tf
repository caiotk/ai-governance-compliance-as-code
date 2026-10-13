terraform {
  required_version = ">= 1.6"

  # Llama is open weights: Meta operates no control plane to configure. This
  # module governs Llama WHERE IT IS HOSTED. Each host is behind an enable_*
  # variable (all false by default). `terraform validate` needs no credentials;
  # `terraform plan` configures all three providers, so supply credentials for
  # each (or remove the provider blocks/resources for clouds you don't use).
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.6"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.9"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.68"
    }
  }
}

provider "google" {}

provider "azurerm" {
  features {}
}

provider "aws" {}
