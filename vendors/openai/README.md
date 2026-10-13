# OpenAI API Platform pack

**Verified as of 2026-10-13** against developers.openai.com, help.openai.com, trust.openai.com and the `openai/openai` Terraform provider schema (v1.3.1).

## Purpose

Governs OpenAI API Platform organizations so that each environment runs in its own project. Each project:

- can call only approved models;
- has hosted tools turned off unless someone approves them;
- inherits or overrides an approved data-retention mode;
- has rate limits, a hard spend cap and a spend alert;
- runs workloads under a project service account with least privilege, not on personal user keys.

The native scripts apply the same baseline without Terraform. They also export the organization audit log to a SIEM and show the Moderation API as a runtime gate.

## What is enforced

| Control | Mechanism | File |
|---|---|---|
| AIG-02 inventory | One `openai_project` per environment, plus a named workload service account | `terraform/main.tf`, `native/admin-api.sh` |
| AIG-06 approved models | `openai_project_model_permissions` with `mode = "allow_list"` | `terraform/main.tf`, `native/admin-api.sh` |
| AIG-07 workload identity | `openai_project_service_account` (no default role, no key), a custom `openai_project_role`, and a group-based role binding | `terraform/main.tf` |
| AIG-08 / AIG-18 residency | Optional `geography`, which is fixed at project creation and needs sales eligibility | `terraform/main.tf` |
| AIG-05 retention | `openai_project_data_retention`. The default is `organization_default`; ZDR and MAM apply only after OpenAI approves them | `terraform/main.tf`, `native/admin-api.sh` |
| AIG-10 guardrails | `openai_project_hosted_tool_permissions` with every tool `false`; the Moderation API gate fails closed | `terraform/main.tf`, `native/moderation-gate.py` |
| AIG-13 logging | Audit-log export to JSONL; spend alerts | `native/audit-log-export.sh`, `terraform/main.tf` |
| AIG-17 blast radius | Project and organization hard spend limits (they return 429 once reached), spend alerts, per-model project rate limits | `terraform/main.tf`, `native/admin-api.sh` |

## Prerequisites

- An OpenAI **Admin API key**, exported as `OPENAI_ADMIN_KEY`. Admin keys cannot call non-admin endpoints.
- To disable a hosted tool for one project, the **organization-level tool policy** for that tool must be "allow selected projects". Otherwise the call fails.
- Data-retention controls must be enabled for the organization before you manage project retention.
- `zero_data_retention`, `modified_abuse_monitoring` and the `enhanced_*` variants are **subject to prior approval by OpenAI**.
- Data residency needs a sales eligibility check. The region can only be chosen when the project is created.
- Tooling: Terraform >= 1.6. For the native scripts you need `curl` and `jq`, and Python 3 for the moderation example.

## Apply with Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # edit projects, models, limits, recipients
export OPENAI_ADMIN_KEY=...                     # never in tfvars
terraform init
terraform plan -out=tfplan
terraform apply tfplan
terraform plan -detailed-exitcode               # drift check: 0 = clean, 2 = drift
```

Behaviour to know before you apply:

- **Destroying `openai_project` archives the project.** An archived project cannot be restored.
- **Rate limits update existing records; they do not create new ones.** OpenAI creates the rate-limit records. Find each record's `rate_limit_id` first with `data "openai_project_rate_limits"` or `./native/admin-api.sh show-rate-limits`.
- **Removing a resource from config does not always reset the remote setting.**
  - Removing hosted-tool permissions, data retention or a rate limit leaves the remote setting unchanged.
  - Removing model permissions deletes the project's model policy.
- **API keys for service accounts are created outside Terraform** (see `native/admin-api.sh`, `CREATE_SERVICE_ACCOUNT=true`). Key values must never pass through Terraform variables, state or outputs.

## Apply natively

```bash
export OPENAI_ADMIN_KEY=...
PROJECT_NAME=ai-gov-prod APPROVED_MODELS=gpt-5.4-mini SPEND_LIMIT_CENTS=100000 \
  ./native/admin-api.sh apply
./native/admin-api.sh show-rate-limits
./native/audit-log-export.sh openai-audit.jsonl          # schedule this for the SIEM
echo "user text" | OPENAI_API_KEY=... python3 native/moderation-gate.py   # example only
```

How `admin-api.sh` behaves on re-runs:

- It looks the project up by name and creates it only if it is missing.
- It then POSTs the full desired state of each control, so re-running converges the settings.
- With `RETENTION_TYPE=organization_default`, the retention call is skipped. That value exists only in the Terraform provider; the API enum has no "inherit" value.

## Attestations

The following are listed at https://trust.openai.com/:

- **SOC 2 Type 2.** The 2025 report covers the API Platform, ChatGPT Enterprise, Edu and Team.
- **ISO/IEC 27001:2022, 27017:2015, 27018:2019, 27701:2019 and ISO/IEC 42001:2023.**
- Also listed: SOC 3, PCI DSS v4.0.1, CSA STAR and FedRAMP 20x.

**BAA for the API.** An organization admin can self-serve it under Settings → Organization → General → "HIPAA compliance support". This requires usage history, and the setting **cannot be turned off** once enabled. You can also email baa@openai.com.

## Unverified / known gaps

- **`geography` values (UNVERIFIED).** The provider docs do not list the values `openai_project.geography` accepts. The Admin API marks `geography` as deprecated in favour of `residency`, which the provider does not expose. Leave it `null` until OpenAI confirms a value for your org.
- **Audit logging (UNVERIFIED).** It is not confirmed whether audit logging must be enabled first, or how long audit logs are retained. The bracketed `effective_at[gte]` query encoding in `audit-log-export.sh` is also unconfirmed; the cursor file is the fallback.
- **SCIM for API Platform organizations (UNVERIFIED).**
- **No private network path to api.openai.com.** For network isolation, consume OpenAI models through Azure (see the Azure/Foundry pack).
- **Moderation is not enforced across the organization.** Each application must call it.
- **Non-ZDR-eligible endpoints.** These keep state "until deleted": `/v1/assistants`, `/v1/threads`, `/v1/vector_stores`, `/v1/files`, `/v1/fine_tuning/jobs`, `/v1/evals` and `/v1/batches`. Block them in the application if ZDR is required.
- **Restricted API-key permissions** (All / Restricted / Read Only) are set in the dashboard. They are not managed by this pack.
- **Customer-managed keys (`external_key_id`)** are not enabled: CMK eligibility was not verified.
