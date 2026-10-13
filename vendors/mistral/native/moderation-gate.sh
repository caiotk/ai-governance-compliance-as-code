#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Mistral Moderation API as a CI gate — AIG-10 AIG-14
#
# Scores a file of prompts (one per line) or a JSON array of chat messages with
# the moderation classifier and fails when any category is flagged. Use it on
# system prompts, few-shot examples, evaluation sets and red-team corpora before
# they are promoted, and as the pre-check in an application gateway.
#
# Verified 2026-10-13 (docs.mistral.ai/api/endpoint/classifiers,
# docs.mistral.ai/capabilities/guardrailing):
#   POST /v1/moderations        {"model": "mistral-moderation-latest", "input": "str" | ["str", ...]}
#   POST /v1/chat/moderations   {"model": ..., "input": [ {role, content}, ... ]}
#   Header Authorization: Bearer <Workspace API key>
#   Response: {"id","model","results":[{"categories":{<key>: bool}, "category_scores":{<key>: float}}]}
#   Category keys (API reference, 9): sexual, hate_and_discrimination,
#   violence_and_threats, dangerous_and_criminal_content, selfharm, health,
#   financial, law, pii. Newer model pages list 11 incl. jailbreaking — the key
#   set is model-version dependent, so this script flags on ANY true category
#   rather than a hard-coded list, and lets you exempt categories by name.
#
# Usage:
#   export MISTRAL_API_KEY=...
#   ./moderation-gate.sh prompts.txt                      # one prompt per line
#   ./moderation-gate.sh --chat conversation.json         # JSON array of messages
#   ./moderation-gate.sh prompts.txt --allow health,law   # categories to ignore
#   MODERATION_MODEL=mistral-moderation-2603 ./moderation-gate.sh prompts.txt
# Exit codes: 0 clean, 1 flagged content, 2 usage/API error.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

API="${MISTRAL_API_BASE:-https://api.mistral.ai}"
MODEL="${MODERATION_MODEL:-mistral-moderation-latest}"
: "${MISTRAL_API_KEY:?Set MISTRAL_API_KEY to a Workspace API key}"
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 2; }

mode="text"; allow=""; file=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --chat) mode="chat"; shift ;;
    --allow) allow="$2"; shift 2 ;;
    *) file="$1"; shift ;;
  esac
done
[[ -n "$file" && -r "$file" ]] || { echo "usage: $0 [--chat] <file> [--allow cat1,cat2]" >&2; exit 2; }

if [[ "$mode" == "chat" ]]; then
  endpoint="/v1/chat/moderations"
  body="$(jq -c --arg m "$MODEL" '{model: $m, input: .}' "$file")"
else
  endpoint="/v1/moderations"
  body="$(jq -R -s -c --arg m "$MODEL" '{model: $m, input: (split("\n") | map(select(length > 0)))}' "$file")"
fi

resp="$(curl -sS --fail-with-body -X POST "${API}${endpoint}" \
  -H "Authorization: Bearer ${MISTRAL_API_KEY}" -H "Content-Type: application/json" -d "$body")" \
  || { echo "moderation request failed: $resp" >&2; exit 2; }

# Flag any category reported true, minus the allow-list.
flagged="$(printf '%s' "$resp" | jq -r --arg allow "$allow" '
  ($allow | split(",") | map(select(length > 0))) as $skip
  | .results | to_entries[]
  | .key as $i
  | .value.categories | to_entries[]
  | select(.value == true and (($skip | index(.key)) == null))
  | "item \($i): \(.key)"')"

if [[ -n "$flagged" ]]; then
  echo "❌ moderation gate: flagged by ${MODEL}" >&2
  printf '%s\n' "$flagged" >&2
  exit 1
fi
echo "✅ moderation gate: $(printf '%s' "$resp" | jq '.results | length') item(s) clean (${MODEL})"
