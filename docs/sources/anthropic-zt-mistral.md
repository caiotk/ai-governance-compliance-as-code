# Research: "Anthropic Zero Trust" and Mistral AI governance controls

Researched 2026-10-13. All facts below were read from vendor-owned pages (anthropic.com, claude.com, code.claude.com, platform.claude.com, support.claude.com, docs.mistral.ai, help.mistral.ai, legal.mistral.ai) during the 13 Oct 2026 verification pass unless marked **UNVERIFIED**. Where a page contradicted another vendor page, both are recorded.

---

## 1. "Anthropic Zero Trust"

### 1.1 Is there a document literally titled "Zero Trust"? — YES

- **Blog post: "Zero Trust for AI agents"** — https://claude.com/blog/zero-trust-for-ai-agents — published **May 27, 2026** (Claude by Anthropic blog; categories "Enterprise AI, Agents"; product tag "Claude Security"; no author byline).
  - Frames the model as "trust nothing, verify everything, and assume breach has already occurred", adapted for agents: cryptographically rooted identities, task-scoped permissions, memory protected against poisoning, defensive operations fast enough to match autonomous attackers.
  - Links to the eBook below as the full guidance.
- **eBook: "Zero Trust for AI Agents — A security framework for deploying autonomous AI agents in the enterprise"** (PDF, ~35 pages, file name dated 05182026) — https://cdn.prod.website-files.com/6889473510b50328dbb70ae6/6a1611a04085d7cd3dadc924_Claude-eBook-Zero-Trust-for-AI-Agents-05182026.pdf
  - Section headings (verbatim): "Building for the next threat landscape"; "The principles behind Zero Trust"; Part I "Security considerations for autonomous systems"; Part II "Current threats to agentic systems"; Part III "Applying Zero Trust to agentic AI services"; Part IV "Agent implementation workflow"; Part V "Defensive operations at the speed of autonomous threats"; "From principles to practice".
  - **Three maturity tiers** (eBook names: **Foundation / Enterprise / Advanced**; note the blog page summarises them as "Foundation, Advanced, and Optimized" — the PDF wording governs):
    - Foundation: cryptographically rooted agent IDs, short-lived OAuth tokens, deny-by-default RBAC, identity-based isolation, immutable-style action logs.
    - Enterprise: adds X.509 certificates, mutual TLS with pinning, ABAC, sandboxed execution, append-only audit trails.
    - Advanced: hardware-backed identity (HSM/TPM), attested credentials, JIT/JEA access, confidential computing, real-time SIEM correlation.
  - **Eight implementation phases** (Part IV): 1 Identify requirements; 2 Manage supply chain risks; 3 Define agent boundaries; 4 Defend against prompt injection; 5 Secure tool access; 6 Protect agent credentials; 7 Safeguard agent memory; 8 Measure what matters.
  - Threats (cites OWASP): prompt injection (direct/indirect), tool and resource hijacking, identity and access privilege abuse, memory and context poisoning, supply chain risks; also names tool poisoning, rug pulls, tool chaining, resource exhaustion, confused deputy, RAG poisoning, shared-context poisoning, long-term memory drift.
  - Controls named: unique cryptographic agent IDs; "least agency" (OWASP term) / deny-by-default / JIT scoping; sandboxing (containers with restricted capabilities, gVisor, microVMs, AMD SEV, Intel TDX); deny-by-default tool allowlists, parameter validation, rate limits/circuit breakers; MCP stack compromise risk; memory session isolation, context-integrity validation, retention policies, versioned rollback; action logs, immutable audit trails, OpenTelemetry tracing, SIEM streaming; "Agentic SOAR" (Part V).
  - Only Anthropic product named is **Claude Code**: deny-by-default permissions, sandboxed execution, command-injection detection, managed settings and `allowManagedPermissionRulesOnly`, `settings.json` "ask" rules, `PreToolUse` hooks, OpenTelemetry metrics and `session.id`, `ConfigChange` hooks, OAuth 2.0 with refresh for MCP, `apiKeyHelper`, `cleanupPeriodDays`, checkpoints with `/rewind`. The eBook does **not** mention Workload Identity Federation, Claude Security or the Compliance API.

### 1.2 Closest companion publications (vendor-published)

- **"Zero risk isn't the job: a CISO's guide to agentic AI"** — https://claude.com/blog/ciso-guide-to-agentic-ai — **July 17, 2026**, Jason Clinton (Deputy CISO, Anthropic).
  - Four risk questions: what untrusted content does it ingest; what actions can it take and on whose behalf; what is the blast radius if misaligned; what observability do I have. Governing principle: **least agency**; default rollout is admin-paced (small group → telemetry → expand).
  - "Agentic identity spectrum": system service account ↔ human credential; the delegated-identity middle is where accountability blurs.
  - Seven requirements illustrated with Claude Cowork: identity from your IdP (SAML/OIDC sign-in, SCIM provisioning, Enterprise custom roles); connector allowlists (admin enables per connector org-wide, per-role connector control, DLP/DSPM at the boundary); per-tool per-action approval (restrict verbs org-wide or per role); sandboxed execution (Cowork remote sessions in isolated temporary sandboxes; connector calls via a credential-injecting reverse proxy so the sandbox never holds exfiltratable credentials); **egress allowlisting** ("strongest control against prompt injection"; also part of Claude Managed Agents); telemetry to SIEM over OpenTelemetry (OTLP endpoint set in Organization settings; stream includes tool name, MCP server, parameters, outcome, duration, user identity, session context; prompt content included by default in Cowork OTel, opt-in in Claude Code); org-wide off switch for connectors incl. active sessions, plus RBAC per group and per-connector write disable on Enterprise.
  - Notes ISO 42001 with a live risk register as a way to make human risk acceptance accountable.
- **"Trustworthy agents in practice"** — https://www.anthropic.com/news/trustworthy-agents — **April 9, 2026**. Five principles: keeping humans in control; aligning with human values; securing agents' interactions; maintaining transparency; protecting privacy. Describes tool-level "always allow / needs approval / block", Claude Code Plan Mode, layered prompt-injection defences (training, production monitoring, red-teaming) and the instruction that customers "carefully limit the tools, data, permissions, and environments" given to agents.
- **Claude Code "Security" doc** — https://code.claude.com/docs/en/security (also `.md` variant) — see §1.4.

### 1.3 Platform identity / data controls that implement zero-trust principles

**Workload Identity Federation (WIF)** — https://platform.claude.com/docs/en/manage-claude/workload-identity-federation
- Replaces long-lived `sk-ant-...` keys with short-lived OIDC JWT exchange. Providers with guided tiles: **GitHub Actions, AWS, Google Cloud, Microsoft Entra ID, Kubernetes**; "Custom OIDC" for **SPIFFE, Okta** and any compliant issuer (per-provider guides exist for all seven at `/docs/en/manage-claude/wif-providers/{aws,gcp,azure,github-actions,kubernetes,spiffe,okta}`).
- Resources: **service account** (`svac_...`), **federation issuer** (`fdis_...`; JWKS source `discovery` | `explicit_url` | `inline`; issuer/JWKS URLs must be https:443 public DNS), **federation rule** (`fdrl_...`; match on `subject_prefix`, `audience`, `claims`, CEL `condition`; default `scope` `workspace:developer`; `token_lifetime_seconds` 60–86400, default 3600; wizard prefills 600).
- Exchange: `POST https://api.anthropic.com/v1/oauth/token` with `grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer"`, `assertion`, `federation_rule_id`, `organization_id`, `service_account_id`, `workspace_id` → `sk-ant-oat01-...` bearer token. Minted lifetime = min(rule lifetime, 2× remaining JWT lifetime), never < 60 s. `jti` replay protection on by default (`check_jti`, failure reason `jti_reused`).
- Env vars: `ANTHROPIC_FEDERATION_RULE_ID`, `ANTHROPIC_ORGANIZATION_ID`, `ANTHROPIC_SERVICE_ACCOUNT_ID`, `ANTHROPIC_WORKSPACE_ID`, `ANTHROPIC_IDENTITY_TOKEN_FILE`. Precedence warning: `ANTHROPIC_API_KEY` outranks federation.
- Admin API management: `/docs/en/manage-claude/wif-admin-api`, references at `/docs/en/api/organization/service_accounts`, `/organization/federation/issuers`, `/organization/federation/rules`.

**Zero Data Retention (ZDR)** — https://platform.claude.com/docs/en/build-with-claude/zero-data-retention
- "Under a ZDR arrangement, Anthropic does not store customer prompts or responses at rest after the API response is returned." Requested via sales; enabled per organization. Covers Messages/Token Counting for eligible features and Claude Code with Commercial API keys; available on request for Claude Platform on AWS.
- Not covered: Console/playground, Managed Agents, consumer plans, Teams/Enterprise UIs (except a separate Claude Code on Enterprise ZDR offering), Batch (29-day), Files API, code execution (container data up to 30 days), Agent Skills, MCP connector, MCP tunnels; "Covered Models" (named on page as Claude Fable 5.1, Claude Mythos 5.1, Claude Fable 5, Claude Mythos 5) require 30-day retention (workspace-level override possible). Flagged content may be retained up to 2 years. HIPAA readiness is an alternative to ZDR. Data residency via `inference_geo` on `/v1/messages` is ZDR-eligible (details at `/docs/en/manage-claude/data-residency`).

**Compliance API** — https://platform.claude.com/docs/en/manage-claude/compliance-api
- All endpoints under `https://api.anthropic.com/v1/compliance/*`, auth header `x-api-key`, `anthropic-version` required. Two key types: **Compliance Access Key** (claude.ai; all endpoints) and **Admin API key** (Console; Activity Feed only). Scope `read:compliance_activities` for `GET /v1/compliance/activities`.
- Covers Activity Feed; for Enterprise: directory (orgs, users, roles, groups), effective settings, chats/files/projects, and session transcripts for Cowork, Claude Code, Claude Science, Claude for Microsoft 365, Claude in Chrome. Shared limit 600 req/min per parent org. Example response fields: `data[]` (`id`, `created_at`, `organization_id`, `actor{type,email_address,user_id,ip_address,user_agent}`, `type`), `has_more`, `first_id`, `last_id`.
- Related: audit log CSV export (claude.ai > Organization settings > Data and privacy), Claude Code Analytics API, OpenTelemetry logging, **Inference hooks (beta)** at `/docs/en/manage-claude/inference-hooks` — inline deny of governed prompts before inference.

**Claude Enterprise identity & roles (support.claude.com)**
- SSO: https://support.claude.com/en/articles/9797544-setting-up-single-sign-on-sso-on-team-and-enterprise-plans — "Single sign-on (SSO) is available to Team and Enterprise plans, as well as Claude Console organizations." Domain verification by TXT record at claude.ai/admin-settings/identity (WorkOS); JIT or Manual provisioning; **SCIM Enterprise only** ("SCIM is not available for Team plan organizations"); option to enforce SSO across Console and Claude surfaces; "Disable new organization creation" toggle for verified domains. Page names SAML group attribute statements; OIDC not mentioned on this page.
- Roles: https://support.claude.com/en/articles/13133750-managing-members-on-team-and-enterprise-plans — **Primary Owner** (one per org), **Owner**, **Admin**, **Member**, **Custom** (Enterprise only; access via group memberships and custom roles; "View effective role").
- Audit logs: https://support.claude.com/en/articles/9970975-access-audit-logs (page dated June 15, 2026) — Enterprise only; Owners/Primary Owners export; export window "within the past 180 days"; download link valid 24 h; columns `created_at, actor_info, event, event_info, entity_info, ip_address, device_id, user_agent, client_platform`; 35 event types incl. `user_signed_in_sso`, `org_sso_toggled`, `org_jit_toggled`, `org_domain_verified`, `org_data_export_started`. Export button unavailable with customer-managed encryption keys → use Compliance API.
- Trust Center: https://trust.anthropic.com (SOC 2 Type 2 report, ISO 27001 certificate per Claude Code Security doc).

### 1.4 Claude Code enterprise controls (verified key names)

Sources: https://code.claude.com/docs/en/settings, https://code.claude.com/docs/en/managed-settings, https://code.claude.com/docs/en/sandboxing, https://code.claude.com/docs/en/security, reference index https://code.claude.com/docs/en/settings-reference (docs.claude.com/en/docs/claude-code/* 302-redirects to code.claude.com).

- **Precedence (highest first):** Managed settings (`managed-settings.json`, MDM, or claude.ai console) → `claude --settings` → `.claude/settings.local.json` → `.claude/settings.json` → `~/.claude/settings.json`. Security-sensitive keys (e.g. `disableClaudeAiConnectors`) honour the stricter value from any level.
- **Managed settings file paths:** macOS `/Library/Application Support/ClaudeCode/managed-settings.json`; Linux/WSL `/etc/claude-code/managed-settings.json`; Windows `C:\Program Files\ClaudeCode\managed-settings.json` (legacy `C:\ProgramData\ClaudeCode\managed-settings.json` is **not** read). Optional `managed-settings.d/` drop-ins and `managed-mcp.json` in the same directory. MDM: macOS managed-preferences domain `com.anthropic.claudecode`; Windows `REG_SZ`/`REG_EXPAND_SZ` value `Settings` under `HKLM\SOFTWARE\Policies\ClaudeCode` (HKCU fallback is user-writable). Server-managed settings fetched from claude.ai admin console (polled hourly) or self-hosted Claude apps gateway; `forceRemoteSettingsRefresh: true` makes startup fail closed.
- **Documented minimal managed example (verbatim):**
  ```json
  {
    "permissions": {
      "deny": ["Read(./.env)", "Read(./secrets/**)"],
      "disableBypassPermissionsMode": "disable"
    },
    "allowManagedPermissionRulesOnly": true
  }
  ```
- **Permission keys:** `permissions.allow`, `permissions.deny`, `permissions.ask`, `permissions.additionalDirectories`, `permissions.defaultMode` (values include `auto` and `bypassPermissions`, which "don't take effect from project or local settings"), `permissions.disableBypassPermissionsMode` (value `"disable"`), `allowManagedPermissionRulesOnly`. Deny rules match command text (e.g. `Bash(curl *)`); for network enforcement independent of command text use sandbox network isolation.
- **MCP keys:** `allowedMcpServers`, `deniedMcpServers`, `allowManagedMcpServersOnly` (requires v2.1.273+; locks allowlist; `deniedMcpServers` still merges), `managedMcpServers` (v2.1.259+), `allowAllClaudeAiMcps`, `disableClaudeAiConnectors`, `managed-mcp.json`. Invalid `allowedMcpServers` fails closed to an empty allowlist.
- **Plugin/hook keys:** `strictKnownMarketplaces`, `blockedMarketplaces`, `pluginSuggestionMarketplaces`, `pluginTrustMessage`, `strictPluginOnlyCustomization`, `disableCommandPluginSources`, `disableSideloadFlags`, `allowManagedHooksOnly`, `allowedChannelPlugins`, `channelsEnabled`, `policyHelper`, `managedSourcesBehavior`, `parentSettingsBehavior`, `wslInheritsWindowsSettings`, `requiredMinimumVersion` / `requiredMaximumVersion` (fail open by design), `forceLoginMethod` (incl. `"gateway"`), `forceLoginOrgUUID` (fails closed), `forceLoginGatewayUrl`, `gatewayInternalNetworks`, `allowedProviders`, `availableModels`, `deniedModels`, `apiKeyHelper`, `env`.
- **Sandbox** (macOS Seatbelt; Linux/WSL2 `bubblewrap` + `socat`; not on native Windows): keys `sandbox.enabled`, `sandbox.failIfUnavailable`, `sandbox.allowUnsandboxedCommands`, `sandbox.autoAllowBashIfSandboxed` (default `true`), `sandbox.excludedCommands`, `sandbox.enableWeakerNestedSandbox`, `sandbox.enableWeakerNetworkIsolation`, `sandbox.allowAppleEvents`, `sandbox.filesystem.{allowWrite,denyWrite,denyRead,allowRead,allowManagedReadPathsOnly,disabled}`, `sandbox.network.{allowedDomains,deniedDomains,allowManagedDomainsOnly,strictAllowlist,allowAllUnixSockets,allowLocalBinding}`, `sandbox.credentials` (`files` with `"mode": "deny"`, `mask` entries with `injectHosts`). Sandbox covers shell commands only; Read/Edit/WebFetch, MCP servers and hooks run outside it. Documented enforcement example (verbatim):
  ```json
  { "sandbox": { "enabled": true, "failIfUnavailable": true, "allowUnsandboxedCommands": false } }
  ```
- **Security doc protections (verbatim bullets):** Permission system; Context-aware analysis; Input sanitization; Network command approval (`curl`/`wget` not auto-approved); Isolated context windows for web fetch; Trust verification (disabled with `-p`); Command injection detection; Fail-closed matching; Secure credential storage (macOS Keychain). Cloud sessions: isolated Anthropic-managed VMs, network access limited by default/configurable allowlist, scoped-credential proxy for GitHub, push restricted to current branch, audit logging. Monitoring via OpenTelemetry and `ConfigChange` hooks; `/permissions`, `/sandbox`, `/security-review`.
- Team/Enterprise Owners toggle Remote Control and cloud sessions org-wide at https://claude.ai/admin-settings/claude-code.

### 1.5 Responsible Scaling Policy — ASL-3 Security Standard (as published)

- https://anthropic.com/news/activating-asl3-protections — **May 22, 2025**. ASL-3 Security Standard protects model weights against "sophisticated non-state actors"; nation-state (non-novel chains excepted) and "sophisticated insider risk" are out of scope. Named controls: two-party authorization for weight access; enhanced change management; endpoint software controls via binary allowlisting; "we have implemented preliminary egress bandwidth controls" that "restrict the flow of data out of secure computing environments where AI model weights reside". Deployment: Constitutional Classifiers for CBRN.
- https://www.anthropic.com/rsp-updates — current **RSP v3.4, effective July 8, 2026** (PDF https://www-cdn.anthropic.com/files/4zrzovbb/website/0bacdc8440ea96e62a8766d99ebe1d4eea6d5f3a.pdf). v2.2 (May 14, 2025) narrowed the ASL-3 security footnote to exclude sophisticated and state-compromised insiders; v3.0 (Feb 24, 2026) introduced Frontier Safety Roadmaps and Risk Reports.

---

## 2. Mistral AI

### 2.1 Organisation / workspace / roles / keys

- **Organizations & Workspaces** — https://docs.mistral.ai/admin/security-access/organization — each Organization starts with a default Workspace (cannot be archived); up to 500 active Workspaces; members belong to the Organization then get Workspace access directly or via Groups; Organization admins have full access to every Workspace; spend limits per Workspace; admin panel https://admin.mistral.ai/organization/workspaces.
- **Roles** — https://docs.mistral.ai/admin/identity-access/roles-permissions — predefined, additive. Organization: `member` ("Member"), `billing_manager` ("Billing"), `organization_admin` ("Admin": settings, members, security, billing, audit logs). Workspace: `user`, `dev` ("Developer"), `mistral_code_user`, `workspace_contributor` (default for new members), `workspace_admin`, `observability_viewer`. `GET /v1/admin/roles` returns authoritative list/UUIDs. No custom roles documented.
- **API keys** — https://docs.mistral.ai/admin/security-access/api-keys — types Studio / Vibe / Mistral Code (legacy); "API keys are scoped to the Workspace where they were created"; connector scope "Shared connectors only" (default) or "Private and shared connectors"; optional expiry; org-wide expiration policy (off by default; Workspace Admins may set stricter); rotation = create new + delete old; Workspace, scope and expiry immutable after creation.
- **Admin API** — https://docs.mistral.ai/admin/admin-api/overview, https://docs.mistral.ai/admin/admin-api/authentication, https://docs.mistral.ai/admin/admin-api/api-reference — "available only on Enterprise plans, and access isn't self-serve". Base URL `https://api.mistral.ai/v1/admin`; dedicated **Admin API key** created in Backoffice (https://backoffice.mistral.ai → API keys → Create key; shown once; optional expiry; tied to one Organization); header `x-api-key: $ADMIN_API_KEY`. Example (verbatim): `curl "https://api.mistral.ai/v1/admin/users?page=1&page_size=50" -H "x-api-key: $ADMIN_API_KEY"`. Areas: users & invitations, workspaces, API keys, analytics, billing/usage/limits, audit logs, user groups (reference pages `/api/endpoint/beta/admin/{users,workspaces,api-keys,analytics,billing,audit-logs,user-groups}`). Role fields `roles`/`role_names`, `workspace_role`/`workspace_role_name` (singular `role`/`role_name` deprecated).
  - `GET /v1/admin/audit-logs` (https://docs.mistral.ai/api/endpoint/beta/admin/audit-logs) returns `AuditLogOut[]` with `log_id`, `created_at`, `actor_type` (e.g. `"HUMAN"`), `actor_metadata`, `event_type` (e.g. `"user.create"`), `event_metadata`, `target_type` (e.g. `"USER"`), `target_metadata`. **Discrepancy:** this reference page's curl shows `Authorization: Bearer ...` (scheme "AdminApiKey") while the authentication page specifies `x-api-key`.
  - **UNVERIFIED the 13 Oct 2026 verification pass:** `GET /v1/models` and fine-tuning job endpoints (`/v1/fine_tuning/jobs`) were not fetched; treat exact paths as unverified.
- **SSO** — https://docs.mistral.ai/admin/security-access/sso — "Organization SSO uses SAML 2.0. OpenID Connect (OIDC) is not supported for Organization SSO." "You need an Enterprise plan to configure SAML SSO." Any compliant SAML IdP; Microsoft Entra ID, Google Workspace, Okta most common. Requires a verified domain; matching users redirected to IdP; JIT provisioning on first sign-in; automatic seat assignment. **SCIM: not mentioned on the SSO page — UNVERIFIED whether Mistral offers SCIM.**
- **Audit logs** — https://docs.mistral.ai/admin/monitor-comply/audit-logs/overview — Enterprise only; "enabled automatically on Enterprise plans"; Admin Panel → Administration → Audit Logs (https://admin.mistral.ai/audit-logs). Categories: authentication (sign-ins, SSO), API usage & key management, Organization/Workspace changes, user management, settings, Vibe interactions (e.g. `batch_job.create`, `le_chat.conversation.deleted`). Fields: CreatedAt, Actor (human/API key/system), Event, Target, Metadata. UI export not supported; retention not specified (API access via `GET /v1/admin/audit-logs` above).

### 2.2 Data retention, training, residency, deployment

- **Zero Data Retention** — https://docs.mistral.ai/admin/monitor-comply/zero-data-retention — with ZDR Mistral "does not store or log inputs and outputs for supported API requests" beyond generation. Applies to stateless endpoints: `/v1/chat/completions`, `/v1/fim/completions`, `/v1/embeddings`, `/v1/moderations`, `/v1/chat/moderations`, `/v1/classifications`, `/v1/chat/classifications`, `/v1/ocr`, `/v1/audio/speech`, `/v1/audio/transcriptions` (all models except Labs). Excluded: Agents, Batch files, Conversations, Libraries, `/v1/files`, Vibe Work, Chat. Available on paid plans by request to support (help article 347612), reviewed case by case; appears at https://admin.mistral.ai/vibe/privacy. Training opt-out is a separate control (Privacy and data controls page `/admin/monitor-comply/privacy-data-controls` — not fetched the 13 Oct 2026 verification pass).
- **Privacy Policy** — https://legal.mistral.ai/terms/privacy-policy — "Effective: September 3, 2026". API inputs/outputs kept for generation then "thirty (30) rolling days to monitor abuse" unless ZDR; Agents API data until account termination; fine-tuning data until deleted; Vibe conversations until deleted. Training on "Your Input and Output, subject to your opt-out". Hosting: Mistral "prioritize[s] selecting providers within the European Union", non-EU "in exceptional cases"; SCCs for transfers; subprocessors at https://trust.mistral.ai/subprocessors.
- **Data location** — https://help.mistral.ai/en/articles/156206-when-using-mistral-ai-s-api-where-is-my-data-stored — "Mistral AI's servers are located in Europe (Sweden)." No multi-region selection documented. **UNVERIFIED:** any customer-selectable region option.
- **Commercial Terms of Service** — https://legal.mistral.ai/terms/commercial-terms-of-service — "Effective: September 25, 2026". §4.2 "Mistral AI will not use Customer Data or Outputs to train its artificial intelligence models except" listed cases (opt-in/non-opted-out users, Feedback, Order Form, Labs/Preview Models); §4.3 Labs/Preview models are training-eligible and ZDR opt-out does not apply to them; §14.10 governing law California (Americas) / Singapore (APAC) / France (rest); §12.3 references DPA for Mistral Infrastructure.
- **Usage Policy** — https://legal.mistral.ai/terms/usage-policy — effective June 11, 2026; prohibited headings: Illegal activities; CSAM; Non-consensual intimate imagery; Hate and discrimination; Violence and threats; Self-harm; Fraud and scams; Misinformation; Privacy; Professional advice; Security Violations.
- Other legal URLs (from Privacy Policy nav): DPA https://legal.mistral.ai/terms/data-processing-addendum; Additional Product Terms https://legal.mistral.ai/terms/additional-terms; Partner-served deployment terms https://legal.mistral.ai/terms/partner-served-deployment-terms; EU consumer ToS https://legal.mistral.ai/terms/eu-consumers-terms-of-service.
- **Deployment options** — https://docs.mistral.ai/models/deployment, https://docs.mistral.ai/models/deployment/cloud-deployments, https://docs.mistral.ai/deployment/self-deployment/overview — Studio (console.mistral.ai); cloud: **Azure AI, Amazon Bedrock, Google Cloud Vertex AI Model Garden, Snowflake Cortex, IBM watsonx, Outscale**; self-deployment: vLLM (recommended, OpenAI-compatible API), TensorRT-LLM, TGI, SkyPilot, Cerebrium, Cloudflare Workers AI; commercial models "through cloud provider integrations or Mistral Compute". **UNVERIFIED:** scope/details of "Mistral Compute" and any formal on-prem/VPC enterprise offering — docs only link the name. Vendor docs do not state that governance falls to the cloud provider; that is an inference (IAM, logging, data handling are the hyperscaler's when consumed via Bedrock/Vertex/Azure).

### 2.3 Safety tooling

- **Moderation API** — reference https://docs.mistral.ai/api/endpoint/classifiers; guide https://docs.mistral.ai/capabilities/guardrailing (current) and https://docs.mistral.ai/usage/guardrailing (older copy).
  - `POST /v1/moderations` — body `model`, `input` (string | string[]), `metadata`; `POST /v1/chat/moderations` — body `model`, `input` (array of messages or arrays of messages). Header `Authorization: Bearer <API key>`. Example request (verbatim from reference): `{"input": "Example input.", "model": "mistral-moderation-latest"}`. Response: `id`, `model`, `results[]` each with `categories` (booleans) and `category_scores` (floats).
  - **Category keys (API reference & /usage page, 9):** `sexual`, `hate_and_discrimination`, `violence_and_threats`, `dangerous_and_criminal_content`, `selfharm`, `health`, `financial`, `law`, `pii`.
  - **Category list on /capabilities/guardrailing (11, model `mistral-moderation-2603`):** Sexual; Hate and Discrimination; Violence and Threats; Dangerous; Criminal; Self-Harm; Health; Financial; Law; PII; Jailbreaking (guardrail keys seen: `sexual`, `selfharm`, `violence_and_threats`, `hate_and_discrimination`, `jailbreaking`). `mistral-moderation-2411` deprecated March 31, 2026. **Discrepancy noted — treat exact key set as model-version dependent; verify against live response before encoding in policy.**
- **Guardrails parameter (current)** — on `POST /v1/chat/completions` and `POST /v1/conversations` / agents: `guardrails` list with `moderation_llm_v2` config: `custom_category_thresholds` (e.g. `sexual: 0.1`), `ignore_other_categories`, `action: "block"`, `block_on_error: true`. Passing → response `guardrails.moderation_llm_v2.action: "pass"` with per-category `score`/`violated`; blocked → HTTP **403** "Content blocked by guardrail"; evaluation error with `block_on_error` → code `3201`, `invalid_request_error`.
- **`safe_prompt`** — https://docs.mistral.ai/deprecated/guardrailing/safe_prompt — boolean on chat completions; **deprecated** ("We recommend using Custom Guardrails instead"); when true prepends the system prompt: "Always assist with care, respect, and truth. Respond with utmost utility yet securely. Avoid harmful, unethical, prejudiced, or negative content. Ensure replies promote fairness and positivity." Example (from /usage/guardrailing): POST `https://api.mistral.ai/v1/chat/completions` with `"model": "mistral-large-latest"`, one user message, `"safe_prompt": true`. Default value not stated on page (**UNVERIFIED** default; historically false).
- System-level guardrail cookbook: https://docs.mistral.ai/resources/cookbooks/mistral-moderation-system-level-guardrails.

### 2.4 Compliance

- https://help.mistral.ai/en/articles/323772-do-you-have-soc2-or-iso27001-certification (Aug 12, 2026): "complies with both SOC 2 Type II" and "ISO 27001/27701 frameworks"; reports via https://trust.mistral.ai/resources.
- https://help.mistral.ai/en/articles/156208-... (undated) still says ISO 27001/SOC 2 audits "in the process of undergoing" — older text; the Aug 2026 article supersedes.
- https://trust.mistral.ai — gated (renders only metadata without JS/login); certification tiles **UNVERIFIED**. **UNVERIFIED:** ISO 42001, HDS, CSA STAR.
- GDPR: Privacy Policy and Commercial Terms §12.1 reference Regulation (EU) 2016/679; DPA at legal.mistral.ai.
- **EU AI Act GPAI Code of Practice signatory status — UNVERIFIED on vendor site.** Searches of mistral.ai returned no first-party page; third-party reports (July 2025) say Mistral backed/signed the Code. Legal Center metadata describes itself as a resource for "compliance with the EU AI Act".
- Model documentation: model cards exist per model on docs.mistral.ai/models (not individually verified the 13 Oct 2026 verification pass).

### 2.5 Terraform

- **No official Mistral provider found on registry.terraform.io** via search (results returned only unrelated providers). **UNVERIFIED:** existence of any community provider; registry could not be fetched directly in.

### 2.6 Verbatim snippets usable in the repo

```bash
# Moderation (raw text)
curl https://api.mistral.ai/v1/moderations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $MISTRAL_API_KEY" \
  -d '{"model": "mistral-moderation-latest", "input": ["...text to check..."]}'
# -> {"id": "...", "model": "mistral-moderation-latest", "results": [{"categories": {"sexual": false, "hate_and_discrimination": false, "violence_and_threats": true, "dangerous_and_criminal_content": false, "selfharm": false, "health": false, "financial": false, "law": false, "pii": false}, "category_scores": {...}}]}

# Chat completion with (deprecated) safe_prompt
curl https://api.mistral.ai/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $MISTRAL_API_KEY" \
  -d '{"model": "mistral-large-latest", "messages": [{"role": "user", "content": "What is the best French cheese?"}], "safe_prompt": true}'

# Admin API
curl "https://api.mistral.ai/v1/admin/users?page=1&page_size=50" -H "x-api-key: $ADMIN_API_KEY"
```
(The moderation response above is reconstructed from the documented field list; numeric scores omitted. The request shapes are as documented.)
