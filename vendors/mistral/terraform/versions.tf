terraform {
  # `check` blocks need Terraform >= 1.5; the repo baseline is >= 1.6.
  required_version = ">= 1.6"

  required_providers {
    # There is NO official Mistral AI Terraform provider (registry search on
    # 2026-10-13 returned no mistral/mistralai provider; existence of community
    # providers is UNVERIFIED and none is used). This module therefore only
    # READS the Mistral Admin API and the Moderation API with hashicorp/http and
    # verifies posture; changes are applied natively (see ../native/).
    http = {
      source  = "hashicorp/http"
      version = "~> 3.5"
    }
  }
}
