# Anthropic Claude pack (Claude API / Claude Console / Claude Enterprise)

**Verified as of 2026-10-13** against platform.claude.com, support.claude.com and anthropic.com.

## Purpose

This pack governs Claude Console organizations through workspaces, API-key hygiene, data residency and compliance logging.

> **Changes are applied natively; Terraform only verifies posture.**
> - **There is no official Anthropic Terraform provider.** `anthropic/anthropic` and `anthropics/anthropic` return 404 on the registry, and the Claude docs have no Terraform page.
> - **The community providers are deliberately not used.** `ippontech/anthropic` and `terraform-mars/anthropic` are not maintained by Anthropic.
> - **The `terraform/` module creates and changes nothing.** During `terraform plan` it reads the Claude Admin API with `hashicorp/http` data sources and evaluates `check` blocks against your governance expectations. An output precondition can turn violations into a failed plan, which works as a CI gate.
> - **Native changes:** use `native/admin-api.sh` or the Claude Console.

## What is enforced

| Control | Mechanism | File |
|---|---|---|
| AIG-02 inventory | Workspace and active-key inventory. Required workspaces must exist (`check.required_workspaces_exist`). Workspaces are created idempotently. | `terraform/main.tf`, `terraform/outputs.tf`, `native/admin-api.sh` |
| AIG-07 key hygiene | Several `check` blocks: active-key threshold, keys older than N days, keys without expiry, and personal keys in service-account-only workspaces. `disable-stale-keys` sets `{"status":"inactive"}`. Members are added as `workspace_developer` by default. | `terraform/main.tf`, `native/admin-api.sh` |
| AIG-08 / AIG-18 residency | Workspace `data_residency.allowed_inference_geos=["us"]` and `default_inference_geo="us"` (enforced natively, checked by Terraform). Per-request `inference_geo: "us"`. Workspace geo is `"us"` only and is set at creation. | `native/admin-api.sh`, `native/data-residency.md`, `native/request-example.json`, `terraform/main.tf` |
| AIG-05 privacy | ZDR by arrangement with sales. HIPAA readiness plus a BAA, enabled in the Console. | `mapping.yaml`, `native/data-residency.md` |
| AIG-13 logging | Compliance API Activity Feed exported to JSONL (retained for 6 years). Usage and cost reports grouped by `inference_geo`. | `native/compliance-activity-export.sh`, `native/admin-api.sh` |
| AIG-17 blast radius | No active keys in the Default Workspace, which cannot carry spend or rate limits. Required workspaces must have rate-limit overrides. | `terraform/main.tf` |

## Prerequisites

- **Admin API key.** You need an Admin API key (`sk-ant-admin...`), and only the admin role can create one. The Admin API is unavailable for individual accounts.
- **Compliance export key.** Use a Compliance Access Key (created in claude.ai) or an Admin key. An Admin key reaches only the Activity Feed.
- **Tooling.** Terraform >= 1.6 (`check` blocks need >= 1.5). The native scripts need `curl` and `jq`.

## Verify posture with Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
export TF_VAR_anthropic_admin_api_key=sk-ant-admin...
terraform init
terraform plan                    # check warnings + posture_violations output; fails if fail_on_violation=true
```

- `terraform validate` makes no network calls. The data sources run only during `plan`.
- **Treat the plan as sensitive.** The admin key is marked sensitive, but the response bodies (workspace names, key IDs, partial key hints) appear in state. Use `-refresh-only` or `plan` without a saved state file, or keep the state in an encrypted backend.

## Apply natively

```bash
export ANTHROPIC_ADMIN_KEY=sk-ant-admin...
./native/admin-api.sh create-workspace production --us-only
./native/admin-api.sh add-member wrkspc_... user_... workspace_developer
./native/admin-api.sh list-keys
./native/admin-api.sh disable-stale-keys 90            # dry run
./native/admin-api.sh disable-stale-keys 90 --apply
./native/admin-api.sh usage-report 2026-10-01T00:00:00Z 2026-10-13T00:00:00Z usage.jsonl
ANTHROPIC_COMPLIANCE_KEY=... ./native/compliance-activity-export.sh claude-activity.jsonl
```

**Steps that only work in the Console.** The API can't do these:

- **Create API keys.** The Admin API can only read keys, rename them and change their status.
- **Set workspace spend limits** (Settings → Workspaces → Spend limits).
- **Set workspace rate limits** (the Rate limits page). Rate limits can be read through `GET /v1/organizations/workspaces/{id}/rate_limits`.
- **Neither limit can be set on the Default Workspace.**

## Policies and attestations

**Attestations.** These are listed at https://support.claude.com/en/articles/10015870-what-certifications-has-anthropic-obtained, and the reports are available from trust.anthropic.com:
- SOC 2 Type I & Type II
- ISO 27001:2022
- ISO/IEC 42001:2023
- HIPAA-ready configuration (BAA available)

**Policies:**
- **Usage Policy** (https://www.anthropic.com/legal/aup). The page shows a version **effective November 12, 2026**, which replaces the version effective September 15, 2025. Review your use cases against the new High-risk Use Case Requirements before that date.
- **Responsible Scaling Policy v3.4**, effective 2026-07-08.

## Unverified / known gaps

- The workspace update endpoint, `workspace_geo` in the create body, and the `include_archived` / `group_by[]=inference_geo` query parameters in `native/admin-api.sh` were not confirmed against the Admin API reference. Create, list, archive, members, api_keys, usage_report, cost_report and rate_limits paths are verified.
- **No model allow-list (AIG-06).** The Admin API docs show no organization- or workspace-level model allow-list. Enforce approved models in an API gateway or in application config. Alternatively, consume Claude through a cloud with model-access policy: Vertex `vertexai.allowedModels`, the Azure "Foundry model deployments should only use approved models" policy, or a Bedrock SCP.
- **Guardrails are the customer's responsibility (AIG-10)** on the first-party API. When Claude runs on Bedrock, Vertex or Foundry, use that cloud's guardrails (see the cloud packs).
- **No last-used timestamp on keys.** Stale keys are identified by age (`created_at`) instead.
- **Spend limits.** The Spend Limits API exists only for Claude Enterprise. For Console organizations, spend limits are set and checked in the Console.
- **Workspace geo is `"us"` only.** There is no in-region storage for EU, AU or NZ, so treat this as a cross-border transfer (AIG-18).
- **Default Workspace detection.** Keys bound to the Default Workspace are identified as top-level `workspace_id == null` with `scope.type == "workspace"`. This follows the documented semantics. It also assumes the Default Workspace's real ID differs from the IDs of any named workspace.
- **Pagination limit in Terraform.** The module reads one page of up to 1000 items. Larger organizations get an explicit "truncated" violation; use the native scripts for full pagination.
- **UNVERIFIED:**
  - the standard commercial retention period (the docs defer to privacy.claude.com);
  - SCIM on Team plans;
  - the trust.anthropic.com framework list, which is a JavaScript app and could not be read;
  - the ASL level of current models.
