#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Claude Admin API — governance changes applied natively (Terraform in
# ../terraform only VERIFIES posture; there is no official Anthropic provider).
# Controls: AIG-02 AIG-07 AIG-08 AIG-13 AIG-17 AIG-18
#
# Endpoints verified 2026-10-13 (platform.claude.com/docs/en/manage-claude/admin-api,
# /workspaces, /data-residency, /usage-cost-api and the API reference):
#   GET/POST /v1/organizations/workspaces                          list / create
#   POST     /v1/organizations/workspaces/{id}                     update (data_residency)
#   POST     /v1/organizations/workspaces/{id}/archive             archive (irreversible)
#   GET/POST /v1/organizations/workspaces/{id}/members             list / add member
#   GET      /v1/organizations/api_keys?status=active              list keys
#   POST     /v1/organizations/api_keys/{id}  {"status":"inactive"} disable a key
#   GET      /v1/organizations/usage_report/messages               usage report
#   GET      /v1/organizations/cost_report                         cost report
# Headers: x-api-key: <Admin key sk-ant-admin...>, anthropic-version: 2023-06-01
#
# Facts that shape this script:
# - API keys CANNOT be created through the Admin API (Console only); it can read,
#   rename and change the status of keys. Status values: active | inactive |
#   archived | expired (only "inactive" is set here).
# - Workspace spend limits and rate limits are set in the Claude Console and
#   cannot be set on the Default Workspace.
# - Workspace roles via API: workspace_admin | workspace_developer |
#   workspace_restricted_developer | workspace_user (not workspace_billing).
# - Workspace geo is "us" only and immutable; inference geo is controlled by
#   data_residency.allowed_inference_geos / default_inference_geo.
#
# Usage:
#   export ANTHROPIC_ADMIN_KEY=sk-ant-admin...
#   ./admin-api.sh list-workspaces
#   ./admin-api.sh create-workspace <name> [--us-only]
#   ./admin-api.sh set-us-only <workspace_id>
#   ./admin-api.sh archive-workspace <workspace_id>          # irreversible; archives its keys
#   ./admin-api.sh add-member <workspace_id> <user_id> [workspace_developer|workspace_admin|...]
#   ./admin-api.sh list-keys [workspace_id]
#   ./admin-api.sh disable-stale-keys [max_age_days] [--apply]   # dry run unless --apply
#   ./admin-api.sh disable-key <api_key_id>
#   ./admin-api.sh usage-report <starting_at RFC3339> <ending_at RFC3339> [out.jsonl]
#   ./admin-api.sh cost-report  <starting_at RFC3339> <ending_at RFC3339> [out.jsonl]
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

API="${ANTHROPIC_API_BASE:-https://api.anthropic.com}"
VERSION="2023-06-01"
: "${ANTHROPIC_ADMIN_KEY:?Set ANTHROPIC_ADMIN_KEY to a Claude Admin API key (sk-ant-admin...)}"
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 2; }

log() { printf '[claude-admin] %s\n' "$*" >&2; }

api() {
  # api METHOD PATH [JSON_BODY]
  local method="$1" path="$2" body="${3:-}"
  local args=(-sS --fail-with-body -X "$method" "${API}${path}"
    -H "x-api-key: ${ANTHROPIC_ADMIN_KEY}"
    -H "anthropic-version: ${VERSION}"
    -H "content-type: application/json")
  [[ -n "$body" ]] && args+=(-d "$body")
  curl "${args[@]}"
}

paged() {
  # paged PATH_WITH_QUERY — follows after_id/last_id until has_more=false; emits items.
  local path="$1" after="" page sep
  [[ "$path" == *\?* ]] && sep="&" || sep="?"
  while :; do
    page="$(api GET "${path}${after:+${sep}after_id=${after}}")"
    jq -c '.data[]' <<<"$page"
    [[ "$(jq -r '.has_more' <<<"$page")" == "true" ]] || break
    after="$(jq -r '.last_id' <<<"$page")"
  done
}

list_workspaces() {
  # AIG-02
  paged "/v1/organizations/workspaces?limit=1000&include_archived=false" |
    jq -c '{id, name, archived_at, data_residency}'
}

create_workspace() {
  # AIG-02 AIG-08 — idempotent: returns the existing workspace if the name exists.
  local name="${1:?workspace name required}" us_only="${2:-}" existing body
  existing="$(paged "/v1/organizations/workspaces?limit=1000&include_archived=false" |
    jq -r --arg n "$name" 'select(.name == $n) | .id' | head -n1)"
  if [[ -n "$existing" ]]; then
    log "Workspace '${name}' exists: ${existing}"
    echo "$existing"
    return 0
  fi
  if [[ "$us_only" == "--us-only" ]]; then
    # UNVERIFIED: workspace_geo in the create body; "us" is currently the only workspace geo.
    body="$(jq -cn --arg n "$name" '{name: $n, data_residency: {workspace_geo: "us", allowed_inference_geos: ["us"], default_inference_geo: "us"}}')"
  else
    body="$(jq -cn --arg n "$name" '{name: $n}')"
  fi
  log "Creating workspace '${name}'. Set its spend and rate limits in the Console afterwards (AIG-17)."
  api POST "/v1/organizations/workspaces" "$body" | jq -r '.id'
}

set_us_only() {
  # AIG-08 AIG-18 — restrict inference to US infrastructure for every key in the workspace.
  local id="${1:?workspace_id required}"
  # UNVERIFIED: the workspace update endpoint (POST /v1/organizations/workspaces/{id}) and the
  # data_residency fields were taken from the live docs at build time; confirm against the
  # Admin API reference before use. Create/list/archive are verified.
  api POST "/v1/organizations/workspaces/${id}" \
    '{"data_residency": {"allowed_inference_geos": ["us"], "default_inference_geo": "us"}}' |
    jq -c '{id, name, data_residency}'
}

archive_workspace() {
  # Irreversible: also archives every API key created for the workspace.
  local id="${1:?workspace_id required}"
  read -r -p "Archive ${id}? This cannot be undone and archives its API keys. Type 'archive' to confirm: " ok
  [[ "$ok" == "archive" ]] || { log "Aborted"; exit 1; }
  api POST "/v1/organizations/workspaces/${id}/archive" | jq -c '{id, name, archived_at}'
}

add_member() {
  # AIG-07 — least privilege: default role is workspace_developer, not workspace_admin.
  local id="${1:?workspace_id required}" user="${2:?user_id required}" role="${3:-workspace_developer}"
  case "$role" in
    workspace_admin | workspace_developer | workspace_restricted_developer | workspace_user) ;;
    *) log "Unsupported workspace_role '${role}'"; exit 64 ;;
  esac
  api POST "/v1/organizations/workspaces/${id}/members" \
    "$(jq -cn --arg u "$user" --arg r "$role" '{user_id: $u, workspace_role: $r}')" |
    jq -c '{user_id, workspace_id, workspace_role}'
}

list_keys() {
  # AIG-02 AIG-07 — `scope` tells Default-Workspace keys from org-scoped keys
  # (the top-level workspace_id is deprecated and null for both).
  local ws="${1:-}"
  paged "/v1/organizations/api_keys?status=active&limit=1000${ws:+&workspace_id=${ws}}" |
    jq -c '{id, name, created_at, expires_at, scope, principal: (.principal.type // null), status}'
}

disable_key() {
  local id="${1:?api_key_id required}"
  api POST "/v1/organizations/api_keys/${id}" '{"status": "inactive"}' | jq -c '{id, name, status}'
}

disable_stale_keys() {
  # AIG-07 — the Admin API exposes created_at but not last-used time; age is the proxy.
  local max_days="${1:-90}" apply="${2:-}" cutoff
  cutoff="$(date -u -d "-${max_days} days" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null ||
    date -u -v-"${max_days}"d +%Y-%m-%dT%H:%M:%SZ)"
  log "Active keys created before ${cutoff}:"
  paged "/v1/organizations/api_keys?status=active&limit=1000" |
    jq -r --arg c "$cutoff" 'select(.created_at < $c) | .id' |
    while IFS= read -r id; do
      if [[ "$apply" == "--apply" ]]; then
        log "Disabling ${id}"
        disable_key "$id"
      else
        echo "would disable: ${id}"
      fi
    done
}

report() {
  # AIG-13 AIG-17 — usage/cost export; pagination via has_more + next_page (page=...).
  local path="$1" start="${2:?starting_at required}" end="${3:?ending_at required}" out="${4:-/dev/stdout}"
  local q="starting_at=${start}&ending_at=${end}" page next=""
  # group_by inference_geo gives residency evidence (AIG-18) per model.
  # UNVERIFIED: include_archived and group_by[]=inference_geo query parameters.
  [[ "$path" == *usage_report* ]] && q+="&bucket_width=1d&group_by%5B%5D=inference_geo&group_by%5B%5D=model"
  [[ "$path" == *cost_report* ]] && q+="&group_by%5B%5D=workspace_id&group_by%5B%5D=description"
  while :; do
    page="$(api GET "${path}?${q}${next:+&page=${next}}")"
    jq -c '.data[]' <<<"$page" >>"$out"
    [[ "$(jq -r '.has_more' <<<"$page")" == "true" ]] || break
    next="$(jq -r '.next_page' <<<"$page")"
  done
}

cmd="${1:-}"
shift || true
case "$cmd" in
  list-workspaces) list_workspaces ;;
  create-workspace) create_workspace "$@" ;;
  set-us-only) set_us_only "$@" ;;
  archive-workspace) archive_workspace "$@" ;;
  add-member) add_member "$@" ;;
  list-keys) list_keys "$@" ;;
  disable-key) disable_key "$@" ;;
  disable-stale-keys) disable_stale_keys "$@" ;;
  usage-report) report "/v1/organizations/usage_report/messages" "$@" ;;
  cost-report) report "/v1/organizations/cost_report" "$@" ;;
  *)
    sed -n '/^# Usage:/,/^# ────/p' "$0" | sed 's/^# \{0,1\}//' >&2
    exit 64
    ;;
esac
