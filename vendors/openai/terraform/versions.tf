terraform {
  required_version = ">= 1.6"

  required_providers {
    # Official OpenAI provider (registry tier: community). Source:
    # https://github.com/openai/terraform-provider-openai — latest 1.3.1 (2026-09-25).
    openai = {
      source  = "openai/openai"
      version = "~> 1.3"
    }
  }
}

# Authentication: export OPENAI_ADMIN_KEY (an Admin API key created at
# https://platform.openai.com/settings/organization/admin-keys). Never put the
# key in a .tf or .tfvars file.
provider "openai" {}
