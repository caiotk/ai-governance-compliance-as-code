# Vendor pack: Microsoft Copilot Studio / Power Platform

**Verified as of 2026-10-13.** Checked against:

- the microsoft/power-platform **v4.2.0** provider schema and its v4.2.0 validator source
- Microsoft Learn: Copilot Studio admin, Managed Environments, cross-tenant restrictions, pac CLI and the PowerShell module reference
- the `Microsoft.PowerApps.Administration.PowerShell` 2.0.219 module source

## Purpose

This pack sets a tenant baseline for Copilot Studio agents and the production environment they run in:

- **Data policy.** Agents can use only approved connectors. High-risk agent connectors are blocked.
- **Authentication.** Agents must authenticate users with Microsoft Entra ID.
- **Sharing.** Agent sharing is limited to named individuals.
- **Imports.** Solution imports are checked before they land.
- **Cross-tenant connections.** These are blocked except to listed tenants.

Copilot Studio enforces data policies in real time. A violating agent cannot be published, and blocking a connector also blocks its tools in connected MCP servers. Agent exemptions are no longer supported (MC973179).

## What is enforced

| Control | Mechanism | Terraform | Native |
|---|---|---|---|
| AIG-05 / AIG-06 connectors | Tenant-wide data policy "AIGov agent baseline". It covers `AllEnvironments`, with `default_connectors_classification = "Blocked"`, so new and unlisted connectors are blocked. Business connectors come from a variable. Unblockable connectors go to Non-business. Custom connectors are Blocked unless they match an approved host pattern. | `terraform/main.tf` (`powerplatform_data_loss_prevention_policy.agent_baseline`) | `native/dlp-policy.json`, `native/New-AgentDlpPolicy.ps1` |
| AIG-07 user authentication | **Chat without Microsoft Entra ID authentication in Copilot Studio** is in the Blocked group, which forces agents to require Entra ID sign-in. | same | same |
| AIG-08 egress | **HTTP** is Blocked. Alternatively, it moves to Business with endpoint rules: Allow each listed endpoint, then Deny `*` (`http_allowed_endpoints`). **Knowledge source with public websites and data**, **Facebook channel** and **WhatsApp channel** in Copilot Studio are Blocked. | same | same (endpoint rules: see Unverified) |
| AIG-07 sharing | `powerplatform_managed_environment` sets: `is_group_sharing_disabled = true`; `copilot_limit_sharing_mode = ExcludeSharingToSecurityGroups` (or `DisableSharing`); `copilot_max_limit_user_sharing = 20`; `copilot_allow_grant_editor_permissions_when_shared = false`; `power_automate_is_sharing_disabled = true` | `terraform/main.tf` (`powerplatform_managed_environment.production`) | `New-AgentDlpPolicy.ps1 -EnvironmentName` (`bot-limitSharingMode`, `bot-maxLimitUserSharing`, `bot-authoringSharingDisabled`) |
| AIG-15 change gate | Managed Environment `solution_checker_mode = "Block"` | same (pac flag UNVERIFIED) | `native/pac-cli.sh` (`pac admin set-governance-config --protection-level Standard --solution-checker-mode block`) |
| AIG-06 / AIG-13 environment settings | `enable_preview_and_experimental_ai_models = false`; Dataverse auditing on, with `log_retention_period_in_days` | `terraform/main.tf` (`powerplatform_environment_settings.production`) | Power Platform admin center |
| AIG-08 / AIG-18 tenant isolation | `powerplatform_tenant_isolation_policy` with `is_disabled = false` and the allow-list from `terraform/allowed-tenants.json` | `terraform/main.tf` (`powerplatform_tenant_isolation_policy.this`) | Power Platform admin center → Security → Tenant isolation |
| AIG-08 / AIG-18 data movement *(optional)* | `powerplatform_environment` with `allow_moving_data_across_regions = false` and `allow_bing_search = false` | `terraform/examples/governed-environment/main.tf` | admin center: environment → Generative AI features |
| AIG-13 audit *(evidence)* | Purview audit for Copilot Studio is on by default and cannot be disabled. It logs `BotCreate`, `BotDelete`, `BotUpdateOperation-BotPublish`, `BotUpdateOperation-BotShare`, `BotComponentCreate`, `AIPluginOperationUpdate` and `CopilotInteraction`. | n/a | Purview portal → Audit |
| AIG-02 inventory *(evidence)* | Agent inventory (`microsoft.copilotstudio/agents` in `PowerPlatformResources`), including `properties.authentication` and `properties.entraAgentId` | n/a | `native/pac-cli.sh` + `native/agent-inventory-query.json` (`pac resource-query query-resources`, Preview) |

`mapping.yaml` holds the same mapping plus the gaps.

### How connector IDs are resolved

Microsoft Learn documents the governable Copilot Studio connectors by admin-center **display name** only. Their connector IDs (`/providers/Microsoft.PowerApps/apis/shared_…`) are UNVERIFIED, so no ID is hard-coded:

1. `data "powerplatform_connectors" "all"` reads the tenant's connector catalogue.
2. Each name in `blocked_connector_display_names` is matched exactly against `display_name`.
3. Entries in `blocked_connector_id_overrides` (display name → ID) take precedence over the lookup.
4. Names that do not resolve:
   - appear in `output.unresolved_blocked_connectors`
   - raise a warning from the `check "copilot_studio_connectors_resolved"` block
   - are still blocked by `default_connectors_classification = "Blocked"`, but not listed explicitly.

After the first `terraform plan`, confirm each resolved ID against Power Platform admin center → Policies → Data policies → Prebuilt connectors, then pin any missing ones in `blocked_connector_id_overrides`. The native `dlp-policy.json` carries `REPLACE_ME_…` placeholders, and `New-AgentDlpPolicy.ps1` refuses to run while they remain.

## How to apply

### Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars    # fill in environment_id and connector lists
# edit allowed-tenants.json if partner tenants need cross-tenant connections
terraform init
terraform plan -out tfplan                       # check outputs.unresolved_blocked_connectors
terraform apply tfplan
```

**Before you apply, note the following:**

- **Tenant isolation is tenant-wide.** Coordinate with whoever owns cross-tenant access. Set `enable_tenant_isolation = false` to leave it unmanaged.
- **The allow-list lives in a file.** `allowed-tenants.json` is a reviewed data file, not a variable. Provider v4.2.0's validation of `powerplatform_tenant_isolation_policy` fails when `allowed_tenants` is unknown at validate time.
- **Existing tenant policies still apply.** The data policy is `AllEnvironments`. Any existing tenant or environment data policies keep applying alongside it.
- **The governed-environment example creates a new environment.** `terraform/examples/governed-environment` is a separate root module. To use it on an existing environment, import that environment first.

### Native

```bash
# Managed Environment + read-only evidence (pac CLI)
pac auth create
ENVIRONMENT_ID=<env-guid> native/pac-cli.sh
```

```powershell
# Data policy + agent sharing limits
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser
./native/New-AgentDlpPolicy.ps1 -EnvironmentName <env-guid> -WhatIf   # review
./native/New-AgentDlpPolicy.ps1 -EnvironmentName <env-guid>
```

**About `native/dlp-policy.json`:**

- **Shape.** It uses the Power Platform governance API wire shape, taken from the Microsoft-owned Terraform provider's DTOs.
- **Classifications.** `Confidential` = Business, `General` = Non-business, `Blocked` = Blocked. `Add-ConnectorsToPolicy` on Learn documents the same mapping.
- **Creation.** `New-DlpPolicy -NewPolicy` posts it to the governance API.
- **Group membership.** You can adjust it afterwards with the documented `Add-ConnectorsToPolicy -PolicyName <guid> -Classification Confidential|General|Blocked -Connectors @(...)`.

## Prerequisites and permissions

- **Role.** Power Platform administrator, or Global administrator, for data policies, Managed Environments, tenant isolation and tenant settings.
- **Terraform authentication.** The microsoft/power-platform provider can use Azure CLI, OIDC or a service principal. To use a service principal, register its Entra application with `pac admin application register` first.
- **PowerShell.**
  - `Microsoft.PowerApps.Administration.PowerShell` from the PowerShell Gallery
  - interactive `Add-PowerAppsAccount`; no credentials are stored in the script
- **pac CLI.** Power Platform CLI with `pac auth create`. The inventory query is a Preview command that supports delegated user authentication only.
- **Agent authentication.** Before blocking the unauthenticated chat connector, configure Microsoft Entra ID authentication on existing agents. Otherwise they cannot be republished.

## Unverified / known gaps

**UNVERIFIED**

- **Connector IDs.** The exact IDs of the Copilot Studio governance connectors are unknown. These are "HTTP", "Chat without Microsoft Entra ID authentication in Copilot Studio", "Knowledge source with public websites and data in Copilot Studio", "Facebook channel in Copilot Studio" and "WhatsApp channel in Copilot Studio". The pack resolves them by display name or override, as described above.
- **Connectors API coverage.** It is also unverified whether every one of these connectors is returned by the connectors API that `data "powerplatform_connectors"` uses.
- **DLP JSON `type` value.** The `type` on connectors in `dlp-policy.json` (`Microsoft.PowerApps/apis`) is what the Terraform provider sends. The PowerShell module's own example for `Add-ConnectorsToPolicy` uses `providers/Microsoft.PowerApps/apis` instead.
- **Endpoint-configuration object.** The object shape for `New-/Set-PowerAppDlpPolicyConnectorConfigurations` is not documented on Learn. Use the Terraform path (`http_allowed_endpoints`) for HTTP endpoint filtering. The PowerShell script documents the provider-derived shape in comments only.
- **Tenant isolation scope.** Microsoft documents tenant isolation for canvas apps and Power Automate flows. Whether it applies explicitly to Copilot Studio agents is unverified.
- **Purview RecordType.** The RecordType name for Copilot Studio audit events is unverified. Search by operation name instead.
- **Entra Agent IDs.** Whether Copilot Studio agents automatically receive Microsoft Entra Agent IDs is unverified. The inventory exposes `entraAgentId` when it is present.

**Known gaps** (also in `mapping.yaml`):

- **No content controls here.** Content moderation, runtime protection and customer-managed keys (via Power Platform enterprise policies) are not configured by this pack.
- **Environment groups override sharing limits.** When an environment belongs to an environment group, Managed Environment settings from `powerplatform_managed_environment` do not apply. Manage them with `powerplatform_environment_group_rule_set` instead.
- **Data movement needs a new environment.** `allow_moving_data_across_regions` and `allow_bing_search` are only available on the full `powerplatform_environment` resource. They are therefore in the optional example and not in the root pack.
- **Out of scope for the platform.** Human oversight, transparency, testing, fairness and incident handling must be built into agent design and ALM.

## Attestation

Microsoft Copilot Studio is in scope of Microsoft's **ISO/IEC 42001:2023** certification ([offering page](https://learn.microsoft.com/en-us/compliance/regulatory/offering-iso-42001)). Audit reports are on the [Service Trust Portal](https://servicetrust.microsoft.com/viewpage/ISOIEC). The certification covers Microsoft as the provider, not your agents.
