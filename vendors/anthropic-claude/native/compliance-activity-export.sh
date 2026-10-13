#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Export the Claude Compliance API Activity Feed to JSON Lines for a SIEM.
# Control: AIG-13 (logging & monitoring).
#
# Verified 2026-10-13 (platform.claude.com/docs/en/manage-claude/compliance-api,
# /compliance-activity-feed):
#   GET https://api.anthropic.com/v1/compliance/activities
#   Headers: x-api-key, anthropic-version: 2023-06-01
#   Query:   limit (default 100, max 5000), after_id / before_id (cursor),
#            created_at.gte / .gt / .lte / .lt (RFC 3339)
#   Response: { data: [Activity], has_more, first_id, last_id } — newest first.
#   Pagination: pass last_id as after_id to reach OLDER activities; stop when has_more=false.
#
# Keys:
#   - A Compliance Access Key (created in claude.ai) reaches every /v1/compliance/* endpoint.
#   - An Admin API key reaches ONLY the Activity Feed (scope read:compliance_activities).
# Retention: the Activity Feed is kept for 6 years; recording starts when the
# Compliance API is first enabled (no backfill). Shared limit: 600 requests/minute.
#
# Usage:
#   export ANTHROPIC_COMPLIANCE_KEY=...      # Compliance Access Key or Admin key
#   ./compliance-activity-export.sh [OUTPUT_FILE] [SINCE_RFC3339]
#   e.g. ./compliance-activity-export.sh claude-activity.jsonl 2026-10-12T00:00:00Z
#
# Incremental runs: the newest activity ID exported is stored in ${OUTPUT_FILE}.cursor;
# the next run stops as soon as it reaches that ID.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

: "${ANTHROPIC_COMPLIANCE_KEY:?Set ANTHROPIC_COMPLIANCE_KEY (Compliance Access Key or Admin API key)}"
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 2; }

API="${ANTHROPIC_API_BASE:-https://api.anthropic.com}"
OUT="${1:-claude-compliance-activities.jsonl}"
SINCE="${2:-}"
CURSOR_FILE="${OUT}.cursor"
LAST_SEEN=""
[[ -f "$CURSOR_FILE" ]] && LAST_SEEN="$(cat "$CURSOR_FILE")"

fetch() {
  local args=(--fail-with-body -sS -G "${API}/v1/compliance/activities"
    --header "x-api-key: ${ANTHROPIC_COMPLIANCE_KEY}"
    --header "anthropic-version: 2023-06-01"
    --data-urlencode "limit=1000")
  [[ -n "$SINCE" ]] && args+=(--data-urlencode "created_at.gte=${SINCE}")
  [[ -n "${1:-}" ]] && args+=(--data-urlencode "after_id=$1")
  local attempt=0 out
  while :; do
    if out="$(curl "${args[@]}")"; then
      printf '%s' "$out"
      return 0
    fi
    attempt=$((attempt + 1))
    [[ $attempt -ge 5 ]] && return 1
    sleep $((attempt * 5)) # back off (429s share a 600 rpm org budget)
  done
}

after=""
newest=""
count=0
while :; do
  page="$(fetch "$after")"
  [[ -z "$newest" ]] && newest="$(jq -r '.first_id // empty' <<<"$page")"

  stop=false
  while IFS= read -r activity; do
    id="$(jq -r '.id' <<<"$activity")"
    if [[ -n "$LAST_SEEN" && "$id" == "$LAST_SEEN" ]]; then
      stop=true
      break
    fi
    jq -c '{source: "anthropic.compliance.activities", event: .}' <<<"$activity" >>"$OUT"
    count=$((count + 1))
  done < <(jq -c '.data[]' <<<"$page")

  [[ "$stop" == true ]] && break
  [[ "$(jq -r '.has_more' <<<"$page")" == "true" ]] || break
  after="$(jq -r '.last_id' <<<"$page")"
done

[[ -n "$newest" ]] && printf '%s' "$newest" >"$CURSOR_FILE"
echo "Exported ${count} activities to ${OUT}" >&2
