#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Assign the Foundry / Azure AI services built-in policies at a management
# group with the Azure CLI (`az policy assignment create`). Equivalent to
# assignments.bicep and terraform/policy.tf.
#
# Usage:
#   MG_NAME=<management-group-name> ./assign.sh            # enforce (Default)
#   MG_NAME=<mg> ENFORCEMENT_MODE=DoNotEnforce ./assign.sh  # evaluate only
#
# Requires: az CLI logged in as a principal with Resource Policy Contributor
# (or Owner) on the management group.
# AIG-06 AIG-07 AIG-08 AIG-09 AIG-13
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

: "${MG_NAME:?Set MG_NAME to the management group name}"
ENFORCEMENT_MODE="${ENFORCEMENT_MODE:-Default}"
CMK_EFFECT="${CMK_EFFECT:-Audit}"
MANAGED_IDENTITY_EFFECT="${MANAGED_IDENTITY_EFFECT:-Deny}"
ASSIGN_EU_AI_ACT="${ASSIGN_EU_AI_ACT:-true}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPROVED_MODELS_PARAMS="${APPROVED_MODELS_PARAMS:-${SCRIPT_DIR}/approved-models.parameters.json}"

SCOPE="/providers/Microsoft.Management/managementGroups/${MG_NAME}"
BUILTIN="/providers/Microsoft.Authorization/policyDefinitions"

assign() {
  local name="$1" display="$2" definition="$3" params="$4"
  echo "Assigning ${name} -> ${definition}"
  az policy assignment create \
    --name "${name}" \
    --display-name "${display}" \
    --scope "${SCOPE}" \
    --policy "${BUILTIN}/${definition}" \
    --enforcement-mode "${ENFORCEMENT_MODE}" \
    --params "${params}" \
    --output none
}

# AIG-07: Azure AI Services resources should have key access disabled
assign aigov-ai-no-local-auth "AIGov: AI Services key access disabled" \
  71ef260a-8f18-47b7-abcb-62d0673d94dc '{"effect":{"value":"Deny"}}'

# AIG-08: Azure AI Services resources should restrict network access
assign aigov-ai-restrict-net "AIGov: AI Services restrict network access" \
  037eea7a-bd0a-46c5-9a66-03aea78705d3 '{"effect":{"value":"Deny"}}'

# AIG-08: Azure AI Services resources should use Azure Private Link (Audit only)
assign aigov-ai-private-link "AIGov: AI Services use Private Link" \
  d6759c02-b87f-42b7-892e-71b3f471d782 '{"effect":{"value":"Audit"}}'

# AIG-13: Diagnostic logs in Azure AI services resources should be enabled
assign aigov-ai-diag-logs "AIGov: AI Services diagnostic logs" \
  1b4d1c4e-934c-4703-944c-27c82c06bebb '{"effect":{"value":"AuditIfNotExists"}}'

# AIG-07: Cognitive Services accounts should use a managed identity
assign aigov-ai-managed-id "AIGov: Cognitive Services managed identity" \
  fe3fd216-4f83-4fc1-8984-2bbec80a3418 "{\"effect\":{\"value\":\"${MANAGED_IDENTITY_EFFECT}\"}}"

# AIG-09: Azure AI Services resources should encrypt data at rest with a CMK.
# excludedKinds is overridden to [] because the built-in default excludes AIServices.
assign aigov-ai-cmk "AIGov: AI Services encrypt with CMK" \
  67121cc7-ff39-4ab8-b7e3-95b84dab487d "{\"effect\":{\"value\":\"${CMK_EFFECT}\"},\"excludedKinds\":{\"value\":[]}}"

# AIG-06: Foundry model deployments should only use approved models.
# --params takes a JSON/YAML file path directly (az CLI shorthand-syntax rules).
assign aigov-approved-models "AIGov: Foundry approved models only" \
  aafe3651-cb78-4f68-9f81-e7e41509110f "${APPROVED_MODELS_PARAMS}"

# AIG-13 AIG-08: EU AI Act 2024 1689 initiative, default (audit) parameters
if [[ "${ASSIGN_EU_AI_ACT}" == "true" ]]; then
  echo "Assigning aigov-eu-ai-act -> policySetDefinitions/1308bccf-446a-4283-a4e0-0c983fe7a572"
  az policy assignment create \
    --name aigov-eu-ai-act \
    --display-name "AIGov: EU AI Act 2024 1689 (audit)" \
    --scope "${SCOPE}" \
    --policy-set-definition "/providers/Microsoft.Authorization/policySetDefinitions/1308bccf-446a-4283-a4e0-0c983fe7a572" \
    --enforcement-mode "${ENFORCEMENT_MODE}" \
    --output none
fi

echo "Done. Review compliance with:"
echo "  az policy state summarize --management-group ${MG_NAME}"
