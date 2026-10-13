# Cloud vendor AI governance controls: verified reference

Research date: 2026-10-13. I checked every fact against vendor documentation or the vendor's own source repositories:

- learn.microsoft.com
- docs.aws.amazon.com and aws.amazon.com
- docs.cloud.google.com and cloud.google.com
- github.com/Azure/azure-policy
- github.com/hashicorp provider repos
- github.com/microsoft/terraform-provider-power-platform

Anything I could not verify is marked **UNVERIFIED:**.

**Provider doc snapshots used.** Docs came from the default branch on 2026-10-12/13. These are the latest release tags at that point:

| Provider | Latest tag |
|---|---|
| hashicorp/azurerm | v5.9.0 |
| hashicorp/aws | v6.68.0 |
| hashicorp/google | v8.6.0 |
| microsoft/power-platform | v4.2.0 |

Argument names come from the docs on `main`. Pin a provider version and re-check before you depend on a newly added argument.

**Renames to be aware of.** Microsoft docs now say "Microsoft Foundry" where they used to say "Azure AI Foundry". Google docs now call Vertex AI "Gemini Enterprise Agent Platform (formerly Vertex AI Platform)". The API names have not changed: `Microsoft.CognitiveServices` and `aiplatform.googleapis.com`.

---

## 1. Microsoft Foundry / Azure OpenAI / Azure AI services

### 1.1 Built-in Azure Policy definitions

Source: [Azure Policy built-in definitions](https://learn.microsoft.com/en-us/azure/governance/policy/samples/built-in-policies), in the "Azure AI Services" and "Cognitive Services" categories. I cross-checked each GUID against the policy JSON in [Azure/azure-policy built-in-policies/policyDefinitions](https://github.com/Azure/azure-policy/tree/master/built-in-policies/policyDefinitions). The definition ID format is `/providers/Microsoft.Authorization/policyDefinitions/<GUID>`.

**Category "Azure AI Services"**

These policies cover both `Microsoft.CognitiveServices/accounts` and `Microsoft.Search/searchServices`.

| Display name (exact) | GUID | Effects | Version |
|---|---|---|---|
| Azure AI Services resources should have key access disabled (disable local authentication) | `71ef260a-8f18-47b7-abcb-62d0673d94dc` | Audit, Deny, Disabled | 1.1.0 |
| Azure AI Services resources should restrict network access | `037eea7a-bd0a-46c5-9a66-03aea78705d3` | Audit, Deny, Disabled | 3.3.0 |
| Azure AI Services resources should use Azure Private Link | `d6759c02-b87f-42b7-892e-71b3f471d782` | Audit, Disabled | 1.0.0 |
| Configure Azure AI Services resources to disable local key access (disable local authentication) | `55eff01b-f2bd-4c32-9203-db285f709d30` | DeployIfNotExists, Disabled | 1.0.0 |
| Configure Azure AI Services resources  to disable local key access (disable local authentication) | `d45520cb-31ca-44ba-8da2-fcf914608544` | DeployIfNotExists, Disabled | 1.0.0 |
| Diagnostic logs in Azure AI services resources should be enabled | `1b4d1c4e-934c-4703-944c-27c82c06bebb` | AuditIfNotExists, Disabled | 1.0.0 |

Notes on this table:
- The second "Configure…" policy (`d45520cb…`) has a double space in its display name in the source. Its file is `DisableLocalAuth_Search_DINE.json`, so it targets AI Search. The cognitive-accounts variant is `55eff01b…`.
- The "restrict network access" policy evaluates `networkAcls.defaultAction` and `publicNetworkAccess`.

**Category "Cognitive Services"**

| Display name (exact) | GUID | Effects | Version |
|---|---|---|---|
| Foundry model deployments should only use approved models | `aafe3651-cb78-4f68-9f81-e7e41509110f` | Audit, Deny, Disabled | 1.0.2 |
| [Preview]: Foundry model deployments should meet eligibility requirements | `8791d062-ba96-4c34-b604-8538f7e30ca0` | Audit, Deny, Disabled | 1.0.0-preview |
| Azure AI Services resources should encrypt data at rest with a customer-managed key (CMK) | `67121cc7-ff39-4ab8-b7e3-95b84dab487d` | Audit, Deny, Disabled | 2.2.0 |
| Cognitive Services accounts should use a managed identity | `fe3fd216-4f83-4fc1-8984-2bbec80a3418` | Audit, Deny, Disabled | 1.0.0 |
| Cognitive Services accounts should use customer owned storage | `46aa9b05-0e60-4eae-a88b-1e9d374fa515` | Audit, Deny, Disabled | 2.0.0 |
| Configure Cognitive Services accounts to disable local authentication methods | `14de9e63-1b31-492e-a5a3-c3f7fd57f555` | Modify, Disabled | 1.0.0 |
| Configure Cognitive Services accounts to disable public network access | `47ba1dd7-28d9-4b07-a8d5-9813bed64e0c` | Disabled, Modify | 3.0.0 |
| Configure Cognitive Services accounts to use private DNS zones | `c4bc6f10-cb41-49eb-b000-d5ab82e2a091` | DeployIfNotExists, Disabled | 1.0.0 |
| Configure Cognitive Services accounts with private endpoints | `db630ad5-52e9-4f4d-9c44-53912fe40053` | DeployIfNotExists, Disabled | 3.0.0 |
| [Preview]: Cognitive Services Deployments should only use allowed prompt content filtering | `f3a9c2e0-7b4d-4d8f-9c3a-2e1f6b9a8d4e` | Audit, Disabled | 1.0.0-preview |
| [Preview]: Cognitive Services Deployments should only use allowed completion content filtering | `af253d37-136a-42f8-a1fc-30010c083d41` | Audit, Disabled | 1.0.0-preview |
| [Preview]: Cognitive Services Deployments should only use allowed control | `930f48f9-f07e-427c-9494-52603581c6a9` | Audit, Disabled | 1.0.0-preview |
| [Preview]: Cognitive Services Deployments Should Only Use Allowed Control Mode | `c1ad46c6-37f8-4af0-9c71-c208375c87dd` | Audit, Disabled | 1.0.0-preview |
| [Preview]: Cognitive Services Agents should only use allowed prompt content filtering | `9224c1cc-34fc-44f1-ad08-5c4b079c9ce6` | Audit, Disabled | 1.0.0-preview |
| [Preview]: Cognitive Services Agents should only use allowed control | `595f98a5-b562-4ab6-b9c8-2ff9f39a3f7c` | Audit, Disabled | 1.0.0-preview |

These old policies are **deprecated**, so do not use them:
- `0725b4dd-7e76-479c-a735-68e7ee23d5ca` "Cognitive Services accounts should disable public network access"
- `cddd188c-4b82-4c48-a19d-ddf74ee66a01` "Cognitive Services should use private link"
- `2bdd0062-…` and `11566b39-…` (encryption)

**Built-in initiative.** "[Preview]: Guardrail for Cognitive Services Deployments", GUID `5207647b-3e83-4e28-b836-c382cb5e2a2e`, version 1.0.0-preview. It bundles the content-filtering and control policies above ([built-in initiatives](https://learn.microsoft.com/en-us/azure/governance/policy/samples/built-in-initiatives)).

**Machine Learning category.** These are relevant to hub-based (classic) Foundry:

| Display name | GUID |
|---|---|
| Azure Machine Learning Workspaces should disable public network access | `438c38d2-3772-465a-a9cc-7a6666a275ce` |
| Azure Machine Learning workspaces should be encrypted with a customer-managed key | `ba769a63-b8cc-4b2d-abf6-ac33c7204be8` |
| Azure Machine Learning Computes should have local authentication methods disabled | `e96a9a5f-07ca-471b-9bc5-6a0f33cbd68f` |
| Azure Machine Learning and Ai Studio should use Allow Only Approved Outbound Managed Vnet mode | `6ddb1705-c8cf-450e-aa4b-19ad6703c440` |
| Resource logs in Azure Machine Learning Workspaces should be enabled | `afe0c3be-ba3b-4544-ba52-0c99672a8ad6` |
| [Preview]: Azure Machine Learning Deployments should only use approved Registry Models | `12e5dd16-d201-47ff-849b-8454061c293d` |

#### The "only approved models" policy (`aafe3651-…`)

- **Mode and target.** Policy mode is `Microsoft.CognitiveServices.Data`. It evaluates `Microsoft.CognitiveServices.Data/accounts/deployments` on the fields `model.publisher` and `model.assetId`. It was previously named "Cognitive Services Deployments should only use approved Registry Models", and the definition ID did not change. Sources: [Built-in policies for model deployment](https://learn.microsoft.com/en-us/azure/ai-foundry/how-to/model-deployment-policy) and the [policy JSON](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Cognitive%20Services/AllowDeployRegistryModels_Audit.json).
- **Parameters.** `effect`, `allowedPublishers` (array) and `allowedAssetIds` (array).
- **Asset ID matching.** Asset IDs match as a prefix, and the match is case-sensitive.
  - A trailing `/` limits the match to that one model.
  - Adding `/versions/N` pins a single version.
- **Model router.** It must be allowed. Allow publisher `Microsoft` for the router itself, plus the publishers of the models it routes to.

Verified parameter file from the Foundry docs:

```json
{
  "effect": { "value": "Deny" },
  "allowedPublishers": { "value": ["OpenAI"] },
  "allowedAssetIds": {
    "value": [
      "azureml://registries/azure-openai/models/gpt-5/",
      "azureml://registries/azure-openai/models/gpt-5.2/versions/1"
    ]
  }
}
```

#### The eligibility policy (`8791d062-…`)

- Parameters: `onlyAllowDirectFromAzure` (bool) and `denyPreviewModels` (bool) ([source](https://learn.microsoft.com/en-us/azure/ai-foundry/how-to/model-deployment-policy)).
- There is a status mismatch. The Foundry doc page calls this policy "Generally available", but the built-in list and the JSON still show `[Preview]` with version 1.0.0-preview.

### 1.2 Regulatory-compliance initiatives for AI

**Azure Policy built-in initiatives** ([built-in initiatives](https://learn.microsoft.com/en-us/azure/governance/policy/samples/built-in-initiatives)):

- **EU AI Act 2024 1689**
  - GUID `1308bccf-446a-4283-a4e0-0c983fe7a572`, version 1.0.1, 6 policies.
  - Members include `1b4d1c4e…` (AI services diagnostic logs) and `d6759c02…` (AI Services Private Link).
  - It also includes Defender for APIs, APIM, and AI Search policies.
  - [JSON](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policySetDefinitions/Regulatory%20Compliance/EU_AI_Act_2024_1689.json)
- **NIST AI RMF v1.0**
  - GUID `f58a876c-ec25-417e-9634-58d2a93e3fe2`, version 1.0.0.
  - It contains only 1 policy (`1b4d1c4e…`).
  - [JSON](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policySetDefinitions/Regulatory%20Compliance/NIST_AI_RMF_v1.0.json)

**Defender for Cloud.** The regulatory compliance standards list includes "European Union Artificial Intelligence Act (EU AI Act)" for Azure, AWS and GCP ([source](https://learn.microsoft.com/en-us/azure/defender-for-cloud/concept-regulatory-compliance-standards)). That page lists **no** ISO/IEC 42001 or NIST AI RMF standard.

**Microsoft Purview Compliance Manager.** The template list includes "ISO/IEC 42001:2023", "ISO/IEC 23894:2023", "EU Artificial Intelligence Act" and "NIST AI Risk Management Framework (RMF) 1.0" ([templates list](https://learn.microsoft.com/en-us/purview/compliance-manager-templates-list)).

### 1.3 Content filters / Responsible AI policy (`raiPolicies`)

**ARM resource type:** `Microsoft.CognitiveServices/accounts/raiPolicies`. Versions listed on the [template reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.cognitiveservices/accounts/raipolicies):
- Latest stable: `2026-07-01`. I confirmed `raiPolicies@2026-07-01` on the [versioned page](https://learn.microsoft.com/en-us/azure/templates/microsoft.cognitiveservices/2026-07-01/accounts/raipolicies).
- Latest preview: `2026-07-15-preview`.
- Other stable versions: `2026-05-01`, `2025-12-01`, `2025-09-01`, `2025-06-01` and `2024-10-01`.

**Bicep properties:**
- `basePolicyName`
- `mode`: `Default` | `Deferred` | `Blocking` | `Asynchronous_filter`
- `contentFilters[]`, each with:
  - `name`, `enabled`, `blocking`
  - `severityThreshold`: `Low` | `Medium` | `High`
  - `source`: `Prompt` | `Completion` (newer versions add `PreRun`, `PostRun`, `PreToolCall` and `PostToolCall`)
  - `action` (newer versions)
- `customBlocklists[]`, each with `blocklistName`, `blocking` and `source`.

**REST sample** ([RAI Policies - Create Or Update](https://learn.microsoft.com/en-us/rest/api/aiservices/accountmanagement/rai-policies/create-or-update), api-version `2024-10-01`), abridged:

```json
{
  "properties": {
    "basePolicyName": "Microsoft.Default",
    "mode": "Asynchronous_filter",
    "contentFilters": [
      { "name": "Hate", "blocking": true, "enabled": true, "severityThreshold": "Medium", "source": "Completion" },
      { "name": "Jailbreak", "blocking": true, "source": "Prompt", "enabled": true },
      { "name": "Protected Material Text", "blocking": true, "source": "Completion", "enabled": true },
      { "name": "Protected Material Code", "blocking": true, "source": "Completion", "enabled": true }
    ]
  }
}
```

The sample's filter names are `Hate`, `Sexual`, `Selfharm`, `Violence`, `Jailbreak`, `Protected Material Text`, `Protected Material Code` and `Profanity`. The azurerm docs also mention an `Indirect Attack` filter name. **UNVERIFIED:** `Microsoft.DefaultV2` as a `basePolicyName` value. It does not appear in the sample.

**Terraform.** `azurerm_cognitive_account_rai_policy` exists ([doc](https://github.com/hashicorp/terraform-provider-azurerm/blob/main/website/docs/r/cognitive_account_rai_policy.html.markdown)). Its arguments:
- `name`, `cognitive_account_id`, `base_policy_name`
- `content_filter { name, filter_enabled, block_enabled, severity_threshold, source }`
- `mode`: `Default` | `Deferred` | `Blocking` | `Asynchronous_filter`
- `tags`

Related resource: `azurerm_cognitive_account_rai_blocklist`. To attach a policy, use the `rai_policy_name` argument on `azurerm_cognitive_deployment`.

```hcl
resource "azurerm_cognitive_account_rai_policy" "example" {
  name                 = "example-rai-policy"
  cognitive_account_id = azurerm_cognitive_account.example.id
  base_policy_name     = "Microsoft.Default"
  content_filter {
    name               = "Hate"
    filter_enabled     = true
    block_enabled      = true
    severity_threshold = "High"
    source             = "Prompt"
  }
}
```

### 1.4 Defender for Cloud: threat protection for AI services

- **Plan names.** The plan is "threat protection for AI services", also called the "Defender for AI Services plan". In the portal it is the **AI services** toggle under Environment settings, then Defender plans. Optional settings are "Enable user prompt evidence" and "Enable data security for AI interactions"; the latter needs a separate Purview license ([enable](https://learn.microsoft.com/en-us/azure/defender-for-cloud/ai-onboarding)).
- **Coverage.** It is GA in commercial clouds. It covers Azure OpenAI and Azure AI Model Inference supported models, and scans text tokens only. The free trial runs 30 days with a cap of 75B tokens ([overview](https://learn.microsoft.com/en-us/azure/defender-for-cloud/ai-threat-protection)).
- **Terraform.** Use `azurerm_security_center_subscription_pricing` with `resource_type = "AI"`. Valid `tier` values are `Free` and `Standard`. There is an optional `subplan` and `extension { name, additional_extension_properties }` ([doc](https://github.com/hashicorp/terraform-provider-azurerm/blob/main/website/docs/r/security_center_subscription_pricing.html.markdown)).
- **ARM.** `Microsoft.Security/pricings` with `pricingTier` set to `Free` | `Standard`. The latest version is `2025-10-01-preview`; `2024-01-01` is a stable version. The extension `AIPromptEvidence` is documented ("Exposes the prompts passed between the user and the AI model as alert evidence") ([template ref](https://learn.microsoft.com/en-us/azure/templates/microsoft.security/pricings)). The pricing resource name equals the plan name, `AI`, matching the Terraform import path `/providers/Microsoft.Security/pricings/<resource_type>`.

```hcl
resource "azurerm_security_center_subscription_pricing" "ai" {
  tier          = "Standard"
  resource_type = "AI"
  # UNVERIFIED: whether extension { name = "AIPromptEvidence" } is accepted by the azurerm provider for resource_type AI
}
```

### 1.5 Microsoft Purview DSPM for AI

Source: [Purview for AI](https://learn.microsoft.com/en-us/purview/ai-microsoft-purview).

**What it is.** It is the "front door" for discovering, securing and applying compliance controls to AI usage.

**What it governs:**
- **Copilot experiences and agents:** Microsoft 365 Copilot and Microsoft 365 Copilot Chat, Security Copilot, Copilot in Fabric, **Microsoft Copilot Studio**, and others.
- **Enterprise AI apps:** **Microsoft Foundry**, Entra-registered AI apps, ChatGPT Enterprise and Anthropic Claude (Enterprise).
- **Other AI apps,** detected through browser activity: ChatGPT, Gemini, DeepSeek and others.

**Capabilities:**
- Sensitivity labels
- DLP, including Endpoint DLP for generative AI sites
- Insider Risk Management ("Risky AI usage" template)
- Audit (the "AI activities" tab)
- Communication compliance
- eDiscovery
- Retention of prompts and responses
- Compliance Manager "Assessments for AI regulations"

**Limits.** Purview integration does **not** include data from Foundry agents. Policies apply only to Entra ID user-context calls ([Defender onboarding note](https://learn.microsoft.com/en-us/azure/defender-for-cloud/ai-onboarding)).

### 1.6 Terraform azurerm resources

All are verified in the provider docs (main branch, 2026-10-12). The provider uses API `Microsoft.CognitiveServices 2026-03-01`.

**`azurerm_cognitive_account`** ([doc](https://github.com/hashicorp/terraform-provider-azurerm/blob/main/website/docs/r/cognitive_account.html.markdown)):

| Argument | Detail |
|---|---|
| `kind` | Includes `AIServices`, `OpenAI` and `ContentSafety` |
| `local_auth_enabled` | Defaults to `true` |
| `public_network_access_enabled` | Defaults to `true` |
| `network_acls { default_action, bypass, ip_rules, virtual_network_rules }` | Requires `custom_subdomain_name` |
| `customer_managed_key { key_vault_key_id, identity_client_id }` | |
| `identity` | |
| `outbound_network_access_restricted` | |
| `fqdns` | |
| `project_management_enabled` | `AIServices` only |
| `network_injection` | |

There is also a standalone `azurerm_cognitive_account_customer_managed_key` resource.

**`azurerm_cognitive_deployment`.** Arguments: `cognitive_account_id`, `model { format, name, version }`, `sku { name, capacity }`, `rai_policy_name` and `version_upgrade_option` ([doc](https://github.com/hashicorp/terraform-provider-azurerm/blob/main/website/docs/r/cognitive_deployment.html.markdown)).

**Foundry resources:**
- `azurerm_ai_foundry` and `azurerm_ai_foundry_project` both exist. They manage a "Microsoft Foundry **Hub (classic)**" and its project. They are ML-workspace-based and support `public_network_access`, `managed_network { isolation_mode }` and `encryption`.
- New (non-hub) Foundry projects use **`azurerm_cognitive_account_project`**, with `cognitive_account_id`, `location` and `identity`. Set it on an `AIServices` account with `project_management_enabled = true`.

**Policy resources:**
- `azurerm_policy_definition`: `policy_type`, `mode`, `policy_rule`, `parameters`, `management_group_id`. **Note:** the documented `mode` list does not include `Microsoft.CognitiveServices.Data`. **UNVERIFIED:** whether custom definitions can use that mode.
- `azurerm_subscription_policy_assignment` and `azurerm_management_group_policy_assignment`: `policy_definition_id`, `subscription_id` / `management_group_id`, `parameters`, `enforce`, `identity`, `location` and `non_compliance_message`.

**`azurerm_monitor_diagnostic_setting`.** Arguments: `target_resource_id`, `log_analytics_workspace_id`, `enabled_log { category | category_group }` and `enabled_metric { category }`.

### 1.7 Bicep resource types and API versions

Source: the template reference pages at learn.microsoft.com/azure/templates.

| Resource type | Latest stable (verified) | Latest preview |
|---|---|---|
| `Microsoft.CognitiveServices/accounts` | `2026-07-01` | `2026-07-15-preview` |
| `Microsoft.CognitiveServices/accounts/deployments` | `2026-07-01` | `2026-07-15-preview` |
| `Microsoft.CognitiveServices/accounts/projects` | `2026-07-01` | `2026-07-15-preview` |
| `Microsoft.CognitiveServices/accounts/raiPolicies` | `2026-07-01` | `2026-07-15-preview` |
| `Microsoft.MachineLearningServices/workspaces` (classic hub) | `2026-07-01` | `2026-07-15-preview` |
| `Microsoft.Security/pricings` | `2024-01-01` | `2025-10-01-preview` |
| `Microsoft.Insights/diagnosticSettings` | n/a | `2021-05-01-preview` (latest shown) |
| `Microsoft.Authorization/policyDefinitions` | `2026-07-01` | |
| `Microsoft.Authorization/policyAssignments` | `2026-07-01` (`2025-03-01` also present) | |

Bicep property names on `Microsoft.CognitiveServices/accounts`:
- `properties.disableLocalAuth`
- `properties.publicNetworkAccess`: `Enabled` | `Disabled`
- `properties.networkAcls.{defaultAction, bypass, ipRules[].value, virtualNetworkRules[]}`
- `properties.encryption.{keySource: 'Microsoft.KeyVault', keyVaultProperties.{keyName, keyVaultUri, keyVersion, identityClientId}}`
- `properties.restrictOutboundNetworkAccess`
- `properties.allowProjectManagement`
- `identity` (at the top level, not under `properties`)

Source: [accounts template ref](https://learn.microsoft.com/en-us/azure/templates/microsoft.cognitiveservices/accounts).

```bicep
resource ai 'Microsoft.CognitiveServices/accounts@2026-07-01' = {
  name: 'contoso-ai'
  location: location
  kind: 'AIServices'
  sku: { name: 'S0' }
  identity: { type: 'SystemAssigned' }
  properties: {
    customSubDomainName: 'contoso-ai'
    disableLocalAuth: true
    publicNetworkAccess: 'Disabled'
    networkAcls: { defaultAction: 'Deny' }
    allowProjectManagement: true
  }
}
```

The `kind` and `sku` values and the `customSubDomainName` name in this snippet come from the azurerm docs and general ARM knowledge. Validate them against the template reference before use.

### 1.8 Microsoft AI compliance and attestations

- **ISO/IEC 42001.** The in-scope services include Microsoft Foundry, Microsoft Copilot Studio, Microsoft Copilot / Copilot Chat, Security Copilot, GitHub Copilot and Dragon Copilot ([offering page](https://learn.microsoft.com/en-us/compliance/regulatory/offering-iso-42001)). Certificates and audit reports are on the [Service Trust Portal](https://servicetrust.microsoft.com/viewpage/ISOIEC). The offering page does not name the certification body.
- **Announcement blog.** "Microsoft Azure AI Foundry Models and Microsoft Security Copilot achieve ISO/IEC 42001:2023 certification" ([azure.microsoft.com blog](https://azure.microsoft.com/en-us/blog/microsoft-azure-ai-foundry-models-and-microsoft-security-copilot-achieve-iso-iec-420012023-certification/)). I did not open this page; I only saw it in search results.

---

## 2. Microsoft Copilot Studio / Power Platform

### 2.1 Data policies (DLP) and Copilot Studio

Source: [Configure data policies for agents](https://learn.microsoft.com/en-us/microsoft-copilot-studio/admin-data-loss-prevention).

**Data groups.** The three groups are **Business**, **Non-business** and **Blocked**. Connectors in different groups cannot share data. Newer connectors usually default to Non-business.

**Enforcement.**
- Enforcement has applied to all tenants since early 2025 (MC973179). Agent exemptions are no longer supported.
- Enforcement is real-time. When a violation occurs, the **Publish** button is disabled.
- Blocking Power Platform connectors also blocks tools in connected MCP servers.

**Copilot Studio connectors that data policies can govern** (exact admin center names):
- Application Insights in Copilot Studio
- **Chat without Microsoft Entra ID authentication in Copilot Studio** (blocking this enforces authentication)
- **HTTP** (supports endpoint filtering)
- Knowledge source with documents in Copilot Studio
- Knowledge source with public websites and data in Copilot Studio (supports endpoint filtering)
- Knowledge source with SharePoint and OneDrive in Copilot Studio (supports endpoint filtering)
- Direct Line channels in Copilot Studio
- Omnichannel in Copilot Studio
- Facebook channel in Copilot Studio
- SharePoint channel in Copilot Studio
- Microsoft Teams + Microsoft 365 Channel in Copilot Studio
- WhatsApp channel in Copilot Studio
- Microsoft Copilot Studio (event triggers and automated evaluations)
- Skills with Copilot Studio
- Prebuilt and custom connectors used as tools

**Error-message settings.** Configure them with the cmdlets `New-PowerAppDlpErrorSettings` and `Set-PowerAppDlpErrorSettings`.

### 2.2 Other governance controls

**Managed Environments: agent sharing rules** ([sharing limits](https://learn.microsoft.com/en-us/power-platform/admin/managed-environment-sharing-limits)):
- "Let people grant Editor permissions when agents are shared"
- "Let people grant Viewer permissions when agents are shared"
- "Only share with individuals (no security groups)"
- "Limit number of viewers who can access each agent"
- PowerShell extended settings: `bot-limitSharingMode` (`ExcludeSharingToSecurityGroups`), `bot-maxLimitUserSharing` and `bot-authoringSharingDisabled`.

**Controls listed on Copilot Studio's [security and governance page](https://learn.microsoft.com/en-us/microsoft-copilot-studio/security-and-governance):**
- Data policy controls
- Environment routing
- Maker welcome message
- CMK
- Makers audit logs in Microsoft Purview
- Audit logs in Microsoft Sentinel
- Real-time risk assessment
- Maker security warning
- Agent runtime protection status
- "Microsoft Entra network controls (via Agent 365)"
- Disable agent publishing
- Disable data movement across geographic locations
- Customer Lockbox

**Purview audit** ([logging](https://learn.microsoft.com/en-us/microsoft-copilot-studio/admin-logging-copilot-studio)):
- Logging is on by default and cannot be disabled.
- Authoring operations include `BotCreate`, `BotDelete`, `BotUpdateOperation-BotPublish`, `BotUpdateOperation-BotShare`, `BotComponentCreate` and `AIPluginOperationUpdate`.
- Usage is logged as `CopilotInteraction`.
- Audit keeps only the transcript thread ID; DSPM for AI holds the chat text.
- **UNVERIFIED:** the Purview RecordType name for these events.

**Tenant isolation** ([cross-tenant restrictions](https://learn.microsoft.com/en-us/power-platform/admin/cross-tenant-restrictions)):
- It blocks inbound and outbound cross-tenant connections for Entra-authenticated connectors. It is **Off** by default.
- The page names canvas apps and Power Automate flows. **UNVERIFIED:** whether it applies explicitly to Copilot Studio.

**Agent inventory** ([admin-agent-inventory](https://learn.microsoft.com/en-us/microsoft-copilot-studio/admin-agent-inventory)):
- Covers agents built in Copilot Studio and Agent Builder.
- Access paths are the Power Platform admin center, the Power Platform API and Azure Resource Graph.
- Fields include `properties.entraAgentId` and `properties.authentication`.
- Core fields are GA; configuration and quarantine fields are Preview.

**Microsoft Entra Agent ID** ([overview](https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/microsoft-entra-agent-identities-for-ai-agents)):
- It is an identity and security framework for AI agents, "available for all Microsoft Entra customers".
- Extending Entra security features to agents requires **Microsoft Agent 365**. That is included in M365 E7, or available as an add-on to E5/A5/Business Premium.
- **UNVERIFIED:** whether Copilot Studio or Foundry create agent identities automatically. The page does not say.

### 2.3 Terraform provider `microsoft/power-platform`

Source: the registry name `source = "microsoft/power-platform"`; the latest tag is v4.2.0 ([docs](https://github.com/microsoft/terraform-provider-power-platform/tree/main/docs)). These are the verified resource names.

**`powerplatform_data_loss_prevention_policy`:**
- Required: `display_name`, `default_connectors_classification` (`"General"` | `"Confidential"` | `"Blocked"`), `environment_type` (`"AllEnvironments"` | `"ExceptEnvironments"` | `"OnlyEnvironments"`), `business_connectors`, `non_business_connectors`, `blocked_connectors` and `custom_connectors_patterns`.
- Optional: `environments`.
- Connector object: `{ id, default_action_rule_behavior, action_rules[{action_id, behavior}], endpoint_rules[{behavior, endpoint, order}] }`.
- Custom pattern object: `{ order, host_url_pattern, data_group: "Business"|"NonBusiness"|"Blocked"|"Ignore" }`.

**`powerplatform_managed_environment`:**
- `environment_id`, `is_usage_insights_disabled`, `is_group_sharing_disabled`, `limit_sharing_mode`, `max_limit_user_sharing`
- `solution_checker_mode`, `suppress_validation_emails`, `solution_checker_rule_overrides`
- Agent sharing controls: **`copilot_allow_grant_editor_permissions_when_shared`**, **`copilot_limit_sharing_mode`** and **`copilot_max_limit_user_sharing`**
- `power_automate_is_sharing_disabled`

**`powerplatform_environment`:**
- `display_name`, `location` / `macro_region`, `azure_region`, `environment_type`, `dataverse { … }`, `environment_group_id`
- AI-relevant settings: `allow_bing_search`, `allow_moving_data_across_regions`, `allow_flex_routing` and `allow_microsoft_365_services`

**`powerplatform_environment_group` and `powerplatform_environment_group_rule_set`:**
- Rules include `sharing_controls`, `usage_insights`, `maker_welcome_content`, `solution_checker_enforcement`, `backup_retention`, `ai_generated_descriptions`, `ai_generative_settings { move_data_across_regions_enabled, bing_search_enabled }`, `advanced_connector_policies` and `content_security_policy`.

**`powerplatform_tenant_settings`:**
- Includes `power_platform.intelligence { disable_copilot, enable_open_ai_bot_publishing (deprecated) }` and `power_platform.governance { enable_default_environment_routing, environment_routing_* }`.

**`powerplatform_tenant_isolation_policy`:**
- `is_disabled`, `allowed_tenants[{ tenant_id, inbound, outbound }]`

**`powerplatform_copilot_studio_application_insights`** (preview):
- `environment_id`, `bot_id`, `application_insights_connection_string`, `include_sensitive_information`, `include_activities`, `include_actions`

**Other resources:** `powerplatform_enterprise_policy`, `powerplatform_environment_settings` and `powerplatform_rest`.

**There is no** `powerplatform_tenant_settings`-style resource for Copilot Studio DLP beyond the DLP policy resource. Copilot Studio connectors are governed by putting their connector IDs into the DLP connector groups.

```hcl
resource "powerplatform_data_loss_prevention_policy" "agents" {
  display_name                      = "Agent baseline"
  default_connectors_classification = "Blocked"
  environment_type                  = "AllEnvironments"
  environments                      = []
  business_connectors     = local.business_connectors
  non_business_connectors = local.non_business_connectors
  blocked_connectors      = local.blocked_connectors
  custom_connectors_patterns = toset([
    { order = 1, host_url_pattern = "*", data_group = "Blocked" }
  ])
}
```

**UNVERIFIED:** the exact connector IDs (`/providers/Microsoft.PowerApps/apis/shared_…`) for the Copilot Studio connectors, such as "Chat without Microsoft Entra ID authentication". Discover them with `data "powerplatform_connectors"`.

### 2.4 Native options

**PowerShell module `Microsoft.PowerApps.Administration.PowerShell`** ([module](https://learn.microsoft.com/en-us/powershell/module/microsoft.powerapps.administration.powershell/?view=pa-ps-latest)):
- New-style cmdlets: `New-DlpPolicy`, `Get-DlpPolicy`, `Set-DlpPolicy`, `Remove-DlpPolicy`.
- Legacy cmdlets: `New-AdminDlpPolicy`, `Get-AdminDlpPolicy`, `Set-AdminDlpPolicy`, `Remove-AdminDlpPolicy`.
- Also: `New-PowerAppDlpPolicyConnectorConfigurations` and `Set-PowerAppDlpPolicyConnectorConfigurations` (action and endpoint rules), and `*-PowerAppDlpPolicyExemptResources`.
- `New-DlpPolicy` has two parameter sets ([doc](https://learn.microsoft.com/en-us/powershell/module/microsoft.powerapps.administration.powershell/new-dlppolicy?view=pa-ps-latest)):
  - `-DisplayName -EnvironmentType [-DefaultConnectorClassification] [-Environments]`
  - `-NewPolicy <Object>`
  - Default `-ApiVersion` is `2016-11-01`.

**pac CLI** ([pac admin](https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/admin)):
- `pac admin dlp-policy list` and `pac admin dlp-policy show --policy-name` are read-only.
- `pac admin set-governance-config --environment … --protection-level Standard|Basic` enables or disables Managed Environments.
- `pac admin list-tenant-settings` and `pac admin update-tenant-settings`.

**Admin connector "Power Platform for Admins"** ([connector ref](https://learn.microsoft.com/en-us/connectors/powerplatformforadmins/)): operation `CreatePolicyV2` ("Create DLP Policy V2").

**Native DLP JSON shape.** Microsoft Learn does not document it in full. The shape below comes from the Microsoft-owned Terraform provider source (`internal/services/dlp_policy/dto.go`), which calls `https://api.bap.microsoft.com/providers/PowerPlatform.Governance/v2/policies`. Treat it as **vendor-source-verified, not Learn-documented**.

```json
{
  "displayName": "Agent baseline",
  "defaultConnectorsClassification": "Blocked",
  "environmentType": "AllEnvironments",
  "environments": [
    { "id": "/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments/<envName>",
      "name": "<envName>", "type": "Microsoft.BusinessAppPlatform/scopes/environments" }
  ],
  "connectorGroups": [
    { "classification": "Confidential", "connectors": [ { "id": "/providers/Microsoft.PowerApps/apis/shared_sql", "name": "SQL Server", "type": "Microsoft.PowerApps/apis" } ] },
    { "classification": "General",      "connectors": [] },
    { "classification": "Blocked",      "connectors": [] }
  ]
}
```

Notes on this shape:
- In the wire format, `Confidential` means Business and `General` means Non-business. This mapping is from the provider's `convertConnectorRuleClassificationValues`.
- Custom connector URL patterns use `customConnectorUrlPatternsDefinition.rules[{order, customConnectorRuleClassification, pattern}]`.
- Action and endpoint rules use `connectorConfigurationsDefinition.{connectorActionConfigurations, endpointConfigurations}`.
- **UNVERIFIED:** the `type` value shown for connectors (`Microsoft.PowerApps/apis`).

### 2.5 Compliance

Copilot Studio is in the Microsoft ISO/IEC 42001 scope ([offering page](https://learn.microsoft.com/en-us/compliance/regulatory/offering-iso-42001)), and the reports are on the [Service Trust Portal](https://servicetrust.microsoft.com/viewpage/ISOIEC).

---

## 3. AWS Bedrock

### 3.1 Guardrails

**Policy types** ([components](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-components.html)):
- Content filters. Categories: Hate, Insults, Sexual, Violence, Misconduct and Prompt Attack. Prompt attack detection (jailbreaks, prompt injection, prompt leakage) is Standard tier only.
- Denied topics
- Word filters
- Sensitive information filters
- Contextual grounding checks
- Automated Reasoning checks

**IAM enforcement.** The condition key is **`bedrock:GuardrailIdentifier`**. Its value is the guardrail ARN, or `ARN:NumericVersion` ([guardrails-permissions-id](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-permissions-id.html); [service authorization ref](https://docs.aws.amazon.com/service-authorization/latest/reference/list_bedrock.html)).
- It applies to Converse, ConverseStream, InvokeModel and InvokeModelWithResponseStream.
- **Caveats:**
  - Do not reuse the same role for RetrieveAndGenerate, InvokeAgent or InvokeInlineAgent.
  - Input tags can skip the guardrail on prompts.
  - Cross-account use requires the same AWS Organization.

```json
{
  "Sid": "InvokeFoundationModelStatement2",
  "Effect": "Deny",
  "Action": ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"],
  "Resource": ["arn:aws:bedrock:us-east-1::foundation-model/*"],
  "Condition": { "StringNotEquals": {
    "bedrock:GuardrailIdentifier": "arn:aws:bedrock:us-east-1:123456789012:guardrail/guardrail-id:1" } }
}
```

**Guardrails enforcements: organization-level and account-level** ([guardrails-enforcements](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-enforcements.html)):
- **Organization-level** enforcement uses the AWS Organizations policy type **`BEDROCK_POLICY`**, which is declarative.
- **Account-level** enforcement uses the API `PutEnforcedGuardrailConfiguration`, set per Region.
- All applicable levels are enforced, and the most restrictive setting wins.
- Guardrails that use Automated Reasoning are **not supported** for enforcement.
- AWS announced GA in a ["what's new" post dated 2026-04](https://aws.amazon.com/about-aws/whats-new/2026/04/bedrock-guardrails-cross-account-safeguards). I only saw that post in search results.

```json
{ "bedrock": { "guardrail_inference": { "us-east-1": { "config_1": {
  "identifier": { "@@assign": "arn:aws:bedrock:us-east-1:123456789012:guardrail/guardrail-id:1" },
  "selective_content_guarding": { "system": { "@@assign": "selective" }, "messages": { "@@assign": "comprehensive" } },
  "model_enforcement": { "included_models": { "@@assign": ["ALL"] },
                         "excluded_models": { "@@assign": ["amazon.titan-embed-text-v2:0", "cohere.embed-english-v3"] } } } } } } }
```

### 3.2 Logging, Config, SCPs, network and KMS

**Model invocation logging** ([doc](https://docs.aws.amazon.com/bedrock/latest/userguide/model-invocation-logging.html)):
- It is **disabled by default**.
- Destinations are CloudWatch Logs and/or S3, in the same account and Region.
- It logs Converse, ConverseStream, InvokeModel and InvokeModelWithResponseStream, but only through `bedrock-runtime` (not through `bedrock-mantle`).
- APIs: `PutModelInvocationLoggingConfiguration`, `GetModelInvocationLoggingConfiguration` and `DeleteModelInvocationLoggingConfiguration`.

**CloudTrail** ([doc](https://docs.aws.amazon.com/bedrock/latest/userguide/logging-using-cloudtrail.html)):
- InvokeModel, InvokeModelWithResponseStream, Converse and ConverseStream are **management events**, which are logged by default.
- These are data events, which must be opted in: ApplyGuardrail (`AWS::Bedrock::Guardrail`), InvokeAgent (`AWS::Bedrock::AgentAlias`), InvokeInlineAgent (`AWS::Bedrock::InlineAgent`), Retrieve and RetrieveAndGenerate (`AWS::Bedrock::KnowledgeBase`), InvokeFlow (`AWS::Bedrock::FlowAlias`), RenderPrompt (`AWS::Bedrock::Prompt`), and async or bidirectional invocations (`AWS::Bedrock::Model` and `AWS::Bedrock::AsyncInvoke`).

**AWS Config managed rules** ([list](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html)). These are the only Bedrock rules found:
- `bedrock-data-source-encryption-enabled` (`BEDROCK_DATA_SOURCE_ENCRYPTION_ENABLED`, `AWS::Bedrock::DataSource`)
- `bedrock-agentcore-memory-encryption-enabled`
- `bedrock-agentcore-memory-event-expiry-duration`
- `bedrockagentcore-runtime-private-network-required`
- `bedrockagentcore-gateway-authorizer-enabled`
- `bedrockagentcore-gateway-encryption-enabled`
- `bedrockagentcore-browsercustom-network-mode-not-public`
- `bedrockagentcore-browsercustom-recording-enabled`
- `bedrockagentcore-codeinterpreter-networkmode-check`

There is **no** managed rule for "guardrail attached" or for "invocation logging enabled". Use a custom rule for those.

**SCPs and model restriction** ([identity-based policy examples](https://docs.aws.amazon.com/bedrock/latest/userguide/security_iam_id-based-policy-examples.html)):
- AWS says the deny-inference policy "can be used as a service control policy (SCP)".
- The foundation model ARN format is `arn:${Partition}:bedrock:${Region}::foundation-model/${ResourceId}`. There is no account segment.
- The inference profile ARN format is `arn:aws:bedrock:<region>:<account-id>:inference-profile/*`. The application inference profile format is `arn:${Partition}:bedrock:${Region}:${Account}:application-inference-profile/${ResourceId}`.
- Other condition keys: `bedrock:InferenceProfileArn`, `bedrock:PromptRouterArn`, `bedrock:ServiceTier`, `bedrock:DataRetentionMode` and `bedrock:BearerTokenType` ([service authorization ref](https://docs.aws.amazon.com/service-authorization/latest/reference/list_bedrock.html)).

```json
{ "Version": "2012-10-17", "Statement": { "Sid": "DenyInference", "Effect": "Deny",
  "Action": ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream", "bedrock:CreateModelInvocationJob"],
  "Resource": "arn:aws:bedrock:*::foundation-model/model-id" } }
```

Notes on this SCP:
- Denying `InvokeModel` also blocks Converse and StartAsyncInvoke.
- Restrictions that cover only `foundation-model` may not cover calls made through an inference profile. AWS examples list both ARN types.

**Region restriction with cross-Region inference.** Geographic profiles need every destination Region allowed. **Global** profiles need `"aws:RequestedRegion": "unspecified"` allowed ([cross-region inference](https://docs.aws.amazon.com/bedrock/latest/userguide/cross-region-inference.html)).

**VPC endpoints (PrivateLink)** ([doc](https://docs.aws.amazon.com/bedrock/latest/userguide/vpc-interface-endpoints.html)):
- `com.amazonaws.<region>.bedrock`
- `com.amazonaws.<region>.bedrock-runtime`
- `com.amazonaws.<region>.bedrock-mantle`
- `com.amazonaws.<region>.bedrock-agent`
- `com.amazonaws.<region>.bedrock-agent-runtime`
- FIPS variants: `bedrock-fips` and `bedrock-runtime-fips`

**KMS.** Custom models are encrypted with AWS-owned keys by default; you can supply a CMK instead ([doc](https://docs.aws.amazon.com/bedrock/latest/userguide/encryption-custom-job.html)).
- API parameter: `customModelKmsKeyId` on CreateModelCustomizationJob ([API ref](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_CreateModelCustomizationJob.html)).
- Terraform: `aws_bedrock_custom_model.custom_model_kms_key_id`.
- Guardrails take `kms_key_arn` (`KmsKeyArn`).

### 3.3 Audit Manager and ISO 42001

**Audit Manager framework.** "**AWS Generative AI Best Practices Framework v2**" has 72 automated controls, 38 manual controls and 8 control sets. It covers Amazon Bedrock and Amazon SageMaker AI. v1 is no longer supported. **Audit Manager is no longer open to new customers** ([doc](https://docs.aws.amazon.com/audit-manager/latest/userguide/aws-generative-ai-best-practices.html)).

**ISO/IEC 42001:2023:**
- AWS was certified by Schellman Compliance, LLC (ANAB-accredited).
- The initial scope was Amazon Bedrock, Amazon Q Business, Amazon Textract and Amazon Transcribe ([AWS ML blog, 2024-11-25](https://aws.amazon.com/blogs/machine-learning/aws-achieves-iso-iec-420012023-artificial-intelligence-management-system-accredited-certification)).
- The current scope is listed on the certificate, which you download from [AWS Artifact](https://aws.amazon.com/artifact/) ([ISO 42001 FAQs](https://aws.amazon.com/compliance/iso-42001-faqs/)).

### 3.4 Terraform (hashicorp/aws)

**`aws_bedrock_guardrail`** ([doc](https://github.com/hashicorp/terraform-provider-aws/blob/main/website/docs/r/bedrock_guardrail.html.markdown)):
- Required: `name`, `blocked_input_messaging` and `blocked_outputs_messaging`.
- Optional blocks:
  - `content_policy_config { filters_config {type, input_strength, output_strength, input_action, output_action, input_enabled, output_enabled, input_modalities, output_modalities}, tier_config {tier_name = CLASSIC|STANDARD} }`
  - `sensitive_information_policy_config { pii_entities_config {type, action, input_action, output_action, …}, regexes_config {name, pattern, action, …} }`
  - `topic_policy_config { topics_config {name, definition, examples, type}, tier_config }`
  - `word_policy_config { managed_word_lists_config {type}, words_config {text} }`
  - `contextual_grounding_policy_config { filters_config {type, threshold} }`
- Other optional arguments: `cross_region_config { guardrail_profile_identifier }` (required for STANDARD tier), `kms_key_arn` and `tags`.
- **Gap:** the Terraform resource has **no** Automated Reasoning argument. CloudFormation has `AutomatedReasoningPolicyConfig`.

**Other resources:**
- `aws_bedrock_guardrail_version`: `guardrail_arn`, `description`, `skip_destroy`.
- `aws_bedrock_model_invocation_logging_configuration`: `logging_config { s3_config {bucket_name, key_prefix}, cloudwatch_config {log_group_name, role_arn, large_data_delivery_s3_config}, text_data_delivery_enabled, image_data_delivery_enabled, embedding_data_delivery_enabled, video_data_delivery_enabled }`.
- `aws_organizations_policy`: `type` includes `SERVICE_CONTROL_POLICY`, `RESOURCE_CONTROL_POLICY` and **`BEDROCK_POLICY`**.
- **Not found** in the provider docs: an account-level enforced-guardrail resource. **UNVERIFIED** that none exists under another name.

```hcl
resource "aws_bedrock_guardrail" "baseline" {
  name                      = "baseline"
  blocked_input_messaging   = "Blocked by policy."
  blocked_outputs_messaging = "Blocked by policy."
  content_policy_config {
    filters_config {
      type            = "PROMPT_ATTACK"
      input_strength  = "HIGH"
      output_strength = "NONE"
    }
    tier_config { tier_name = "CLASSIC" }
  }
  sensitive_information_policy_config {
    pii_entities_config {
      type   = "NAME"
      action = "ANONYMIZE"
    }
  }
}

resource "aws_bedrock_guardrail_version" "v1" {
  guardrail_arn = aws_bedrock_guardrail.baseline.guardrail_arn
}

resource "aws_organizations_policy" "bedrock_guardrail" {
  name    = "bedrock-guardrail-enforcement"
  type    = "BEDROCK_POLICY"
  content = file("bedrock_policy.json")
}
```

`guardrail_arn` is an exported attribute; check the attribute reference before use. The `PROMPT_ATTACK` filter requires `output_strength = "NONE"` per the AWS docs. **UNVERIFIED** in this pass.

### 3.5 CloudFormation

The [AWS::Bedrock resource list](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/AWS_Bedrock.html) includes:
- `AWS::Bedrock::Guardrail`
- `AWS::Bedrock::GuardrailVersion`
- **`AWS::Bedrock::EnforcedGuardrailConfiguration`**
- `AWS::Bedrock::AutomatedReasoningPolicy` and `AWS::Bedrock::AutomatedReasoningPolicyVersion`
- `AWS::Bedrock::ApplicationInferenceProfile`
- `AWS::Bedrock::ResourcePolicy`

There is **no CloudFormation resource for model invocation logging**: none is in the AWS::Bedrock list.

**`AWS::Bedrock::Guardrail` properties** ([doc](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-bedrock-guardrail.html)):
- `AutomatedReasoningPolicyConfig`
- `BlockedInputMessaging` (required)
- `BlockedOutputsMessaging` (required)
- `ContentPolicyConfig` (`FiltersConfig[]`, `ContentFiltersTierConfig`)
- `ContextualGroundingPolicyConfig` (filter `Type`: `GROUNDING` | `RELEVANCE`, plus `Threshold`, `Action` and `Enabled`)
- `CrossRegionConfig`, `Description`, `KmsKeyArn`
- `Name` (required)
- `SensitiveInformationPolicyConfig`, `Tags`, `TopicPolicyConfig`, `WordPolicyConfig`
- GetAtt values: `GuardrailArn`, `GuardrailId`, `Version` (always `DRAFT`), `Status`, `CreatedAt` and `UpdatedAt`.
- Content filter `Type` values: `SEXUAL` | `VIOLENCE` | `HATE` | `INSULTS` | `MISCONDUCT` | `PROMPT_ATTACK`. Strength values: `NONE` | `LOW` | `MEDIUM` | `HIGH`.

**`AWS::Bedrock::GuardrailVersion`:** `GuardrailIdentifier` (required, ID or ARN) and `Description`.

**`AWS::Bedrock::EnforcedGuardrailConfiguration`:** `GuardrailIdentifier` (required), `GuardrailVersion`, `ModelEnforcement` and `SelectiveContentGuarding` ([doc](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-bedrock-enforcedguardrailconfiguration.html)).

```yaml
Resources:
  Guardrail:
    Type: AWS::Bedrock::Guardrail
    Properties:
      Name: baseline
      BlockedInputMessaging: "Blocked by policy."
      BlockedOutputsMessaging: "Blocked by policy."
      ContentPolicyConfig:
        FiltersConfig:
          - Type: HATE
            InputStrength: HIGH
            OutputStrength: HIGH
  GuardrailV1:
    Type: AWS::Bedrock::GuardrailVersion
    Properties:
      GuardrailIdentifier: !GetAtt Guardrail.GuardrailId
```

---

## 4. Google Cloud Vertex AI (now "Gemini Enterprise Agent Platform")

### 4.1 Organization Policy constraints

Sources: [constraints list](https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints) and [Control access to Model Garden models](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/control-model-access).

| Constraint | Type | Purpose (verbatim-ish) |
|---|---|---|
| `constraints/vertexai.allowedModels` | List, prefix `is:` | "Define access to models on Vertex AI". Format `model_id:feature_family`, e.g. `publishers/google/models/gemini-1.0-pro:predict`. Covers Google, third-party and open models in Model Garden. |
| `constraints/vertexai.allowedGenAIModels` | List | "Define access to Google proprietary generative AI models on Vertex AI". Covers Google proprietary models only. The docs point to `allowedModels` for the broader set. |
| `constraints/vertexai.allowedPartnerModelFeatures` | List | Partner model features `web_search` and `structured_outputs`. These are **blocked by default** for projects in an org. Values: `publishers/anthropic`, `publishers/anthropic/models/MODEL`, or `…/MODEL:web_search`. |
| `constraints/vertexai.disableGenAIGoogleSearchGrounding` | Boolean | Disables Grounding with Google Search. |
| `constraints/vertexai.genAIGroundingSources` | List | Allowed grounding sources: GoogleMaps, VertexAiSearch, VertexRagStore, EnterpriseWebSearch, ExternalApiSimpleSearch, ExternalApiElasticSearch, UrlContext and ParallelAiSearch. |
| `constraints/vertexai.allowOnlyAllCompliantAPIs` / `allowOnlyIL5CompliantAPIs` / `allowOnlyITARCompliantAPIs` | Boolean | Set by Assured Workloads ("Do not configure or modify"). |
| `constraints/gcp.resourceLocations` | List, prefixes `is:` and `in:` | Location restriction, e.g. `in:us-locations`. |
| `constraints/gcp.restrictNonCmekServices` | List | "Restrict which services may create resources without CMEK". Deny `aiplatform.googleapis.com` to require CMEK. |
| `constraints/gcp.restrictCmekCryptoKeyProjects` | List | Restricts which projects may supply CMEK keys. Supports `aiplatform.googleapis.com`. |

**`vertexai.allowedModels` details** (Model Garden docs):
- The model format is `publishers/PUBLISHER/models/MODEL_NAME:ACTION`. ACTION is `predict`, `deploy` or `tune`.
- The docs give the example `publishers/google/models/gemini-3.5-flash:predict`.
- The limit is 500 allowed plus denied values.
- Models must be listed individually; you cannot use group wildcards.
- It applies only to Model Garden models, not to Model Registry.
- If no policy is set, everything is allowed.

**Native YAML** for `gcloud org-policies set-policy policy.yaml`, verbatim from the docs. The docs show `rules:` followed by an un-dashed `values:` mapping in the Model Garden examples:

```yaml
name: organizations/ORGANIZATION_ID/policies/vertexai.allowedModels
spec:
  rules:
    values:
      allowedValues:
      - publishers/meta/models/llama3:deploy
      - publishers/google/models/gemini-3.5-flash:tune
      - publishers/hf-google/models/gemma-2b:deploy
```

The general org-policy docs ([create policies](https://docs.cloud.google.com/organization-policy/create-organization-policies)) use the list form `rules: - values: allowedValues: [...]`, with names such as `projects/PROJECT_ID/policies/CONSTRAINT_NAME`. Use the list form for repo artifacts, because `rules` is a repeated field:

```yaml
name: projects/PROJECT_ID/policies/vertexai.allowedModels
spec:
  rules:
  - values:
      allowedValues:
      - publishers/google/models/gemini-3.5-flash:predict
```

### 4.2 Perimeter, logging, safety, Model Armor, Assured Workloads, SCC

**VPC Service Controls.** "Gemini Enterprise Agent Platform" uses service name `aiplatform.googleapis.com`. Status is **GA** and it can be protected by perimeters ([supported products](https://docs.cloud.google.com/vpc-service-controls/docs/supported-products)). `modelarmor.googleapis.com` is also listed.

**Audit logs** ([audit logging](https://docs.cloud.google.com/vertex-ai/docs/general/audit-logging)):
- Admin Activity logs are always on.
- **Data Access logs are disabled by default** and must be enabled.
- Methods logged as DATA_READ include `endpoints.predict`, `endpoints.rawPredict`, `endpoints.explain`, `ragFiles.get` and `memories.retrieve`.
- **UNVERIFIED:** whether publisher-model `generateContent` calls emit Data Access logs. I did not find them listed on that page.

**Safety filters** ([configure safety filters](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/multimodal/configure-safety-filters)):
- Harm categories: `HARM_CATEGORY_HATE_SPEECH`, `HARM_CATEGORY_DANGEROUS_CONTENT`, `HARM_CATEGORY_HARASSMENT` and `HARM_CATEGORY_SEXUALLY_EXPLICIT`.
- Thresholds: `BLOCK_LOW_AND_ABOVE`, `BLOCK_MEDIUM_AND_ABOVE`, `BLOCK_ONLY_HIGH`, `BLOCK_NONE`, `OFF` and `HARM_BLOCK_THRESHOLD_UNSPECIFIED`.
- Methods: `SEVERITY` (the default) and `PROBABILITY`.
- "For gemini-3.5-flash and subsequent models, OFF is the default value". The default is off for new models, so a governance baseline should set thresholds explicitly.
- Safety settings are set per request; there is no org policy for them. To enforce centrally, use Model Armor floor settings.

**Model Armor: templates** ([overview](https://docs.cloud.google.com/model-armor/overview)):
- Filters:
  - Responsible AI: hate speech, harassment, sexually explicit and dangerous. CSAM is always on.
  - Prompt injection and jailbreak detection.
  - Sensitive Data Protection: basic or advanced configuration.
  - Malicious URL detection.
- Confidence levels: `LOW_AND_ABOVE`, `MEDIUM_AND_ABOVE` and `HIGH`.

**Model Armor: floor settings** ([configure](https://docs.cloud.google.com/model-armor/configure-floor-settings)):
- Floor settings set minimum requirements at organization, folder or project level.
- Resource name: `{organizations|folders|projects}/ID/locations/global/floorSetting`.
- REST fields ([discovery doc](https://modelarmor.googleapis.com/$discovery/rest?version=v1)): `filterConfig`, `enableFloorSettingEnforcement`, `integratedServices[]` (`AI_PLATFORM` | `GOOGLE_MCP_SERVER`), `aiPlatformFloorSetting { inspectOnly | inspectAndBlock, enableCloudLogging }` and `googleMcpServerFloorSetting`.

**Model Armor: Vertex integration** ([integration](https://docs.cloud.google.com/model-armor/model-armor-vertex-integration)):
- Per request: `generateContent` takes `model_armor_config { prompt_template_name, response_template_name }`.
- Project-wide: floor settings apply to all Gemini `generateContent` calls.
- The Vertex AI service account needs the Model Armor User role.

**Model Armor: Terraform.** Both resources exist in hashicorp/google:
- **`google_model_armor_template`**: `location`, `template_id`, `filter_config { rai_settings { rai_filters { filter_type = SEXUALLY_EXPLICIT|HATE_SPEECH|HARASSMENT|DANGEROUS, confidence_level } }, sdp_settings { basic_config | advanced_config }, pi_and_jailbreak_filter_settings, malicious_uri_filter_settings }` and `template_metadata { enforcement_type = INSPECT_ONLY|INSPECT_AND_BLOCK, … }`.
- **`google_model_armor_floorsetting`**: `parent`, `location = "global"`, `filter_config`, `enable_floor_setting_enforcement`, `integrated_services`, `ai_platform_floor_setting { inspect_only | inspect_and_block, enable_cloud_logging }` and `google_mcp_server_floor_setting`.

```hcl
resource "google_model_armor_floorsetting" "org_floor" {
  parent   = "projects/my-project"
  location = "global"
  filter_config {
    rai_settings {
      rai_filters {
        filter_type      = "DANGEROUS"
        confidence_level = "MEDIUM_AND_ABOVE"
      }
    }
    pi_and_jailbreak_filter_settings {
      filter_enforcement = "ENABLED"
      confidence_level   = "HIGH"
    }
    malicious_uri_filter_settings { filter_enforcement = "ENABLED" }
  }
  enable_floor_setting_enforcement = true
  # integrated_services = ["AI_PLATFORM"]   # enum value verified in REST discovery doc
}
```

**Assured Workloads.** `google_assured_workloads_workload.compliance_regime` values include `FEDRAMP_HIGH`, `IL5`, `ITAR`, `EU_REGIONS_AND_SUPPORT`, `HIPAA`, `REGIONAL_CONTROLS` and others. The `vertexai.allowOnly*CompliantAPIs` constraints are set automatically during Assured Workloads onboarding.

**Security Command Center AI Protection** ([overview](https://docs.cloud.google.com/security-command-center/docs/ai-protection-overview)):
- Capabilities: AI asset inventory, vulnerabilities and risks (Premium tier), over-privileged agent detection, compliance and threat detection.
- It includes the Compliance Manager frameworks "Security Essentials" and "Google Recommended AI Essentials - Gemini Enterprise Agent Platform".
- The SCC Enterprise tier shuts down on 2027-05-21.

### 4.3 Terraform (hashicorp/google)

**`google_org_policy_policy`** ([doc](https://github.com/hashicorp/terraform-provider-google/blob/main/website/docs/r/org_policy_policy.html.markdown)):
- `name`, `parent`
- `spec { inherit_from_parent, reset, rules { values { allowed_values, denied_values }, allow_all, deny_all, enforce, condition {…} } }`
- `dry_run_spec`

```hcl
resource "google_org_policy_policy" "allowed_models" {
  name   = "projects/${var.project_id}/policies/vertexai.allowedModels"
  parent = "projects/${var.project_id}"
  spec {
    rules {
      values {
        allowed_values = ["publishers/google/models/gemini-3.5-flash:predict"]
      }
    }
  }
}
```

**`google_access_context_manager_service_perimeter`:** `parent = "accessPolicies/…"`, `name = "accessPolicies/…/servicePerimeters/…"`, `title`, `status { restricted_services = ["aiplatform.googleapis.com"], resources = ["projects/NUMBER"] }`, `perimeter_type` and `use_explicit_dry_run_spec`.

**`google_project_iam_audit_config`:** `project`, `service` (for example `"aiplatform.googleapis.com"` or `"allServices"`) and `audit_log_config { log_type = DATA_READ|DATA_WRITE|ADMIN_READ, exempted_members }`. It is documented in the `google_project_iam` doc page.

```hcl
resource "google_project_iam_audit_config" "vertex" {
  project = var.project_id
  service = "aiplatform.googleapis.com"
  audit_log_config { log_type = "DATA_READ" }
  audit_log_config { log_type = "DATA_WRITE" }
}
```

### 4.4 Google compliance

**ISO/IEC 42001:2023.** "Google Cloud, Google Workspace, and Gemini (App) are certified" ([page](https://cloud.google.com/security/compliance/iso-42001)).
- In-scope products include "Gemini Enterprise Agent Platform (formerly Vertex AI Platform)", "Generative AI on Gemini Enterprise Agent Platform (formerly Generative AI on Vertex AI)", Gemini for Google Cloud, Gemini Enterprise, Document AI and others.
- Certificates are available through the **Compliance Reports Manager**.
- That page does not name the certification body.

---

## Cross-cutting UNVERIFIED items

1. Whether `azurerm_policy_definition` accepts `mode = "Microsoft.CognitiveServices.Data"` for custom definitions. The provider doc list omits it, but the built-in definition uses it.
2. Whether `extension { name = "AIPromptEvidence" }` works with `azurerm_security_center_subscription_pricing` for `resource_type = "AI"`.
3. `Microsoft.DefaultV2` as a raiPolicy `basePolicyName`.
4. The exact Power Platform connector IDs for the Copilot Studio governance connectors, and whether tenant isolation applies to Copilot Studio.
5. The Purview RecordType name for Copilot Studio audit events.
6. Whether Vertex AI publisher-model `generateContent` calls appear in Data Access audit logs.
7. Whether a Terraform resource for Bedrock account-level enforced guardrail configuration exists. None was found in the hashicorp/aws docs.
8. Whether Copilot Studio and Foundry agents automatically receive Microsoft Entra Agent IDs.
