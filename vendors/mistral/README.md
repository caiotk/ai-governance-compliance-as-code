# Mistral AI pack (La Plateforme / Admin API / Moderation API)

**Verified as of 2026-10-13** against docs.mistral.ai, help.mistral.ai, legal.mistral.ai and trust.mistral.ai (gated).

## Purpose

This pack governs a Mistral Organization through member and role inventory, audit-log export, moderation guardrails and documented data-handling evidence. It covers Mistral's **first-party API**; when Mistral models are consumed through Azure AI, Amazon Bedrock, Google Vertex AI, Snowflake, IBM watsonx or Outscale, the hosting platform's pack applies instead (identity, network, logging and residency are the platform's).

> **Changes are applied natively; Terraform only verifies posture.**
> - **There is no official Mistral Terraform provider** (registry search, 2026-10-13). Community providers are unverified and deliberately not used.
> - **The `terraform/` module creates and changes nothing.** During `terraform plan` it reads the Admin API and the Moderation API with `hashicorp/http` data sources and evaluates `check` blocks. An output precondition turns violations into a failed plan, which works as a CI gate.
> - **The Admin API is Enterprise-only and access is not self-serve.** Team/Scale plans can still use `native/moderation-gate.sh` and the guardrails request, but have no programmatic inventory or audit export.

## What is enforced

| Control | Mechanism | File |
|---|---|---|
| AIG-02 inventory | Members and their additive roles read from `GET /v1/admin/users`; a full first page is reported as an incomplete inventory. | `terraform/main.tf`, `terraform/outputs.tf`, `native/admin-api.sh` |
| AIG-07 identity | `organization_admin` holders counted against `max_org_admins`; role catalogue from `GET /v1/admin/roles`; Workspace-scoped keys with an org-wide expiry policy and SAML SSO as the identity baseline. | `terraform/main.tf`, `native/admin-api.sh` |
| AIG-10 guardrails | `native/moderation-gate.sh` fails CI when `POST /v1/moderations` (or `/v1/chat/moderations`) flags any category; `native/guardrails-request.json` shows the server-side `guardrails` block (`moderation_llm_v2`, `action: block` → HTTP 403). Terraform smoke-tests the endpoint and category keys. | `native/moderation-gate.sh`, `native/guardrails-request.json`, `terraform/main.tf` |
| AIG-13 logging | `GET /v1/admin/audit-logs` exported to JSON Lines for the SIEM (the Admin Panel has no export). Terraform asserts the log is reachable and non-empty. | `native/admin-api.sh`, `terraform/main.tf` |
| AIG-14 testing | Red-team and evaluation corpora pass through the moderation gate before promotion. | `native/moderation-gate.sh` |
| AIG-18 transfers | Processing in Sweden, 30-day retention, ZDR scope, Labs/Preview training exclusion and the contractual artefacts to file. | `native/data-residency.md` |

## Prerequisites

- **Admin API key** from Backoffice (backoffice.mistral.ai → API keys; shown once; optional expiry; tied to one Organization). Enterprise plans only.
- **Workspace API key** for the moderation gate and smoke test.
- **Tooling.** Terraform >= 1.6; the native scripts need `curl` and `jq`.

## Verify posture with Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
export TF_VAR_mistral_admin_api_key=...
export TF_VAR_mistral_api_key=...        # Workspace key for the moderation smoke test
terraform init
terraform plan                           # check warnings + posture_violations; fails if fail_on_violation=true
```

- `terraform validate` makes no network calls; data sources run only during `plan`.
- **Treat the plan as sensitive** — member e-mails and audit events appear in state. Plan without a saved state or keep state in an encrypted backend.
- If the Admin API rejects `x-api-key`, set `admin_auth_scheme = "bearer"` (the audit-logs reference page documents `Authorization: Bearer`; the authentication page documents `x-api-key`).

## Apply and export natively

```bash
export MISTRAL_ADMIN_KEY=...
./native/admin-api.sh list-users
./native/admin-api.sh org-admins
./native/admin-api.sh audit-logs mistral-audit.jsonl        # schedule this into the SIEM

export MISTRAL_API_KEY=...
./native/moderation-gate.sh prompts/system-prompts.txt
./native/moderation-gate.sh --chat tests/redteam-conversation.json --allow health,law
```

**Steps that only work in the Admin Panel / Studio** (no verified API): creating or rotating API keys (Workspace, connector scope and expiry are immutable after creation — create new, delete old), setting the org-wide key-expiry policy, role changes, Workspace spend limits, SAML SSO, training opt-out, and requesting ZDR (via support, case by case).

## Known gaps (see `mapping.yaml`)

- No model allow-list, private networking, region choice or customer-managed keys on the first-party API; use a hyperscaler route or self-deployment (vLLM) where those are required.
- Admin API response shapes for Workspaces and API keys were not verified, so the Terraform module reads only users, roles and audit logs; `admin-api.sh get <path>` is a passthrough for the rest.
- SCIM: not mentioned on the SSO page — **unverified**. SSO is SAML 2.0 only.
- Moderation category keys are **model-version dependent** (9 keys in the API reference, 11 on the current guardrailing page incl. `jailbreaking`); the gate flags on any `true` category instead of a fixed list, and the Terraform variable `required_moderation_categories` should be aligned to a live response.
- ISO/IEC 42001, HDS and CSA STAR: **unverified** (Trust Center gated). SOC 2 Type II and ISO 27001/27701 are stated in a help article dated 2026-08-12.
- `safe_prompt` is deprecated in favour of custom guardrails and is not used here.
