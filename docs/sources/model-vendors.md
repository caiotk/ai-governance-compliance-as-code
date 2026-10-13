# Model vendor governance facts: OpenAI, Anthropic, Meta Llama

Research date: 2026-10-13. Every fact below was read from the vendor's own website, docs or GitHub org on that date. Anything that could not be confirmed there is marked **UNVERIFIED:**.

Notes on sources:
- `platform.openai.com/docs/...` now redirects (302) to `developers.openai.com/api/...`. Every OpenAI developer link below uses the new host.
- `docs.anthropic.com` / `docs.claude.com` now redirect to `platform.claude.com/docs/...`.
- `llama.com/...` now redirects to `dev.meta.ai/llama/...`.
- Llama Stack has been **renamed OGX** (repo `github.com/ogx-ai/ogx`; `github.com/meta-llama/llama-stack` serves the same README). Its Safety/Shields API was **removed in OGX 1.0** (see section 3).

---

## 1. OpenAI (API Platform and ChatGPT Enterprise)

### 1.1 Organization and project governance (API Platform)

- **Hierarchy.** An Organization is the top-level account, and a Project is "a workspace for keys, files, and resources." Roles exist at both organization and project level. Groups can be synced from an IdP via SCIM. Custom roles are supported. Source: https://developers.openai.com/api/docs/guides/rbac.md
- **Preset roles** in the RBAC permission table: Org owner, Org reader, Project owner, Project member, Project viewer. Source: https://developers.openai.com/api/docs/guides/rbac.md
- **Admin API key.** Every Administration API endpoint requires one. "Admin API keys cannot be used for non-administration endpoints." Keys are created at https://platform.openai.com/settings/organization/admin-keys. The auth header in the documented curl examples is `Authorization: Bearer $OPENAI_ADMIN_KEY`. Sources: https://developers.openai.com/api/reference/administration/overview and https://developers.openai.com/api/docs/guides/admin-apis.md
- **Administration API resource groups** (from the reference sidebar): Admin API Keys, Audit Logs, Certificates, Data Retention, External Storage, Groups (with Roles and Users), Invites, Projects (with API Keys, Certificates, Data Retention, Groups, Hosted Tool Permissions, Model Permissions, Rate Limits, Roles, Service Accounts, Spend Alerts, Spend Limit, Users), Roles, Spend Alerts, Spend Limit, Usage (incl. costs), and Users. Source: https://developers.openai.com/api/reference/administration/overview
- **Verified endpoint paths.** Each was taken from the curl example on its reference page under `https://developers.openai.com/api/reference/resources/admin/subresources/organization/subresources/...`:

  | Method | Path | Purpose |
  |---|---|---|
  | POST | `/v1/organization/projects` | Create project |
  | POST | `/v1/organization/projects/{project_id}/archive` | Archive project (there is no delete) |
  | GET | `/v1/organization/users` | List org users |
  | POST | `/v1/organization/invites` | Invite user |
  | GET | `/v1/organization/audit_logs` | List audit logs |
  | POST | `/v1/organization/admin_api_keys` | Create Admin API key |
  | POST | `/v1/organization/projects/{project_id}/service_accounts` | Create project service account |
  | GET | `/v1/organization/projects/{project_id}/api_keys` | List project API keys |
  | GET | `/v1/organization/projects/{project_id}/rate_limits` | List project rate limits |
  | POST | `/v1/organization/projects/{project_id}/rate_limits/{rate_limit_id}` | Update a project rate limit |
  | POST | `/v1/organization/projects/{project_id}/model_permissions` | Set model allow/deny list |
  | POST | `/v1/organization/projects/{project_id}/hosted_tool_permissions` | Enable or disable hosted tools per project |
  | POST | `/v1/organization/projects/{project_id}/data_retention` | Project data-retention override |
  | POST | `/v1/organization/data_retention` | Organization data-retention setting |
  | POST | `/v1/organization/spend_limit` | Organization monthly hard spend limit |
  | POST | `/v1/organization/projects/{project_id}/spend_limit` | Project monthly hard spend limit |
  | GET | `/v1/organization/costs` | Cost report |

- **Project model access restriction.** "Set `mode` to `allow_list` to allow only the listed models, or set `mode` to `deny_list` to block the listed models while allowing other available models. Model IDs must be visible to the organization." Source: https://developers.openai.com/api/docs/guides/admin-apis.md
- **Hosted-tool permissions per project.** The flags are `file_search`, `web_search`, `image_generation`, `mcp` and `code_interpreter`. The organization's tool policy must be "allow selected projects" before a single project can disable a tool. Sources: https://developers.openai.com/api/reference/resources/admin/subresources/organization/subresources/projects/subresources/hosted_tool_permissions/methods/update and https://developers.openai.com/api/docs/guides/terraform/project-controls.md
- **Rate limits.** "Rate limits are defined at the organization level and at the project level, not user level." Project rate-limit fields include `max_requests_per_1_minute`, `max_tokens_per_1_minute`, `max_images_per_1_minute`, `max_requests_per_1_day`, `max_audio_megabytes_per_1_minute` and `batch_1_day_max_input_tokens`. Responses carry `x-ratelimit-limit-project-tokens` headers. Sources: https://developers.openai.com/api/docs/guides/rate-limits.md and the `openai_project_rate_limit` schema on registry.terraform.io (openai/openai)
- **Spend limits.** Hard monthly limits exist at both organization and project level, with `threshold_amount` in cents. "When tracked spend reaches a hard limit, affected API requests return a `429` error." Spend alerts can also be set per project. Source: https://developers.openai.com/api/docs/guides/admin-apis.md
- **API key permissions (restricted keys).** The levels are **All** (the default, full permissions), **Restricted** (per resource or endpoint: None, Read, Write, or request-specific), and **Read Only**. "The key-creation dialog does not show these permission controls for service account keys." Source: https://help.openai.com/en/articles/8867743-assign-api-key-permissions
- **Audit logs.** These are listed through `GET /v1/organization/audit_logs` ("recent user actions and configuration changes"). Source: https://developers.openai.com/api/docs/guides/admin-apis.md
  - UNVERIFIED: whether audit logging must first be enabled in organization settings, and how long audit logs are retained. Neither was stated on the pages read.

### 1.2 Data retention (ZDR / MAM)

- **Default.** "By default, abuse monitoring logs are generated for all API feature usage and retained for up to 30 days, unless longer retention is required by law." API data is not used for training: the endpoint table shows "Data used for training: No". Source: https://developers.openai.com/api/docs/guides/your-data.md
- **Controls.** These are **Modified Abuse Monitoring (MAM)** and **Zero Data Retention (ZDR)**, plus newer variants: ZDR with Private Safety Processing, Private Retention with PSP (formerly "Eyes Off"), and Safety Retention. All are "subject to prior approval by OpenAI." Under ZDR, the `store` parameter for `/v1/responses` and `/v1/chat/completions` is always treated as `false`. Source: https://developers.openai.com/api/docs/guides/your-data.md
- **Scope.** Retention can be set at organization level, or per project as `default` (inherit), ZDR, MAM, or None. This is configured under Settings → Organization → Data controls → Data Retention. Source: https://developers.openai.com/api/docs/guides/your-data.md
- **API enum.** `retention_type` takes `"zero_data_retention" | "modified_abuse_monitoring" | "enhanced_zero_data_retention" | "enhanced_modified_abuse_monitoring"`. The Terraform provider also accepts `organization_default` and `none` at project level. Sources: https://developers.openai.com/api/reference/resources/admin/subresources/organization/subresources/data_retention/methods/update and https://developers.openai.com/api/docs/guides/terraform/project-controls.md
- **Not ZDR-eligible.** Endpoints that keep application state "until deleted" are not ZDR-eligible. They include `/v1/assistants`, `/v1/threads`, `/v1/vector_stores`, `/v1/files`, `/v1/fine_tuning/jobs`, `/v1/evals` and `/v1/batches`. Source: https://developers.openai.com/api/docs/guides/your-data.md

### 1.3 Data residency

- **What it is.** Data residency is "a project configuration option." It requires a sales eligibility check. The region is chosen when a new project is created, and requests then go to a regional domain prefix. Source: https://developers.openai.com/api/docs/guides/your-data.md
- **Regions and prefixes:**

  | Region | Prefix | Regional storage | Regional processing | MAM or ZDR required |
  |---|---|---|---|---|
  | United States | `us.api.openai.com` | Yes | Yes | No |
  | Europe (EEA + Switzerland) | `eu.api.openai.com` | Yes | Yes | Yes |
  | Australia | `au.api.openai.com` | Yes | No | Yes |
  | Canada | `ca.api.openai.com` | Yes | No | Yes |
  | Japan | `jp.api.openai.com` | Yes | No | Yes |
  | India | `in.api.openai.com` | Yes | No | Yes |
  | Singapore | `sg.api.openai.com` | Yes | No | Yes |
  | South Korea | `kr.api.openai.com` | Yes | No | Yes |
  | United Kingdom | `gb.api.openai.com` | Yes | No | Yes |
  | United Arab Emirates | `ae.api.openai.com` | Yes | Yes (subset of models) | Yes |

  Source: https://developers.openai.com/api/docs/guides/your-data.md
- **Pricing.** "Data residency endpoints are charged a 10% uplift for models released on or after March 5, 2026." Source: same page.
- **What is excluded.** Data residency does not cover "system data" (account data, metadata, usage data). Source: same page.

### 1.4 Identity (SSO / SCIM)

- **SSO** is supported for ChatGPT Enterprise/Edu (through the Admin Console), standalone ChatGPT Business, and API Platform organizations linked to a tenant. "A ChatGPT subscription does not automatically include API organization access or API SSO." SAML is supported. OIDC is mentioned only as "Custom OIDC" on existing configurations. Source: https://help.openai.com/en/articles/9534785-single-sign-on-sso-setup-for-openai-products
- **SCIM** is supported tenant-wide and for eligible ChatGPT workspaces. SCIM-synced groups can be read by the API RBAC/Terraform. Sources: same page, https://help.openai.com/en/collections/11585137-sso-scim-and-user-management and https://developers.openai.com/api/docs/guides/terraform/projects-and-access.md
  - UNVERIFIED: SCIM availability specifically for API Platform organizations.

### 1.5 ChatGPT Enterprise Compliance API

- **What it covers.** It provides "logs and metadata from your ChatGPT workspace": conversation messages (only a workspace owner can grant this), audit, authentication and app logs, and Codex policy/config change history. Source: https://help.openai.com/en/articles/9261474-compliance-api-for-chatgpt-enterprise-edu-and-chatgpt-for-teachers
- **Current model.** The **Compliance Logs Platform** gives "immutable, append-only compliance log events" and keeps data for 30 days. The older Stateful Compliance API was deprecated and **removed on Jun 5, 2026**. Access uses a workspace-scoped Admin key. The reference is at chatgpt.com/public/admin/api-reference. Source: same article.
- **Listed partner integrations** (selection): Microsoft Purview, Netskope, Palo Alto Networks, Zscaler, Varonis, Forcepoint, CrowdStrike, Relativity, Smarsh, Global Relay, Theta Lake. Source: same article.
- **ChatGPT workspace Admin keys** are workspace-scoped, with permissions All, Read only, or Custom. Source: https://help.openai.com/en/articles/20001407
- UNVERIFIED: exact Compliance Logs Platform endpoint paths. The help article gives none.

### 1.6 Policies and safety

- **Usage policies.** Title "Usage policies", effective **October 29, 2025**, at https://openai.com/policies/usage-policies/. The sections are "Protect people", "Respect privacy", "Keep minors safe" and "Empower people".
- **Moderation endpoint.** `POST https://api.openai.com/v1/moderations` with model **`omni-moderation-latest`**. It takes text and images (no audio), is free to use, and accepts images up to 20 MB. Categories: `harassment`, `harassment/threatening`, `hate`, `hate/threatening`, `illicit`, `illicit/violent`, `self-harm`, `self-harm/intent`, `self-harm/instructions`, `sexual`, `sexual/minors`, `violence`, `violence/graphic`. Inline moderation on Responses is also available (`moderation: {"model": "omni-moderation-latest"}`). Source: https://developers.openai.com/api/docs/guides/moderation.md
- **Safety best practices.** The guide covers the Moderation API, adversarial testing, human in the loop, prompt engineering, KYC, constraining input and output, user reporting, communicating limitations, the **`safety_identifier`** request parameter, revoking compromised keys, and CSAM guidance. Source: https://developers.openai.com/api/docs/guides/safety-best-practices.md
- **Model Spec.** The current version is dated **2026-08-18** at https://model-spec.openai.com/2026-08-18.html (https://model-spec.openai.com/ redirects there). Its levels of authority are Root, System, Developer, User, Guideline, and No Authority (assistant/tool messages and quoted or untrusted content).

### 1.7 Compliance attestations (trust.openai.com)

- **Listed:** SOC 2 Type 2, SOC 3, PCI DSS v4.0.1, ISO/IEC 27001:2022, ISO/IEC 27017:2015, ISO/IEC 27018:2019, ISO/IEC 27701:2019, **ISO/IEC 42001:2023**, CCPA, CSA STAR, GDPR, TX-RAMP, FedRAMP 20x. Source: https://trust.openai.com/
- **Scope stated:** the SOC 2 Type 2 (2025) report covers the API Platform, ChatGPT Enterprise, ChatGPT Edu and ChatGPT Team. ISO 27001 covers the API, ChatGPT Enterprise and ChatGPT Edu. Source: same page.
- **DPA:** "OpenAI Data Processing Addendum", effective January 1, 2026, at https://openai.com/policies/data-processing-addendum/
- **BAA (API):** an organization admin can self-serve under Settings → Organization → General → "HIPAA compliance support" → Enable (this requires established usage history), or contact baa@openai.com. "An enterprise agreement is not required to sign a BAA for API services." Once enabled, this setting cannot be turned off. Source: https://help.openai.com/en/articles/8660679-getting-a-business-associate-agreement-for-the-openai-api
- **BAA (ChatGPT):** sales-managed Enterprise and Edu accounts arrange a BAA through sales. "We do not offer a BAA for ChatGPT Business." Source: same article.
- HIPAA itself is not listed as a framework on trust.openai.com.

### 1.8 Terraform

- **There is an official OpenAI provider:** `openai/openai`. Its source is https://github.com/openai/terraform-provider-openai. OpenAI's docs call it "The official OpenAI Terraform provider" (https://developers.openai.com/api/docs/guides/terraform.md).
- **Registry tier.** registry.terraform.io lists it as tier **community** (not HashiCorp "partner"). The latest version is **1.3.1**, published 2026-09-25.
- **Credentials.** It uses `OPENAI_ADMIN_KEY` / `admin_api_key` for administration and `OPENAI_API_KEY` for the beta webhook resources.
- **Resources** include `openai_project`, `openai_project_model_permissions`, `openai_project_hosted_tool_permissions`, `openai_project_rate_limit`, `openai_project_data_retention`, `openai_organization_data_retention`, `openai_project_service_account`, `openai_project_role`, `openai_group`, `openai_project_group_role`, `openai_organization_spend_limit`, `openai_project_spend_limit` and `openai_project_spend_alert`.
- **Destroy behaviour.** "Destroying an `openai_project` archives the project ... You can't restore an archived project." (projects-and-access guide)

### 1.9 Verified examples (verbatim from OpenAI docs)

```bash
# Create a project — https://developers.openai.com/api/reference/resources/admin/subresources/organization/subresources/projects/methods/create
curl -X POST https://api.openai.com/v1/organization/projects \
  -H "Authorization: Bearer $OPENAI_ADMIN_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Project ABC"
  }'

# Project model deny-list — .../projects/subresources/model_permissions/methods/update
curl -X POST https://api.openai.com/v1/organization/projects/proj_abc/model_permissions \
  -H "Authorization: Bearer $OPENAI_ADMIN_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "mode": "deny_list",
    "model_ids": [
      "o3"
    ]
  }'

# Project data retention — .../projects/subresources/data_retention/methods/update
curl -X POST https://api.openai.com/v1/organization/projects/proj_abc/data_retention \
  -H "Authorization: Bearer $OPENAI_ADMIN_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "retention_type": "modified_abuse_monitoring"
  }'
```

(The reference pages render as HTML and were whitespace-collapsed when read. The line breaks above are reconstructed, but the tokens are verbatim.)

```terraform
# https://developers.openai.com/api/docs/guides/terraform/project-controls.md
resource "openai_project_model_permissions" "application" {
  project_id = "proj_123"
  mode       = "allow_list"
  model_ids  = ["gpt-5.4-mini"]
}

resource "openai_project_data_retention" "application" {
  project_id = "proj_123"
  type       = "organization_default"
}
```

---

## 2. Anthropic Claude (Claude API / Console, Claude for Work Team/Enterprise)

### 2.1 Organization governance

- **Workspaces.** Every org has a **Default Workspace** that "cannot be renamed, archived, or deleted". The default maximum is **100 workspaces** per org (archived ones don't count). Archiving a workspace archives all of its API keys and cannot be undone. The Default Workspace shows `workspace_id: null` in API keys and usage/cost reports. Source: https://platform.claude.com/docs/en/manage-claude/workspaces
- **Workspace roles.** Workspace User, Workspace Limited Developer, Workspace Developer, Workspace Admin and Workspace Billing. The API values seen are `workspace_developer` and `workspace_admin`. Source: same page.
- **Organization roles.** `user`, `claude_code_user`, `developer`, `billing` and `admin`, with owners and primary owners above them. Source: https://platform.claude.com/docs/en/manage-claude/admin-api
- **Workspace spend and rate limits.** These are set in the Console: spend limits under Settings → Workspaces, and rate limits (RPM, input TPM, output TPM per model) on the Rate limits page. They "can [be set] lower than (but not higher than) your organization's limits". "You cannot set limits on the Default Workspace". "Organization-wide limits always apply." Source: https://platform.claude.com/docs/en/manage-claude/workspaces
- **Claude Code workspace.** It is created automatically, has rate limits separate from other workloads, and "is the only workspace that supports per-user monthly spend limits." Source: same page.
- **Admin API authentication.** Three credentials work:
  - an **Admin API key `sk-ant-admin...`** in the `x-api-key` header, which only the admin role can create;
  - an OAuth bearer token with the `org:admin` scope;
  - a personal or service-account key that is not scoped to a workspace.

  Every request also sends `anthropic-version: 2023-06-01`. The Admin API is "unavailable for individual accounts." Source: https://platform.claude.com/docs/en/manage-claude/admin-api
- **Verified Admin API paths** (base `https://api.anthropic.com`). Sources: admin-api, workspaces, usage-cost-api and rate-limits-api pages.

  | Method | Path |
  |---|---|
  | GET | `/v1/organizations/me` |
  | GET | `/v1/organizations/users` |
  | GET / POST / DELETE | `/v1/organizations/users/{user_id}` |
  | POST / GET | `/v1/organizations/invites` |
  | DELETE | `/v1/organizations/invites/{invite_id}` |
  | POST / GET | `/v1/organizations/workspaces` |
  | POST | `/v1/organizations/workspaces/{workspace_id}/archive` |
  | POST / GET | `/v1/organizations/workspaces/{workspace_id}/members` |
  | POST / DELETE | `/v1/organizations/workspaces/{workspace_id}/members/{user_id}` |
  | GET | `/v1/organizations/api_keys` (filters: `status`, `workspace_id`) |
  | POST | `/v1/organizations/api_keys/{api_key_id}` (rename / change status) |
  | GET | `/v1/organizations/usage_report/messages` |
  | GET | `/v1/organizations/cost_report` |
  | GET | `/v1/organizations/rate_limits` |
  | GET | `/v1/organizations/workspaces/{workspace_id}/rate_limits` |
  | — | `/v1/organizations/external_keys` (CMEK; Claude Platform on AWS) |

- **API keys cannot be created through the Admin API.** "You create API keys in the Claude Console. The Admin API can only read, rename, and change the status of existing keys." Invites expire after 21 days. The API cannot remove members with the admin role. Source: https://platform.claude.com/docs/en/manage-claude/admin-api
- **Claude Enterprise organizations.** They use a scoped API key created in claude.ai. Only the members and invites endpoints apply to them, plus the Enterprise-only group and role reads and the **Spend Limits API** (scopes `read:spend_limits` / `write:spend_limits`; Enterprise only). Sources: https://platform.claude.com/docs/en/manage-claude/admin-api and https://platform.claude.com/docs/en/manage-claude/spend-limits-api
- **Other documented admin capabilities:**
  - Workload Identity Federation (WIF) for AWS, GitHub Actions, Google Cloud, Kubernetes, Microsoft Entra ID, Okta and SPIFFE.
  - Customer-managed encryption keys (CMEK) with AWS KMS, Azure Key Vault and Google Cloud KMS.

  Source: https://platform.claude.com/llms.txt (Admin section)

### 2.2 Data retention, ZDR, HIPAA

- **Default.** "Conversation content (your prompts and Claude's outputs) is not retained by default; the exception is Covered Models, which require 30-day retention." Retained data "is never used for model training without your express permission." Source: https://platform.claude.com/docs/en/manage-claude/api-and-data-retention
  - UNVERIFIED: the precise standard commercial retention period. The page defers to https://privacy.claude.com/en/articles/7996866, which was not read.
- **ZDR.** "Anthropic does not store customer prompts or responses at rest after the API response is returned." It is requested through sales and enabled per organization. Source: same page.
  - Covered: the Messages and Token Counting APIs (eligible features), Claude Code with Commercial-org API keys, and Claude Platform on AWS.
  - Not covered: the Console/playground, Managed Agents, consumer plans, the Claude Team/Enterprise product interfaces, Claude for Excel, and Covered Models. Claude Code on Enterprise has its own separate ZDR offering. CORS is unsupported under ZDR.
- **Covered Models.** Claude Fable 5.1, Claude Mythos 5.1, Claude Fable 5 and Claude Mythos 5 require 30-day retention. A ZDR org can enable 30-day retention in a single workspace to use them. Source: same page.
- **HIPAA.** "With a signed BAA and a HIPAA-enabled organization ... Eligible organizations can review and execute the BAA and enable HIPAA readiness directly from the Claude Console." "If your organization handles PHI, HIPAA readiness is the arrangement to use; you do not also need ZDR." Source: same page.

### 2.3 Data residency

- **`inference_geo`.** This is a per-request parameter on `POST /v1/messages`: `"global"` (the default) or `"us"`. Supported on Claude 4.6 and later models; requests to older models return 400. US-only inference is priced at 1.1x. Workspace controls `allowed_inference_geos` and `default_inference_geo` live under the `data_residency` field, settable in the Console or the Admin API. Source: https://platform.claude.com/docs/en/manage-claude/data-residency
- **Workspace geo.** This is where data is stored at rest. It is set when the workspace is created and can't be changed. "Currently, `"us"` is the only available workspace geo." Source: same page.
- **Third-party clouds.** On Bedrock and Google Cloud, the region comes from the endpoint or inference profile, so `inference_geo` does not apply. On Microsoft Foundry, use the US Data Zone Standard deployment type. Source: same page.

### 2.4 Identity, audit and Compliance API

- **SSO.** "Single sign-on is available for Team plans, Enterprise plans, and Console organizations." It includes DNS TXT domain verification and optional JIT provisioning. Source: https://support.claude.com/en/articles/13132885-setting-up-single-sign-on-sso
- **SCIM** is documented for the **Enterprise plan**. Setup goes through the WorkOS-hosted directory setup, and IdP groups do not map to Claude roles. Source: https://support.claude.com/en/articles/9970869-setting-up-scim-on-the-enterprise-plan
  - UNVERIFIED: SCIM on Team plans.
- **Compliance API.** Base path `/v1/compliance/*` on api.anthropic.com, using `x-api-key` and `anthropic-version`. It has a shared limit of 600 requests per minute. Source: https://platform.claude.com/docs/en/manage-claude/compliance-api
  - A **Compliance Access Key** (created in claude.ai) reaches every endpoint.
  - An Admin API key reaches only the **Activity Feed** (`GET /v1/compliance/activities`, scope `read:compliance_activities`).
  - Enterprise coverage: directory (orgs, users, roles, groups, settings); claude.ai chats, files and projects; and session transcripts for Cowork, Claude Code, Claude in Chrome, etc.
- **Retention of compliance data.** The Activity Feed is kept for 6 years. Source: https://platform.claude.com/docs/en/manage-claude/api-and-data-retention
- **Audit-log export.** A CSV export exists under claude.ai → Organization settings → Data and privacy (owners only, capped lookback window). Anthropic says to "Standardize on the Compliance API for ongoing programmatic use." Source: https://platform.claude.com/docs/en/manage-claude/compliance-api

### 2.5 Policies

- **Usage Policy.** Also called the "Acceptable Use Policy" / "AUP", at https://www.anthropic.com/legal/aup.
  - The page now shows "**Effective November 12, 2026**", a future date that replaces the version effective **September 15, 2025** (archived at https://www.anthropic.com/legal/archive/22742366-2ef0-4c7a-a833-6523f10d3944).
  - Structure: Universal Usage Standards, High-risk Use Case Requirements, and Additional Use Case Guidelines.
  - High-risk areas in the Nov 2026 version: Legal, Medical, Finance, Credit, Insurance, Housing, Employment, Education and credentials, Healthcare access, Public benefits and services, Legal status and adjudication.
- **Responsible Scaling Policy.** **Version 3.4, effective July 8, 2026**, at https://www.anthropic.com/responsible-scaling-policy. Earlier versions were 3.3 (May 26, 2026), 3.2 (Apr 29, 2026), 3.1 (Apr 2, 2026), 3.0 (Feb 24, 2026) and 2.2 (May 14, 2025). The page references ASL-3 Security and Deployment Standards.
  - UNVERIFIED: which ASL level applies to current frontier models. The page does not state it.

### 2.6 Availability via hyperscalers (all on platform.claude.com)

- **Amazon Bedrock.** Two integrations:
  - "Claude in Amazon Bedrock (Opus 4.7 and later)": the Messages API at `/anthropic/v1/messages`, on AWS-managed infrastructure "with zero operator access". https://platform.claude.com/docs/en/build-with-claude/claude-in-amazon-bedrock
  - The legacy InvokeModel/Converse integration for Opus 4.6 and earlier. https://platform.claude.com/docs/en/build-with-claude/claude-on-amazon-bedrock-legacy
- **Claude Platform on AWS.** Anthropic-operated, with AWS SigV4/IAM authentication and AWS Marketplace billing. https://platform.claude.com/docs/en/build-with-claude/claude-platform-on-aws
- **Google Cloud.** "Claude on Google Cloud" through Google Cloud's **Agent Platform** (the page links to cloud.google.com/vertex-ai). `anthropic_version` is sent as `vertex-2023-10-16` in the body. https://platform.claude.com/docs/en/build-with-claude/claude-on-vertex-ai
- **Microsoft Foundry.** "Claude in Microsoft Foundry", with Global Standard and US Data Zone Standard deployment types, billed through the Azure Marketplace. https://platform.claude.com/docs/en/build-with-claude/claude-in-microsoft-foundry
- **Data processor.** On Bedrock and Google Cloud, "the cloud provider is the data processor". Source: api-and-data-retention page.

### 2.7 Certifications

- **Listed:** "HIPAA-ready configuration (BAA available)", "ISO 27001:2022 (Information Security Management)", "ISO/IEC 42001:2023 (AI Management Systems)", "SOC 2 Type I & Type II". Reports are available from the Trust Portal at trust.anthropic.com. Source: https://support.claude.com/en/articles/10015870-what-certifications-has-anthropic-obtained
- **ISO 42001 announcement:** dated Jan 13, 2025. https://www.anthropic.com/news/anthropic-achieves-iso-42001-certification-for-responsible-ai
- **UNVERIFIED:** the trust.anthropic.com framework list itself. The page is a JavaScript (Vanta) app and returned no readable content. CSA STAR and FedRAMP were not confirmed from Anthropic sources.

### 2.8 Terraform

- **No official Anthropic provider found.**
  - `registry.terraform.io/v1/providers/anthropic/anthropic` and `/anthropics/anthropic` both return 404.
  - Claude docs (`platform.claude.com/llms.txt`) contain no Terraform page.
- **Community providers exist (not Anthropic):**
  - `ippontech/anthropic` (v1.60.0, 2026-10-08, community tier)
  - `terraform-mars/anthropic` (v0.3.0, community tier)

### 2.9 Verified examples (verbatim from platform.claude.com)

```bash
# Create a workspace — https://platform.claude.com/docs/en/manage-claude/workspaces
curl -X POST "https://api.anthropic.com/v1/organizations/workspaces" \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -H "content-type: application/json" \
    -d '{"name": "Production"}'

# Invite a user — https://platform.claude.com/docs/en/manage-claude/admin-api
curl "https://api.anthropic.com/v1/organizations/invites" \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -H "content-type: application/json" \
    -d '{
      "email": "user@example.com",
      "role": "developer"
    }'

# Compliance Activity Feed — https://platform.claude.com/docs/en/manage-claude/compliance-api
curl --fail-with-body -sS \
  "https://api.anthropic.com/v1/compliance/activities?limit=1" \
  --header "x-api-key: $ANTHROPIC_COMPLIANCE_ACCESS_KEY" \
  --header "anthropic-version: 2023-06-01"
```

(In these docs examples `$ANTHROPIC_API_KEY` holds the Admin key `sk-ant-admin...`.)

---

## 3. Meta Llama (open weights)

### 3.1 License (Llama 4 Community License Agreement)

- **Name and date.** "Llama 4 Community License Agreement", "Llama 4 Version Effective Date: April 5, 2025". https://www.llama.com/llama4/license/ (now served at https://dev.meta.ai/llama/llama4/license)
- **Attribution.** "prominently display “Built with Llama” on a related website, user interface, blogpost, about page, or product documentation."
- **Derived model naming.** Any model trained from Llama materials or outputs and then distributed must "include “Llama” at the beginning of any such AI model name."
- **Notice file.** It must contain: "Llama 4 is licensed under the Llama 4 Community License, Copyright © Meta Platforms, Inc. All Rights Reserved."
- **AUP.** Incorporated by reference: https://developer.meta.com/ai/llama4/use-policy (the llama.com URL is https://www.llama.com/llama4/use-policy/).
- **700M MAU clause.** "If, on the Llama 4 version release date, the monthly active users ... is greater than 700 million monthly active users in the preceding calendar month, you must request a license from Meta, which Meta may grant to you in its sole discretion."

### 3.2 Acceptable Use Policy (Llama 4)

- **Prohibited uses:**
  1. Violating the law or others' rights. This includes violence or terrorism, child exploitation, human trafficking, unlicensed professional practice, inferring sensitive personal information without legal right, IP infringement, malware, and circumventing safety measures.
  2. Risk of death or bodily harm. This includes military, warfare, nuclear, ITAR, bio/chem weapons, guns, illegal drugs, critical infrastructure and heavy machinery, and self-harm.
  3. Intentional deception. This includes fraud and disinformation, defamation, spam, impersonation, "Representing that the use of Llama 4 or outputs are human-generated", and fake engagement.
  4. Failing to disclose known dangers to end users.
  5. Using third-party tools designed for unlawful content.

  Source: https://www.llama.com/llama4/use-policy/
- **EU multimodal restriction (verified):** "With respect to any multimodal models included in Llama 4, the rights granted under Section 1(a) of the Llama 4 Community License Agreement are not being granted to you if you are an individual domiciled in, or a company with a principal place of business in, the European Union. This restriction does not apply to end users of a product or service that incorporates any such multimodal models." Source: same page.
- **Reporting channels.** AUP violations go to LlamaUseReport@meta.com. Model issues go to github.com/meta-llama/llama-models/issues.

### 3.3 Safety tools

- **Llama Guard 4 (12B)** is the latest safeguard model. It is natively multimodal (text plus multiple images), "pruned from the Llama 4 Scout pre-trained model", and runs on a single GPU. It is a drop-in replacement for Llama Guard 3 8B and 11B. Hugging Face ID: `meta-llama/Llama-Guard-4-12B`. Sources: https://www.llama.com/docs/model-cards-and-prompt-formats/llama-guard-4/ and https://github.com/meta-llama/PurpleLlama/blob/main/Llama-Guard4/12B/MODEL_CARD.md
- **Hazard taxonomy.** "The model is trained to predict safety labels on the categories shown below, based on the MLCommons safety taxonomy. We include an additional category, Code Interpreter Abuse." The exact labels from the GitHub model card are:
  - S1: Violent Crimes
  - S2: Non-Violent Crimes
  - S3: Sex-Related Crimes
  - S4: Child Sexual Exploitation
  - S5: Defamation
  - S6: Specialized Advice
  - S7: Privacy
  - S8: Intellectual Property
  - S9: Indiscriminate Weapons
  - S10: Hate
  - S11: Suicide & Self-Harm
  - S12: Sexual Content
  - S13: Elections
  - S14: Code Interpreter Abuse (text only)

  The llama.com prompt template uses shorter labels for some categories: "S3: Sex Crimes.", "S4: Child Exploitation.", "S11: Self-Harm.". Policy code should accept either form.
- **Llama Prompt Guard 2** is the latest version. It comes in 86M and 22M sizes (`meta-llama/Llama-Prompt-Guard-2-86M` / `-22M`). They are BERT classifiers that label input "benign" or "malicious". Unlike Prompt Guard 1, the separate "injection" label was dropped. Source: https://www.llama.com/docs/model-cards-and-prompt-formats/prompt-guard/
- **LlamaFirewall** (`pip install llamafirewall`) is a guardrail framework. Source: https://github.com/meta-llama/PurpleLlama/blob/main/LlamaFirewall/README.md. Its scanners are:
  - **PromptGuard 2**: prompt injection and jailbreak detection.
  - **AlignmentCheck**: chain-of-thought audit for goal hijacking and indirect injection.
  - **Regex + Custom Scanners**.
  - **CodeShield**: static analysis using Semgrep and regex, across 8 languages per the README.

  The llama.com Protections page says CodeShield covers 7 languages, which conflicts with the README. Code Shield is MIT licensed.
- **CyberSecEval 4** is the latest version. It adds CyberSOCEval and AutoPatchBench on top of the MITRE/FRR, secure-code, prompt-injection and code-interpreter-abuse tests. Sources: https://github.com/meta-llama/PurpleLlama/blob/main/CybersecurityBenchmarks/README.md and https://www.llama.com/llama-protections/
- **Responsible Use Guide.** The old URLs (https://www.llama.com/responsible-use-guide/, https://ai.meta.com/llama/responsible-use-guide/) now return **404**. The current resource is the **"Developer Use Guide for Llama"** at https://www.llama.com/developer-use-guide/ (served at https://dev.meta.ai/developer-use-guide).
- **Llama Stack shields.**
  - Llama Stack has been **renamed OGX** (https://github.com/ogx-ai/ogx; "Llama Stack is now OGX").
  - **OGX 1.0 (May 2026) removed the Safety API.** The release notes say: "Safety API removed; use `/v1/moderations` — Replace `run-shield` and `shields` calls with the moderation endpoint". `/v1/safety/run-shield` and `/v1/shields` are gone, and "configure moderation models via provider config instead." Source: https://github.com/ogx-ai/ogx/blob/main/docs/releases/RELEASE_NOTES_1.0.md
  - Current OGX moderation is the `moderation_endpoint` setting on the `inline::builtin` responses provider: an OpenAI-compatible `/v1/moderations` URL.
  - The `inline::llama-guard` provider and the `shields:` config **did exist up to v0.7.x**. They are verified in the tagged v0.7.0 docs and starter distribution (example 3.5b).

### 3.4 Llama on hyperscalers

- **Meta's own description.** Meta's Cloud partners page lists:
  - **Amazon Bedrock** ("enterprise-grade security via a unified API")
  - **Amazon SageMaker JumpStart** ("deploy models under your VPC controls")
  - **Azure AI Model Catalog** (it mentions using "Azure AI Content Safety")
  - **Google Cloud Vertex AI Model Garden** ("fully managed Llama APIs, or fine-tune and self-deploy")
  - Databricks and others

  Source: https://dev.meta.ai/llama/docs/getting-the-models/405b-partners/
- **Governance implication.** Hosted access is controlled by the cloud's IAM, guardrails and logging. The Llama 4 Community License and AUP still bind the user. Regulated self-hosting guidance: https://www.llama.com/docs/deployment/regulated-industry-self-hosting/
- **UNVERIFIED** (this needs AWS, Google or Microsoft docs, which are outside the permitted source list): specific hyperscaler controls such as Bedrock Guardrails, Vertex AI model-access org policies, and Azure Content Safety default filters for Llama, along with the current Llama 4 model availability per cloud.

### 3.5 Verified examples

a) Llama Guard prompt template header, from https://www.llama.com/docs/model-cards-and-prompt-formats/llama-guard-4/:

```text
<|begin_of_text|><|header_start|>user<|header_end|>

Task: Check if there is unsafe content in '{{ role }}' messages in conversations according to our safety policy with the below categories.

<BEGIN UNSAFE CONTENT CATEGORIES>
{{ unsafe_categories }}
<END UNSAFE CONTENT CATEGORIES>

<BEGIN CONVERSATION>
```

b) Llama Stack (≤ v0.7.x, before the OGX 1.0 removal) shield config, verbatim from `src/llama_stack/distributions/starter/config.yaml` at tag v0.7.0 of github.com/ogx-ai/ogx:

```yaml
providers:
  safety:
  - provider_id: llama-guard
    provider_type: inline::llama-guard
    config:
      excluded_categories: []
  - provider_id: code-scanner
    provider_type: inline::code-scanner
registered_resources:
  shields:
  - shield_id: llama-guard
    provider_id: ${env.SAFETY_MODEL:+llama-guard}
    provider_shield_id: ${env.SAFETY_MODEL:=}
safety:
  default_shield_id: llama-guard
```

This is an excerpt: other providers and keys in the file are left out, and `registered_resources` also contains `models: []`. The v0.7.0 provider docs give `inline::llama-guard` a single config field, `excluded_categories` (`list[str]`, default `[]`).

c) LlamaFirewall, from https://github.com/meta-llama/PurpleLlama/blob/main/LlamaFirewall/README.md:

```python
from llamafirewall import LlamaFirewall, UserMessage, Role, ScannerType

llamafirewall = LlamaFirewall(
    scanners={
        Role.USER: [ScannerType.PROMPT_GUARD],
    }
)
```
