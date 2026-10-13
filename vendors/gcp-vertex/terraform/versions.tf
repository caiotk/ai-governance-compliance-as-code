terraform {
  required_version = ">= 1.6"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.6"
    }
  }
}

provider "google" {
  project = var.project_id

  # Org- and folder-level APIs (Org Policy, Model Armor floor settings, Access
  # Context Manager) need a quota project when called with user credentials.
  billing_project       = var.project_id
  user_project_override = true
}
