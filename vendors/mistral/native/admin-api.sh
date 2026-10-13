#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Mistral Admin API — governance evidence and changes applied natively
# (Terraform in ../terraform only VERIFIES posture; there is no official
# Mistral provider).
# Controls: AIG-02 AIG-07 AIG-13
#
# Verified 2026-10-13 (docs.mistral.ai/admin/admin-api/{overview,authentication,
# api-reference} and docs.mistral.ai/api/endpoint/beta/admin/*):
#   Base URL  https://api.mistral.ai/v1/admin
#   Auth      x-api-key: <Admin API key>  (authentication page). The audit-logs
#             reference page shows "Authorization: Bearer" — use --bearer if
#             your tenant rejects x-api-key.
#   GET /v1/admin/users?page=1&page_size=50      members + role_names (documented example)
#   GET /v1/admin/roles                          authoritative role list and UUIDs
#   GET /v1/admin/audit-logs                     AuditLogOut[]: log_id, created_at,
#                                                actor_type, actor_metadata, event_type,
#                                                event_metadata, target_type, target_metadata
#   Reference pages also exist for workspaces, api-keys, analytics, billing and
#   user-groups; their request/response shapes were not verified, so they are
#   exposed here only as a generic `get <path>` passthrough.
#
# Facts that shape this script:
# - The Admin API is available ONLY on Enterprise plans and access is not
#   self-serve; the Admin API key is created in Backoffice (backoffice.mistral.ai)
#   and is tied to one Organization.
# - Roles are predefined and additive. Organization: member | billing_manager |
#   organization_admin. Workspace: user | dev | mistral_code_user |
#   workspace_contributor (default) | workspace_admin | observability_viewer.
#   No custom roles. Role changes are made in the Admin Panel (admin.mistral.ai).
# - Workspace API keys are scoped to the Workspace where they were created;
#   Workspace, connector scope and expiry are immutable after creation, so
#   rotation = create new key + delete old key (Admin Panel / Studio).
# - Audit logs are enabled automatically on Enterprise plans; the UI has no
#   export, so this script is the export path. Retention is not documented —
#   export on a schedule into your SIEM.
#
# Usage:
#   export MISTRAL_ADMIN_KEY=...
#   ./admin-api.sh list-users [page_size]            # pages until a short page
#   ./admin-api.sh org-admins                        # members holding organization_admin
#   ./admin-api.sh list-roles
#   ./admin-api.sh audit-logs [out.jsonl]            # one JSON object per line
#   ./admin-api.sh get /v1/admin/workspaces          # passthrough (shape unverified)
#   add --bearer before the command to use Authorization: Bearer
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

API="${MISTRAL_API_BASE:-https://api.mistral.ai}"
: "${MISTRAL_ADMIN_KEY:?Set MISTRAL_ADMIN_KEY to a Mistral Admin API key (Backoffice → API keys)}"
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 2; }

AUTH_HEADER="x-api-key: ${MISTRAL_ADMIN_KEY}"
if [[ "${1:-}" == "--bearer" ]]; then
  AUTH_HEADER="Authorization: Bearer ${MISTRAL_ADMIN_KEY}"
  shift
fi

log() { printf '[mistral-admin] %s\n' "$*" >&2; }

api() {
  # api METHOD PATH
  local method="$1" path="$2"
  curl -sS --fail-with-body -X "$method" "${API}${path}" \
    -H "$AUTH_HEADER" -H "accept: application/json"
}

# Admin API responses are documented as arrays; tolerate a {"data": [...]} envelope.
unwrap() { jq 'if type == "object" and has("data") then .data else . end'; }

list_users() {
  local page_size="${1:-50}" page=1 n
  while :; do
    local body
    body="$(api GET "/v1/admin/users?page=${page}&page_size=${page_size}" | unwrap)"
    printf '%s\n' "$body" | jq -c '.[]'
    n="$(printf '%s' "$body" | jq 'length')"
    (( n < page_size )) && break
    page=$((page + 1))
  done
}

case "${1:-}" in
  list-users)
    list_users "${2:-50}" | jq -s '.' ;;
  org-admins)
    # AIG-07: role_names is the documented plural field (role_name deprecated).
    list_users 50 | jq -r 'select(((.role_names // [ .role_name ]) | index("organization_admin")) != null) | (.email // .id)' ;;
  list-roles)
    api GET /v1/admin/roles | unwrap ;;
  audit-logs)
    # AIG-13: export for the SIEM. Pagination parameters for this endpoint are
    # not documented; the whole response is written as JSON Lines.
    if [[ -n "${2:-}" ]]; then
      api GET /v1/admin/audit-logs | unwrap | jq -c '.[]' > "$2"
      log "audit log entries written to $2: $(jq -s 'length' "$2")"
    else
      api GET /v1/admin/audit-logs | unwrap | jq -c '.[]'
    fi ;;
  get)
    api GET "${2:?path required, e.g. /v1/admin/workspaces}" ;;
  *)
    sed -n '2,45p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
