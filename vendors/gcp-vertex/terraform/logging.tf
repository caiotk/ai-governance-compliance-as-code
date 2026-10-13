# ─────────────────────────────────────────────────────────────────────────────
# Data Access audit logs. Admin Activity logs are always on; Data Access logs
# for Vertex AI are disabled by default.
# Source: https://docs.cloud.google.com/vertex-ai/docs/general/audit-logging
# ─────────────────────────────────────────────────────────────────────────────

# AIG-13
# Logs DATA_READ (e.g. endpoints.predict, endpoints.rawPredict, endpoints.explain)
# and DATA_WRITE for each listed service. google_project_iam_audit_config is
# authoritative for the given service only, not for the whole IAM policy.
resource "google_project_iam_audit_config" "data_access" {
  for_each = toset(var.data_access_audit_services)

  project = var.project_id
  service = each.value

  audit_log_config {
    log_type         = "DATA_READ"
    exempted_members = var.audit_log_exempted_members
  }

  audit_log_config {
    log_type         = "DATA_WRITE"
    exempted_members = var.audit_log_exempted_members
  }
}
