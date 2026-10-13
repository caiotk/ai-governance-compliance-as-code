# Vendor pack: Microsoft Foundry / Azure OpenAI / Azure AI services

**Verified as of 2026-10-13.** Checked against:

- hashicorp/azurerm **v5.9.0** provider schema (`terraform providers schema -json`)
- Bicep CLI **0.48.1** with `Microsoft.CognitiveServices@2026-07-01`
- built-in policy JSON in [Azure/azure-policy](https://github.com/Azure/azure-policy/tree/master/built-in-policies)
- Microsoft Learn

Microsoft now calls Azure AI Foundry "Microsoft Foundry". The resource provider is still `Microsoft.CognitiveServices`.

## Purpose

The pack does two things for Foundry (kind `AIServices`), Azure OpenAI and other Azure AI services accounts:

- **Guardrails across the estate.** It assigns built-in Azure Policy definitions at a management group. Non-compliant accounts and model deployments are denied or flagged everywhere under that group.
- **A reference account.** It deploys one hardened account that already passes those policies, with content filters, logging and Defender for AI services turned on.

## What is enforced

| Control | Mechanism | Effect | Terraform | Native |
|---|---|---|---|---|
| AIG-06 approved models | Built-in *Foundry model deployments should only use approved models* (`aafe3651-cb78-4f68-9f81-e7e41509110f`) with `allowedPublishers` / `allowedAssetIds` | **Deny** | `terraform/policy.tf` (`approved_models`) | `native/policy/assignments.bicep`, `native/policy/approved-models.parameters.json`, `native/policy/assign.sh` |
| AIG-06 / AIG-15 version pinning | Deployment pins `model.version` and sets `version_upgrade_option = NoAutoUpgrade` | config | `terraform/main.tf` (`azurerm_cognitive_deployment.sample`) | `native/bicep/foundry-account.bicep` |
| AIG-07 no keys | *Azure AI Services resources should have key access disabled* (`71ef260a-8f18-47b7-abcb-62d0673d94dc`); account `local_auth_enabled = false` | **Deny** | `terraform/policy.tf`, `terraform/main.tf` | `assignments.bicep`, `assign.sh`, `foundry-account.bicep` |
| AIG-07 managed identity | *Cognitive Services accounts should use a managed identity* (`fe3fd216-4f83-4fc1-8984-2bbec80a3418`); account has a system-assigned identity, plus an optional user-assigned one | **Deny** (variable) | `terraform/policy.tf`, `terraform/main.tf` | same |
| AIG-08 network | *Azure AI Services resources should restrict network access* (`037eea7a-bd0a-46c5-9a66-03aea78705d3`); account has `public_network_access_enabled = false`, `network_acls.default_action = Deny`, outbound FQDN allow-list and a private endpoint (subresource `account`) | **Deny** | `terraform/policy.tf`, `terraform/main.tf` | same |
| AIG-08 Private Link | *Azure AI Services resources should use Azure Private Link* (`d6759c02-b87f-42b7-892e-71b3f471d782`) | Audit (the only effect available besides Disabled) | `terraform/policy.tf` | `assignments.bicep`, `assign.sh` |
| AIG-09 CMK | *Azure AI Services resources should encrypt data at rest with a customer-managed key (CMK)* (`67121cc7-ff39-4ab8-b7e3-95b84dab487d`), `excludedKinds` overridden to `[]`; optional `customer_managed_key` on the account | Audit (variable; Deny available) | `terraform/policy.tf`, `terraform/main.tf` | same |
| AIG-10 content safety | `raiPolicies` content filter in `Blocking` mode, bound to the deployment through `rai_policy_name` (filter list below) | config | `terraform/main.tf` (`azurerm_cognitive_account_rai_policy.this`) | `foundry-account.bicep` |
| AIG-13 logging | *Diagnostic logs in Azure AI services resources should be enabled* (`1b4d1c4e-934c-4703-944c-27c82c06bebb`); diagnostic setting sends `allLogs` and `AllMetrics` to Log Analytics | AuditIfNotExists | `terraform/policy.tf`, `terraform/main.tf` | `assignments.bicep`, `assign.sh`, `foundry-account.bicep` |
| AIG-13 / AIG-08 (EU AI Act evidence) | Built-in initiative *EU AI Act 2024 1689* (`1308bccf-446a-4283-a4e0-0c983fe7a572`), default parameters | Audit (optional, `assign_eu_ai_act_initiative`) | `terraform/policy.tf` (`eu_ai_act`) | `assignments.bicep`, `assign.sh` |
| AIG-02 / AIG-13 / AIG-16 threat detection | Defender for Cloud threat protection for AI services: `azurerm_security_center_subscription_pricing` with `resource_type = "AI"`, `tier = "Standard"` | alerts | `terraform/defender.tf` | `native/bicep/defender-ai.bicep` |

The content filter covers:

- `Hate`, `Sexual`, `Violence` and `Selfharm` at `Medium` on `Prompt` and `Completion`
- `Jailbreak` on `Prompt`
- `Protected Material Text` and `Protected Material Code` on `Completion`

`mapping.yaml` lists the same controls in machine-readable form, along with the gaps the platform cannot close.

### Policy parameters used

Every effect below is checked against the definition JSON.

| Definition | Parameters the pack sets |
|---|---|
| `71ef260a…` | `effect` = Deny |
| `037eea7a…` | `effect` = Deny |
| `d6759c02…` | `effect` = Audit |
| `1b4d1c4e…` | `effect` = AuditIfNotExists |
| `fe3fd216…` | `effect` = Deny (`managed_identity_policy_effect`) |
| `67121cc7…` | `effect` = Audit (`cmk_policy_effect`), `excludedKinds` = `[]` |
| `aafe3651…` | `effect` = Deny, `allowedPublishers`, `allowedAssetIds` |
| `1308bccf…` (initiative) | none. The initiative takes per-member parameters named `effect-<definition GUID>`, and all of them default to Audit or AuditIfNotExists. |

**Approved-model matching.** `allowedAssetIds` uses a prefix match that is case-sensitive:

- `…/models/gpt-5/` allows that one model.
- `…/models/gpt-5.2/versions/1` pins a single version.

If you use the model router, add publisher `Microsoft` and the publishers of the models it routes to.

## How to apply

### Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # fill in placeholders
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

Roll out with `policy_enforce = false` first. That sets enforcement mode to DoNotEnforce. Review compliance with `az policy state summarize -m <mg>`, then switch to `true`.

To apply only the guardrails, set `deploy_reference_account = false`. Defender for AI is controlled by `enable_defender_for_ai`.

### Native (Bicep / Azure CLI)

**Policy assignments** (management-group scope):

```bash
az deployment mg create --management-group-id <mg> --location <region> \
  -f native/policy/assignments.bicep \
  -p approvedModelAssetIds='["azureml://registries/azure-openai/models/gpt-5/"]'
# or, with the Azure CLI only:
MG_NAME=<mg> native/policy/assign.sh
```

`assign.sh` reads the approved-model register from `native/policy/approved-models.parameters.json`. That file uses the exact parameter-file shape documented on the Foundry model-deployment-policy page.

**Hardened account** (resource-group scope):

```bash
az deployment group create -g <rg> -f native/bicep/foundry-account.bicep \
  -p accountName=<name> customSubDomainName=<subdomain> \
     logAnalyticsWorkspaceId=<workspace-resource-id>
```

Create the private endpoint separately: subresource `account`, plus the three DNS zones listed in Prerequisites. Alternatively, let a Private Link `DeployIfNotExists` policy create it.

**Defender for AI services** (subscription scope):

```bash
az deployment sub create --location <region> -f native/bicep/defender-ai.bicep
```

## Prerequisites and permissions

| Task | Role needed |
|---|---|
| Assign policies | **Resource Policy Contributor** (or Owner) on the management group |
| Create the account, deployment, RAI policy and diagnostic setting | **Contributor** on the resource group, and **Monitoring Contributor** / Log Analytics access for the diagnostic setting |
| Enable Defender plans | **Security Admin** or Owner on the subscription |

Other prerequisites:

- **Private endpoint.** You need an existing VNet subnet and the private DNS zones `privatelink.cognitiveservices.azure.com`, `privatelink.openai.azure.com` and `privatelink.services.ai.azure.com`.
- **CMK.** You need a Key Vault key and a user-assigned identity that can wrap and unwrap it, granted before the account is created. Pass it as `user_assigned_identity_id` and `customer_managed_key.identity_client_id`. Follow Microsoft's Foundry CMK guidance for the Key Vault settings and the role to grant.
- **Quota.** The sample model and SKU must be available in the region, and the model must be on the approved list. Otherwise the Deny policy blocks the deployment, which is the intended behaviour.

## Unverified / known gaps

**Things this pack could not verify:**

- **`Microsoft.CognitiveServices.Data` custom policy mode.** The approved-models built-in uses this data-plane mode. It is UNVERIFIED whether `azurerm_policy_definition` or custom definitions can use it. This pack only assigns the built-in, so it does not depend on the answer.
- **`AIPromptEvidence` extension.** It is UNVERIFIED whether `azurerm_security_center_subscription_pricing` accepts this extension for `resource_type = "AI"`. In `terraform/defender.tf` it is left commented out.
  - The native `defender-ai.bicep` exposes it behind `enablePromptEvidence` (default `false`). The ARM schema documents the extension, but the pack has not tested it for the `AI` plan.
- **`Microsoft.DefaultV2` base policy.** It is UNVERIFIED as a `basePolicyName`, so the pack uses `Microsoft.Default`.
- **Diagnostic setting API version.** `Microsoft.Insights/diagnosticSettings@2021-05-01-preview` is the newest version the template reference shows, and Bicep accepts it without warnings. No stable version is listed.

**Gaps in what the pack enforces:**

- **CMK default exclusions.** The built-in CMK policy's default `excludedKinds` includes `AIServices`, which would exempt Foundry accounts. The pack overrides it to `[]`. Add kinds back if you intentionally exempt them.
- **Content-filter policies.** The built-in content-filter policies are Preview and Audit-only:
  - `f3a9c2e0…`, `af253d37…`, `930f48f9…`, `c1ad46c6…`
  - the agent variants `9224c1cc…` and `595f98a5…`
  - the initiative *[Preview]: Guardrail for Cognitive Services Deployments* (`5207647b…`)

  They are not assigned here. The pack sets filters directly on the account instead. You can add them as an Audit layer once they reach GA.
- **Eligibility policy.** *[Preview]: Foundry model deployments should meet eligibility requirements* (`8791d062…`, parameters `onlyAllowDirectFromAzure` and `denyPreviewModels`) is not assigned. The built-in list still marks it Preview, even though the Foundry docs call it GA.
- **Hub-based (classic) Foundry.** Hubs run on `Microsoft.MachineLearningServices/workspaces` and are not covered. Use the Machine Learning built-ins (`438c38d2…`, `ba769a63…`, `e96a9a5f…`, `6ddb1705…`, `afe0c3be…`) in a separate assignment.
- **Purview DSPM for AI.** It does not include data from Foundry agents, and its policies apply only to Entra ID user-context calls. Personal data protection (AIG-05) still needs DLP or an application-side PII filter.
- **Region of processing (AIG-18).** `Global*` deployment SKUs can process data outside the account's region, and no verified built-in policy restricts the deployment SKU. Choose `Standard` or `DataZone*` SKUs and record the decision.
- **Agent identities.** It is UNVERIFIED whether Foundry agents automatically receive Microsoft Entra Agent IDs.
- **Not in Azure Policy.** Human oversight (AIG-11), transparency (AIG-12), testing (AIG-14) and fairness (AIG-20) have no Azure Policy control. See `gaps` in `mapping.yaml`.

## Attestation

Microsoft Foundry is in scope of Microsoft's **ISO/IEC 42001:2023** certification ([offering page](https://learn.microsoft.com/en-us/compliance/regulatory/offering-iso-42001)). Certificates and audit reports are on the [Service Trust Portal](https://servicetrust.microsoft.com/viewpage/ISOIEC).

The certification covers Microsoft as the AI provider. It does not cover your deployment, which this pack and your own AI management system address.

Purview Compliance Manager offers assessment templates for ISO/IEC 42001:2023, the EU Artificial Intelligence Act and NIST AI RMF 1.0.
