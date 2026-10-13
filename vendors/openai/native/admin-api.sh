#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# OpenAI Administration API — governance baseline applied natively (no Terraform).
# Controls: AIG-02 AIG-05 AIG-06 AIG-07 AIG-10 AIG-13 AIG-17 AIG-18
#
# Every path below is taken from the curl examples in the OpenAI API reference
# (developers.openai.com/api/reference/resources/admin/...), verified 2026-10-13:
#   GET  /v1/organization/projects
#   POST /v1/organization/projects
#   POST /v1/organization/projects/{project_id}/model_permissions
#   POST /v1/organization/projects/{project_id}/hosted_tool_permissions
#   POST /v1/organization/projects/{project_id}/data_retention
#   POST /v1/organization/projects/{project_id}/spend_limit
#   POST /v1/organization/projects/{project_id}/service_accounts
#   GET  /v1/organization/projects/{project_id}/rate_limits
#   GET  /v1/organization/audit_logs
#
# Usage:
#   export OPENAI_ADMIN_KEY=...            # Admin API key (never commit it)
#   ./admin-api.sh apply                   # create/converge the governed project
#   ./admin-api.sh show-rate-limits        # list rate-limit records for the project
#   ./admin-api.sh audit-tail              # print the 20 most recent audit-log events
#
# Configuration (environment variables, secure defaults):
#   PROJECT_NAME          (default: ai-gov-prod)
#   APPROVED_MODELS       comma-separated allow-list (default: gpt-5.4-mini)
#   RETENTION_TYPE        project retention (default: organization_default — inherit;
#                         zero_data_retention / modified_abuse_monitoring need prior OpenAI approval)
#   SPEND_LIMIT_CENTS     hard monthly limit in cents (default: 100000 = USD 1,000)
#   ENABLE_WEB_SEARCH, ENABLE_MCP, ENABLE_CODE_INTERPRETER, ENABLE_FILE_SEARCH,
#   ENABLE_IMAGE_GENERATION   "true" to enable a hosted tool (all default "false")
#   CREATE_SERVICE_ACCOUNT    "true" to create a workload service account (default "false",
#                         because the API returns the service account's API key ONCE in the response)
#
# "Idempotent-ish": the project is looked up by name before it is created, and
# every control endpoint is a full-state POST (re-running converges the settings).
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

API="${OPENAI_API_BASE:-https://api.openai.com}"
PROJECT_NAME="${PROJECT_NAME:-ai-gov-prod}"
APPROVED_MODELS="${APPROVED_MODELS:-gpt-5.4-mini}"
RETENTION_TYPE="${RETENTION_TYPE:-organization_default}"
SPEND_LIMIT_CENTS="${SPEND_LIMIT_CENTS:-100000}"
ENABLE_WEB_SEARCH="${ENABLE_WEB_SEARCH:-false}"
ENABLE_MCP="${ENABLE_MCP:-false}"
ENABLE_CODE_INTERPRETER="${ENABLE_CODE_INTERPRETER:-false}"
ENABLE_FILE_SEARCH="${ENABLE_FILE_SEARCH:-false}"
ENABLE_IMAGE_GENERATION="${ENABLE_IMAGE_GENERATION:-false}"
CREATE_SERVICE_ACCOUNT="${CREATE_SERVICE_ACCOUNT:-false}"

: "${OPENAI_ADMIN_KEY:?Set OPENAI_ADMIN_KEY to an OpenAI Admin API key}"

HAVE_JQ=false
command -v jq >/dev/null 2>&1 && HAVE_JQ=true

log() { printf '[openai-admin] %s\n' "$*" >&2; }

api() {
  # api METHOD PATH [JSON_BODY]
  local method="$1" path="$2" body="${3:-}"
  local args=(-sS --fail-with-body -X "$method" "${API}${path}"
    -H "Authorization: Bearer ${OPENAI_ADMIN_KEY}"
    -H "Content-Type: application/json")
  if [[ -n "$body" ]]; then
    args+=(-d "$body")
  fi
  curl "${args[@]}"
}

require_jq() {
  if [[ "$HAVE_JQ" != true ]]; then
    log "jq is required for '$1' (install jq, or run the curl calls in this script by hand)."
    exit 2
  fi
}

bool() { [[ "$1" == "true" ]] && echo true || echo false; }

find_project_id() {
  # Pages through GET /v1/organization/projects (limit max 100) looking for PROJECT_NAME.
  require_jq "project lookup"
  local after="" page id
  while :; do
    page="$(api GET "/v1/organization/projects?limit=100${after:+&after=${after}}")"
    id="$(jq -r --arg n "$PROJECT_NAME" '.data[] | select(.name == $n and .status == "active") | .id' <<<"$page" | head -n1)"
    if [[ -n "$id" ]]; then
      echo "$id"
      return 0
    fi
    [[ "$(jq -r '.has_more' <<<"$page")" == "true" ]] || return 0
    after="$(jq -r '.last_id' <<<"$page")"
  done
}

ensure_project() {
  local id
  id="$(find_project_id)"
  if [[ -z "$id" ]]; then
    log "Creating project '${PROJECT_NAME}' (AIG-02)"
    # Data residency (geography/residency) can only be set here, at creation, and needs
    # OpenAI sales eligibility. Add it to this body deliberately if your org is eligible.
    id="$(api POST "/v1/organization/projects" "$(jq -n --arg n "$PROJECT_NAME" '{name: $n}')" | jq -r '.id')"
  else
    log "Project '${PROJECT_NAME}' exists: ${id}"
  fi
  echo "$id"
}

apply() {
  require_jq "apply"
  local pid models_json
  pid="$(ensure_project)"

  # AIG-06 — approved-model allow-list.
  models_json="$(jq -cn --arg m "$APPROVED_MODELS" '$m | split(",") | map(gsub("^\\s+|\\s+$"; "")) | map(select(length > 0))')"
  log "Setting model allow-list ${models_json} (AIG-06)"
  api POST "/v1/organization/projects/${pid}/model_permissions" \
    "$(jq -cn --argjson ids "$models_json" '{mode: "allow_list", model_ids: $ids}')" >/dev/null

  # AIG-10 — hosted tools off unless explicitly enabled. The org-level tool policy
  # must be "allow selected projects" or disabling per project fails.
  log "Setting hosted tool permissions (AIG-10)"
  api POST "/v1/organization/projects/${pid}/hosted_tool_permissions" "$(jq -cn \
    --argjson ws "$(bool "$ENABLE_WEB_SEARCH")" \
    --argjson mcp "$(bool "$ENABLE_MCP")" \
    --argjson ci "$(bool "$ENABLE_CODE_INTERPRETER")" \
    --argjson fs "$(bool "$ENABLE_FILE_SEARCH")" \
    --argjson ig "$(bool "$ENABLE_IMAGE_GENERATION")" \
    '{web_search: {enabled: $ws}, mcp: {enabled: $mcp}, code_interpreter: {enabled: $ci},
      file_search: {enabled: $fs}, image_generation: {enabled: $ig}}')" >/dev/null

  # AIG-05 / AIG-18 — data retention. The documented API enum is zero_data_retention |
  # modified_abuse_monitoring | enhanced_zero_data_retention | enhanced_modified_abuse_monitoring.
  # "organization_default" is documented for the Terraform provider; when it is selected
  # here we skip the call so the project keeps inheriting the organization policy.
  if [[ "$RETENTION_TYPE" == "organization_default" ]]; then
    log "Data retention: inheriting organization default (no override) (AIG-05)"
  else
    log "Setting project data retention '${RETENTION_TYPE}' — requires prior OpenAI approval (AIG-05)"
    api POST "/v1/organization/projects/${pid}/data_retention" \
      "$(jq -cn --arg t "$RETENTION_TYPE" '{retention_type: $t}')" >/dev/null
  fi

  # AIG-17 — hard monthly spend limit (429 once reached).
  log "Setting hard monthly spend limit ${SPEND_LIMIT_CENTS} cents (AIG-17)"
  api POST "/v1/organization/projects/${pid}/spend_limit" \
    "$(jq -cn --argjson c "$SPEND_LIMIT_CENTS" '{threshold_amount: $c, currency: "USD", interval: "month"}')" >/dev/null

  # AIG-07 — workload service account. The create response contains the API key value
  # exactly once; write it straight to a 0600 file and hand it to your secrets manager.
  if [[ "$CREATE_SERVICE_ACCOUNT" == "true" ]]; then
    log "Creating workload service account (AIG-07); key written to ./service-account-api-key.json (mode 600)"
    umask 077
    api POST "/v1/organization/projects/${pid}/service_accounts" \
      "$(jq -cn --arg n "${PROJECT_NAME}-workload" '{name: $n}')" >service-account-api-key.json
    log "Store the key in your secrets manager, then delete service-account-api-key.json."
  fi

  log "Done. Project ${pid} converged."
}

show_rate_limits() {
  require_jq "show-rate-limits"
  local pid
  pid="$(find_project_id)"
  [[ -n "$pid" ]] || { log "Project '${PROJECT_NAME}' not found"; exit 1; }
  # AIG-17 — rate limits are updated with POST .../rate_limits/{rate_limit_id}.
  api GET "/v1/organization/projects/${pid}/rate_limits?limit=100" | jq '.data'
}

audit_tail() {
  # AIG-13 — most recent configuration / user actions. For SIEM export use audit-log-export.sh.
  if [[ "$HAVE_JQ" == true ]]; then
    api GET "/v1/organization/audit_logs?limit=20" | jq -c '.data[] | {id, type, effective_at, actor: .actor.type}'
  else
    api GET "/v1/organization/audit_logs?limit=20"
  fi
}

case "${1:-}" in
  apply) apply ;;
  show-rate-limits) show_rate_limits ;;
  audit-tail) audit_tail ;;
  *)
    echo "Usage: $0 {apply|show-rate-limits|audit-tail}" >&2
    exit 64
    ;;
esac
