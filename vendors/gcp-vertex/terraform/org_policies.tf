# ─────────────────────────────────────────────────────────────────────────────
# Organization Policy constraints for Vertex AI (Gemini Enterprise Agent Platform).
# Sources: https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints
#          https://docs.cloud.google.com/vertex-ai/generative-ai/docs/control-model-access
# Policy names drop the "constraints/" prefix: <parent>/policies/<constraint>.
# ─────────────────────────────────────────────────────────────────────────────

# AIG-06
# Only listed Model Garden models (publishers/PUBLISHER/models/MODEL:ACTION) may be
# used. Without a policy every model is allowed. Does not cover Model Registry.
resource "google_org_policy_policy" "vertexai_allowed_models" {
  name   = "${var.policy_parent}/policies/vertexai.allowedModels"
  parent = var.policy_parent

  spec {
    rules {
      values {
        allowed_values = var.allowed_models
      }
    }
  }
}

# AIG-08 AIG-18
# All location-bound resources under policy_parent (not only Vertex AI) may only be created in the allowed locations.
# UNVERIFIED: whether this constraint also limits where online inference on
# publisher models is processed (e.g. the "global" endpoint). Pin regional
# endpoints in clients and use data residency commitments for inference.
resource "google_org_policy_policy" "resource_locations" {
  count = var.enforce_resource_locations ? 1 : 0

  name   = "${var.policy_parent}/policies/gcp.resourceLocations"
  parent = var.policy_parent

  spec {
    rules {
      values {
        allowed_values = var.allowed_resource_locations
      }
    }
  }
}

# AIG-09
# restrictNonCmekServices lists services that may NOT create resources without
# CMEK. Denying aiplatform.googleapis.com therefore requires CMEK for Vertex AI.
resource "google_org_policy_policy" "require_cmek_vertex" {
  count = var.require_cmek ? 1 : 0

  name   = "${var.policy_parent}/policies/gcp.restrictNonCmekServices"
  parent = var.policy_parent

  spec {
    rules {
      values {
        denied_values = ["aiplatform.googleapis.com"]
      }
    }
  }
}

# AIG-10 AIG-18
# Boolean constraint: disables Grounding with Google Search.
resource "google_org_policy_policy" "disable_google_search_grounding" {
  name   = "${var.policy_parent}/policies/vertexai.disableGenAIGoogleSearchGrounding"
  parent = var.policy_parent

  spec {
    rules {
      enforce = var.disable_google_search_grounding ? "TRUE" : "FALSE"
    }
  }
}

# AIG-06 AIG-10
# Partner model features (web_search, structured_outputs) are blocked by default
# for projects in an organization. A policy is only created when you allow some.
resource "google_org_policy_policy" "allowed_partner_model_features" {
  count = length(var.allowed_partner_model_features) > 0 ? 1 : 0

  name   = "${var.policy_parent}/policies/vertexai.allowedPartnerModelFeatures"
  parent = var.policy_parent

  spec {
    rules {
      values {
        allowed_values = var.allowed_partner_model_features
      }
    }
  }
}
