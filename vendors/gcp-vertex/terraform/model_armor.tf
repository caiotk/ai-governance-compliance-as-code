# ─────────────────────────────────────────────────────────────────────────────
# Model Armor. Gemini safety settings are per request, and OFF is the default
# for gemini-3.5-flash and later models, so the floor setting is the central
# runtime control. It screens Vertex AI generateContent calls project-wide.
# Sources: https://docs.cloud.google.com/model-armor/configure-floor-settings
#          https://docs.cloud.google.com/model-armor/model-armor-vertex-integration
# ─────────────────────────────────────────────────────────────────────────────

data "google_project" "this" {
  project_id = var.project_id
}

locals {
  floor_setting_parent = coalesce(var.model_armor_floor_setting_parent, "projects/${var.project_id}")
  rai_filter_types     = ["HATE_SPEECH", "HARASSMENT", "SEXUALLY_EXPLICIT", "DANGEROUS"]
  vertex_service_agent = "serviceAccount:service-${data.google_project.this.number}@gcp-sa-aiplatform.iam.gserviceaccount.com"
}

# AIG-10
resource "google_project_service" "model_armor" {
  count = var.enable_model_armor_api ? 1 : 0

  project            = var.project_id
  service            = "modelarmor.googleapis.com"
  disable_on_destroy = false
}

# AIG-05 AIG-10 AIG-13
# Floor setting: minimum filters for every template and, through
# integrated_services = AI_PLATFORM, for all Vertex AI generateContent traffic.
resource "google_model_armor_floorsetting" "baseline" {
  parent   = local.floor_setting_parent
  location = "global"

  filter_config {
    rai_settings {
      dynamic "rai_filters" {
        for_each = local.rai_filter_types
        content {
          filter_type      = rai_filters.value
          confidence_level = var.model_armor_confidence_level
        }
      }
    }

    pi_and_jailbreak_filter_settings {
      filter_enforcement = "ENABLED"
      confidence_level   = var.model_armor_confidence_level
    }

    malicious_uri_filter_settings {
      filter_enforcement = "ENABLED"
    }

    sdp_settings {
      basic_config {
        filter_enforcement = "ENABLED"
      }
    }
  }

  enable_floor_setting_enforcement = true
  integrated_services              = ["AI_PLATFORM"]

  ai_platform_floor_setting {
    # inspect_and_block and inspect_only are alternatives; set only one.
    inspect_and_block    = var.model_armor_block ? true : null
    inspect_only         = var.model_armor_block ? null : true
    enable_cloud_logging = true
  }

  depends_on = [google_project_service.model_armor]
}

# AIG-05 AIG-10
# Per-request template for workloads that pass model_armor_config
# (prompt_template_name / response_template_name) on generateContent, or that
# call the Model Armor sanitize APIs directly. Must sit in the request's region.
resource "google_model_armor_template" "baseline" {
  project     = var.project_id
  location    = var.model_armor_template_location
  template_id = var.model_armor_template_id

  filter_config {
    rai_settings {
      dynamic "rai_filters" {
        for_each = local.rai_filter_types
        content {
          filter_type      = rai_filters.value
          confidence_level = var.model_armor_confidence_level
        }
      }
    }

    pi_and_jailbreak_filter_settings {
      filter_enforcement = "ENABLED"
      confidence_level   = var.model_armor_confidence_level
    }

    malicious_uri_filter_settings {
      filter_enforcement = "ENABLED"
    }

    sdp_settings {
      basic_config {
        filter_enforcement = "ENABLED"
      }
    }
  }

  template_metadata {
    enforcement_type        = var.model_armor_block ? "INSPECT_AND_BLOCK" : "INSPECT_ONLY"
    log_sanitize_operations = true
    log_template_operations = true
  }

  depends_on = [google_project_service.model_armor]
}

# AIG-07 AIG-10
# The Vertex AI service agent needs Model Armor User to call Model Armor.
resource "google_project_iam_member" "vertex_agent_model_armor_user" {
  count = var.grant_model_armor_user_to_vertex_agent ? 1 : 0

  project = var.project_id
  role    = "roles/modelarmor.user"
  member  = local.vertex_service_agent
}
