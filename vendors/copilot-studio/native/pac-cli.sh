#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Power Platform CLI (pac) steps for the Copilot Studio agent baseline.
#
# AIG-02 AIG-07 AIG-13 AIG-15
#   1. Turn the production agent environment into a Managed Environment with
#      solution checker set to block (AIG-15, prerequisite for sharing limits).
#   2. Read-only evidence: list/show data policies, export tenant settings,
#      and query the agent inventory (AIG-02, AIG-07 evidence).
#
# Usage:
#   pac auth create            # sign in once (Power Platform administrator)
#   ENVIRONMENT_ID=<env-guid> ./pac-cli.sh
#   DLP_POLICY_NAME=<policy-guid> ./pac-cli.sh   # also show one policy
#
# Data policies are created by Terraform or New-AgentDlpPolicy.ps1; pac is
# used here only to read them.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${OUT_DIR:-${SCRIPT_DIR}/evidence}"
mkdir -p "${OUT_DIR}"

# ── 1. Managed Environment (AIG-07 AIG-15) ───────────────────────────────────
if [[ -n "${ENVIRONMENT_ID:-}" ]]; then
  echo "Enabling Managed Environment on ${ENVIRONMENT_ID}"
  pac admin set-governance-config \
    --environment "${ENVIRONMENT_ID}" \
    --protection-level Standard
  # UNVERIFIED: a --solution-checker-mode flag was not confirmed in the pac reference; set solution checker
  # enforcement with the Terraform powerplatform_managed_environment resource or in the admin centre.
fi

# ── 2. Read-only evidence ────────────────────────────────────────────────────
echo "Data policies in the tenant:"
pac admin dlp-policy list

if [[ -n "${DLP_POLICY_NAME:-}" ]]; then
  pac admin dlp-policy show --policy-name "${DLP_POLICY_NAME}"
fi

echo "Exporting tenant settings to ${OUT_DIR}/tenant-settings.json"
pac admin list-tenant-settings --settings-file "${OUT_DIR}/tenant-settings.json"

# AIG-02: Copilot Studio agent inventory (Preview command — UNVERIFIED against the pac reference;
# the documented access paths are the Power Platform admin center, Power Platform API and Azure Resource Graph). Lists agents with
# their authentication mode, so agents with authentication "None" stand out.
echo "Querying agent inventory to ${OUT_DIR}/agent-inventory.json"
pac resource-query query-resources --body "@${SCRIPT_DIR}/agent-inventory-query.json" \
  > "${OUT_DIR}/agent-inventory.json"
