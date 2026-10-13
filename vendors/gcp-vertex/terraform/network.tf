# ─────────────────────────────────────────────────────────────────────────────
# VPC Service Controls perimeter around Vertex AI and Model Armor.
# Both services are listed as supported (GA) by VPC Service Controls.
# Source: https://docs.cloud.google.com/vpc-service-controls/docs/supported-products
# ─────────────────────────────────────────────────────────────────────────────

locals {
  perimeter_resources = [
    for n in(length(var.perimeter_project_numbers) > 0 ? var.perimeter_project_numbers : [tostring(data.google_project.this.number)]) :
    "projects/${n}"
  ]
}

# AIG-08 AIG-18
resource "google_access_context_manager_service_perimeter" "vertex_ai" {
  count = var.enable_vpc_service_controls ? 1 : 0

  parent         = var.access_policy_name
  name           = "${coalesce(var.access_policy_name, "accessPolicies/UNSET")}/servicePerimeters/${var.perimeter_name}"
  title          = var.perimeter_name
  description    = "AI governance perimeter for Vertex AI and Model Armor (AIG-08)."
  perimeter_type = "PERIMETER_TYPE_REGULAR"

  # Enforced configuration (perimeter_dry_run = false).
  dynamic "status" {
    for_each = var.perimeter_dry_run ? [] : [1]
    content {
      resources           = local.perimeter_resources
      restricted_services = var.perimeter_restricted_services
      access_levels       = var.perimeter_access_levels
    }
  }

  # Dry-run configuration: violations are logged but not blocked.
  use_explicit_dry_run_spec = var.perimeter_dry_run
  dynamic "spec" {
    for_each = var.perimeter_dry_run ? [1] : []
    content {
      resources           = local.perimeter_resources
      restricted_services = var.perimeter_restricted_services
      access_levels       = var.perimeter_access_levels
    }
  }

  lifecycle {
    precondition {
      condition     = var.access_policy_name != null
      error_message = "enable_vpc_service_controls needs access_policy_name (accessPolicies/POLICY_NUMBER)."
    }
  }
}
