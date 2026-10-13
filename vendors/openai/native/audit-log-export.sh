#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Export OpenAI organization audit logs to JSON Lines for a SIEM.   Control: AIG-13
#
# Endpoint (verified 2026-10-13, OpenAI API reference "List audit logs"):
#   GET https://api.openai.com/v1/organization/audit_logs
#   Query: limit (1–100, default 20), after (cursor = last_id of the previous page),
#          effective_at[gte] / effective_at[lt] (Unix seconds), event_types[], project_ids[]
#   Response: { "object": "list", "data": [...], "first_id", "last_id", "has_more" }
#
# Usage:
#   export OPENAI_ADMIN_KEY=...
#   ./audit-log-export.sh [OUTPUT_FILE] [SINCE_UNIX_SECONDS]
#   e.g. ./audit-log-export.sh openai-audit.jsonl "$(date -d '-1 day' +%s)"
#
# Cursor state is kept in ${OUTPUT_FILE}.cursor (the newest event ID seen) so a
# scheduled run can stop once it reaches events it already exported.
#
# Notes:
# - The bracketed effective_at[gte] query form follows the standard OpenAI list
#   convention; the reference documents effective_at as an object {gt,gte,lt,lte}.
#   UNVERIFIED: exact wire encoding of the nested filter — if the API rejects it,
#   omit SINCE and rely on the cursor file instead.
# - UNVERIFIED: whether audit logging must first be enabled in organization
#   settings, and the audit-log retention period (not stated in the docs read).
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

: "${OPENAI_ADMIN_KEY:?Set OPENAI_ADMIN_KEY to an OpenAI Admin API key}"
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 2; }

API="${OPENAI_API_BASE:-https://api.openai.com}"
OUT="${1:-openai-audit-logs.jsonl}"
SINCE="${2:-}"
CURSOR_FILE="${OUT}.cursor"
LAST_SEEN=""
[[ -f "$CURSOR_FILE" ]] && LAST_SEEN="$(cat "$CURSOR_FILE")"

query="limit=100"
if [[ -n "$SINCE" ]]; then
  query+="&effective_at%5Bgte%5D=${SINCE}"
fi

after=""
newest=""
count=0
while :; do
  page="$(curl -sS --fail-with-body \
    "${API}/v1/organization/audit_logs?${query}${after:+&after=${after}}" \
    -H "Authorization: Bearer ${OPENAI_ADMIN_KEY}" \
    -H "Content-Type: application/json")"

  [[ -z "$newest" ]] && newest="$(jq -r '.first_id // empty' <<<"$page")"

  # Emit events until we reach the last event exported by the previous run.
  stop=false
  while IFS= read -r event; do
    id="$(jq -r '.id' <<<"$event")"
    if [[ -n "$LAST_SEEN" && "$id" == "$LAST_SEEN" ]]; then
      stop=true
      break
    fi
    # Add an envelope the SIEM can route on, keep the original event intact.
    jq -c '{source: "openai.audit_logs", event: .}' <<<"$event" >>"$OUT"
    count=$((count + 1))
  done < <(jq -c '.data[]' <<<"$page")

  [[ "$stop" == true ]] && break
  [[ "$(jq -r '.has_more' <<<"$page")" == "true" ]] || break
  after="$(jq -r '.last_id' <<<"$page")"
done

if [[ -n "$newest" ]]; then
  printf '%s' "$newest" >"$CURSOR_FILE"
fi
echo "Exported ${count} audit-log events to ${OUT}" >&2
