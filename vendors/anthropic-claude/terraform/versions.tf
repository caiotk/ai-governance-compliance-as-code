terraform {
  # `check` blocks need Terraform >= 1.5; the repo baseline is >= 1.6.
  required_version = ">= 1.6"

  required_providers {
    # There is NO official Anthropic Terraform provider (registry.terraform.io
    # anthropic/anthropic and anthropics/anthropic return 404 as of 2026-10-13).
    # Community providers exist but are not Anthropic-maintained and are not used.
    # This module therefore only READS the Claude Admin API (hashicorp/http) and
    # verifies posture; changes are applied natively (see ../native/).
    http = {
      source  = "hashicorp/http"
      version = "~> 3.5"
    }
  }
}
