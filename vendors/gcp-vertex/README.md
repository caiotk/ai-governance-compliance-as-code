# Google Cloud Vertex AI vendor pack

Google's docs now call Vertex AI **Gemini Enterprise Agent Platform**. The API is still `aiplatform.googleapis.com`.

**Verified as of 2026-10-13** against these sources:

- Google Cloud documentation
- The `hashicorp/google` provider schema (v8.6.0, from `terraform providers schema -json`)
- The Model Armor v1 REST discovery document
- The gcloud SDK's Org Policy v2 and Cloud Resource Manager v1 message types

Sources are listed in `mapping.yaml` (native_tools and attestations) and in docs/SOURCES.md.

## Purpose

This pack sets a secure-by-default governance baseline for generative AI on Google Cloud:

- **Organization policies**: an approved-model allow-list, resource locations, required CMEK, and no Grounding with Google Search.
- A **Model Armor floor setting** that screens all Vertex AI `generateContent` traffic, plus a per-request template.
- **Data Access audit logs** for Vertex AI. Google leaves them off by default.
- An optional **VPC Service Controls** perimeter.

Every resource carries its control IDs (`# AIG-xx`) in a comment. The same IDs appear in [`mapping.yaml`](mapping.yaml).

## What is enforced

| Control | Mechanism | Terraform | Native |
|---|---|---|---|
| AIG-05 Personal data | Model Armor Sensitive Data Protection basic config (`sdp_settings.basic_config` ENABLED), in both the floor setting and the template. | `terraform/model_armor.tf` | `native/model-armor-floor-setting.json` |
| AIG-06 Approved models | `constraints/vertexai.allowedModels`, with allowed values in `publishers/PUBLISHER/models/MODEL:ACTION` format (`predict`, `deploy` or `tune`). `constraints/vertexai.allowedPartnerModelFeatures` is left at Google's default, which blocks partner `web_search` and `structured_outputs`. | `terraform/org_policies.tf` `google_org_policy_policy.vertexai_allowed_models` | `native/org-policies/vertexai.allowedModels.yaml` |
| AIG-07 Least privilege | The Vertex AI service agent gets only `roles/modelarmor.user`. | `model_armor.tf` `google_project_iam_member.vertex_agent_model_armor_user` | `native/apply-model-armor.sh` |
| AIG-08 Residency and network | `constraints/gcp.resourceLocations` (no default — set the value group for your residency requirement; applies to every location-bound service under policy_parent). Optional VPC-SC perimeter restricting `aiplatform.googleapis.com` and `modelarmor.googleapis.com`, with a dry-run option. | `org_policies.tf`, `terraform/network.tf` | `native/org-policies/gcp.resourceLocations.yaml` |
| AIG-09 CMEK | `constraints/gcp.restrictNonCmekServices` with `denied_values = ["aiplatform.googleapis.com"]`. The constraint lists services that may **not** create resources without CMEK, so denying Vertex AI makes CMEK mandatory for it. | `org_policies.tf` `google_org_policy_policy.require_cmek_vertex` | `native/org-policies/gcp.restrictNonCmekServices.yaml` |
| AIG-10 Runtime guardrails | Model Armor floor setting:<br>• HATE_SPEECH, HARASSMENT, SEXUALLY_EXPLICIT and DANGEROUS at MEDIUM_AND_ABOVE.<br>• Prompt-injection and jailbreak filter ENABLED.<br>• Malicious URI filter ENABLED.<br>• `enable_floor_setting_enforcement = true`, `integrated_services = ["AI_PLATFORM"]`, `ai_platform_floor_setting { inspect_and_block = true, enable_cloud_logging = true }`.<br>A per-request `google_model_armor_template` carries the same filters. `vertexai.disableGenAIGoogleSearchGrounding` is enforced. | `model_armor.tf`, `org_policies.tf` | `native/model-armor-floor-setting.json`, `native/apply-model-armor.sh` |
| AIG-13 Logging | `google_project_iam_audit_config` turns on DATA_READ and DATA_WRITE for `aiplatform.googleapis.com`. Model Armor filter results go to Cloud Logging. | `terraform/logging.tf` | `native/audit-config.yaml`, `native/apply-audit-config.sh` |
| AIG-18 Cross-border | Location restriction, the perimeter, and no Google Search grounding. | `org_policies.tf`, `network.tf` | `native/org-policies/*.yaml` |

### Why the floor setting is the central control

Gemini safety filters (`safetySettings`) are set **per request**, and no org policy controls them. For `gemini-3.5-flash` and later models, the default threshold is `OFF`.

A Model Armor floor setting with `integratedServices: ["AI_PLATFORM"]` screens Gemini `generateContent` calls project-wide, whatever the caller sends. Applications should still set explicit safety thresholds as defence in depth.

## How to apply

### Prerequisites and permissions

- **Terraform** >= 1.6 and `hashicorp/google` `~> 8.6`. The provider uses `project_id` as the billing/quota project for org- and folder-level APIs.
- **Organization policies**: `roles/orgpolicy.policyAdmin` on `policy_parent` (`organizations/ID`, `folders/ID` or `projects/ID`). Setting them at organization or folder level is recommended.
- **Model Armor**:
  - Grant `roles/modelarmor.floorSettingsAdmin` on the floor-setting parent.
  - Template creation needs Model Armor admin on the project.
  - Enable the Model Armor API. The pack enables `modelarmor.googleapis.com` in `project_id`.
  - Granting `roles/modelarmor.user` to `service-PROJECT_NUMBER@gcp-sa-aiplatform.iam.gserviceaccount.com` requires that the service agent already exists, which happens once the Vertex AI API has been used in the project.
- **Audit config**: `resourcemanager.projects.setIamPolicy` on the project.
- **VPC-SC**:
  - Grant `roles/accesscontextmanager.policyAdmin` on the access policy.
  - Set `access_policy_name = "accessPolicies/NUMBER"`.
  - Roll out with `perimeter_dry_run = true` first, then set it to `false`.
- **CMEK**: before you enforce `restrictNonCmekServices`, create Cloud KMS keys in every allowed location and grant the Vertex AI service agent `roles/cloudkms.cryptoKeyEncrypterDecrypter`. Without them, new Vertex AI resources cannot be created.

### Terraform

```bash
cd vendors/gcp-vertex/terraform
cp terraform.tfvars.example terraform.tfvars   # replace placeholders
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

`allowed_models` refuses an empty list. With no policy, every model is allowed.

### Native (gcloud and REST)

```bash
cd vendors/gcp-vertex/native

# 1. Organization policies (edit org-policies/*.yaml first)
PARENT=organizations/123456789012 DRY_RUN=1 ./apply-org-policies.sh   # preview
PARENT=organizations/123456789012 ./apply-org-policies.sh             # gcloud org-policies set-policy

# 2. Model Armor floor setting (PATCH {parent}/locations/global/floorSetting) + service agent role
PROJECT_ID=my-vertex-project ./apply-model-armor.sh

# 3. Data Access audit logs (get-iam-policy -> merge auditConfigs -> set-iam-policy)
PROJECT_ID=my-vertex-project ./apply-audit-config.sh
```

Org-policy files use the list form (`rules: - values: allowedValues: [...]`) that `gcloud org-policies set-policy` accepts. They were checked against the gcloud SDK's `GoogleCloudOrgpolicyV2Policy` message type.

`audit-config.yaml` is a **fragment**, not a complete policy. `gcloud projects set-iam-policy` always overwrites `bindings` and `etag`, so the script merges the fragment into the live policy instead of applying it directly.

Floor-setting REST URL pattern:

```
PATCH https://modelarmor.googleapis.com/v1/{parent}/locations/global/floorSetting
      parent = projects/PROJECT_ID | folders/FOLDER_ID | organizations/ORGANIZATION_ID
```

The equivalent gcloud command is:

```
gcloud model-armor floorsettings update --full-uri=projects/PROJECT_ID/locations/global/floorSetting \
  --add-integrated-services=VERTEX_AI --vertex-ai-enforcement-type=INSPECT_AND_BLOCK ...
```

The gcloud flag value is `VERTEX_AI`; the REST enum is `AI_PLATFORM`. **UNVERIFIED:** the gcloud flag names above were not confirmed against the gcloud reference; `native/apply-model-armor.sh` uses the REST API instead.

## Unverified / known gaps

- **Model Armor endpoint host.** The global host `modelarmor.googleapis.com` comes from Google's floor-settings and Vertex-integration pages. It is **UNVERIFIED** in the pack's research file, and the v1 discovery document lists only regional `modelarmor.<region>.rep.googleapis.com` endpoints. `apply-model-armor.sh` accepts a `MODEL_ARMOR_ENDPOINT` override.
- **Data Access logs for `generateContent`.** It is **UNVERIFIED** whether publisher-model `generateContent` calls emit Data Access audit logs. The audit-logging page lists `endpoints.predict`, `rawPredict`, `explain`, `ragFiles.get` and `memories.retrieve`. Until this is confirmed, use Model Armor Cloud Logging and application logs as prompt-level evidence.
- **Model Armor's own Data Access logs.** Not verified, so `modelarmor.googleapis.com` is not in the default audit-config list.
- **Location of inference.** It is **UNVERIFIED** whether `gcp.resourceLocations` constrains where inference on publisher models is processed, for example through the global endpoint. The constraint governs where resources are created. Pin regional endpoints in clients.
- **Floor-setting parent.** The Vertex AI integration page says to set Vertex floor settings **at project level**, so the default parent is `projects/<project_id>`. The API and the Terraform resource also accept folders and organizations, but behaviour for `AI_PLATFORM` at those levels is not documented.
- **Floor-setting coverage.**
  - It covers `generateContent` only.
  - Documents and file uploads (PDFs) are not screened.
  - If Model Armor is unavailable in a Region, unreachable, or returns an internal error, requests **proceed unscreened**.
  - Per-request templates must exist in the Region the request is routed to.
- **`vertexai.allowedModels` scope.** It covers Model Garden only, not Model Registry. Each model must be listed individually, with no wildcards and at most 500 values.
- **Assured Workloads constraints.** The `vertexai.allowOnly*CompliantAPIs` constraints are set by Assured Workloads and must not be configured here.
- **AIG-02 inventory.** Not covered. Security Command Center AI Protection provides an AI asset inventory and the "Google Recommended AI Essentials - Gemini Enterprise Agent Platform" framework. The SCC Enterprise tier shuts down on 2027-05-21.
