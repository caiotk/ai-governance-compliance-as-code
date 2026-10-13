<#
.SYNOPSIS
    Applies the Copilot Studio agent baseline natively: a tenant-wide data
    (DLP) policy and Managed Environment agent-sharing limits.

.DESCRIPTION
    Uses Microsoft.PowerApps.Administration.PowerShell. Equivalent to
    ../terraform.

    1. Data policy (AIG-05 AIG-06 AIG-07 AIG-08)
       Creates the policy in dlp-policy.json with New-DlpPolicy -NewPolicy.
       Default classification is Blocked; the high-risk Copilot Studio
       connectors are listed in the Blocked group. The connector IDs in the
       JSON are placeholders (REPLACE_ME_...) because the exact IDs are
       UNVERIFIED: take them from the Power Platform admin center or from the
       Terraform output resolved_blocked_connectors. The script refuses to run
       while placeholders remain.

    2. Agent sharing limits (AIG-07), only when -EnvironmentName is given.
       Sets the documented Managed Environment extended settings
       bot-limitSharingMode = ExcludeSharingToSecurityGroups,
       bot-maxLimitUserSharing = <n> and bot-authoringSharingDisabled = True
       (no Editor grants), plus canvas limitSharingMode/maxLimitUserSharing and
       solutionCloudFlows-limitSharingMode = disableSharing. The environment
       must already be a Managed Environment (see pac-cli.sh).

    Requires the Power Platform administrator role. No credentials are stored:
    Add-PowerAppsAccount prompts for sign-in.

.PARAMETER PolicyFile
    Path to the data policy JSON. Defaults to dlp-policy.json next to this script.

.PARAMETER EnvironmentName
    Environment ID (GUID) of the production agent environment. Omit to skip
    the sharing limits.

.PARAMETER MaxAgentViewers
    bot-maxLimitUserSharing: maximum viewers per agent.

.PARAMETER MaxCanvasUsers
    maxLimitUserSharing: maximum individuals per canvas app.

.PARAMETER SkipDlp
    Only apply the sharing limits.

.EXAMPLE
    ./New-AgentDlpPolicy.ps1 -EnvironmentName 00000000-0000-0000-0000-000000000000 -WhatIf

.NOTES
    Controls: AIG-05 AIG-06 AIG-07 AIG-08
    Verified against Microsoft Learn and module 2.0.219 on 2026-10-13.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$PolicyFile = (Join-Path -Path $PSScriptRoot -ChildPath 'dlp-policy.json'),
    [string]$EnvironmentName,
    [ValidateRange(1, 99)]
    [int]$MaxAgentViewers = 20,
    [ValidateRange(1, 99)]
    [int]$MaxCanvasUsers = 20,
    [switch]$SkipDlp
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Module -ListAvailable -Name Microsoft.PowerApps.Administration.PowerShell)) {
    throw 'Install the module first: Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser'
}
Import-Module Microsoft.PowerApps.Administration.PowerShell

# Interactive sign-in; use -Endpoint for sovereign clouds (e.g. usgov).
Add-PowerAppsAccount

# ── 1. Data policy ───────────────────────────────────────────────────────────
if (-not $SkipDlp) {
    $raw = Get-Content -Path $PolicyFile -Raw
    if ($raw -match 'REPLACE_ME') {
        throw "Replace the REPLACE_ME connector IDs in $PolicyFile with the IDs shown in the Power Platform admin center (Policies > Data policies > Prebuilt connectors) before running."
    }
    $newPolicy = $raw | ConvertFrom-Json

    if ($PSCmdlet.ShouldProcess($newPolicy.displayName, 'New-DlpPolicy')) {
        $created = New-DlpPolicy -NewPolicy $newPolicy
        Write-Output "Created data policy '$($newPolicy.displayName)'."
        $created
    }

    # Optional HTTP endpoint filtering instead of blocking HTTP outright:
    # move HTTP to the Business (Confidential) group in dlp-policy.json, then
    # set endpoint rules on the policy with the connector-configurations
    # cmdlets (documented syntax):
    #
    #   New-PowerAppDlpPolicyConnectorConfigurations -TenantId $TenantId -PolicyName $PolicyName `
    #       -NewDlpPolicyConnectorConfigurations $config
    #   Set-PowerAppDlpPolicyConnectorConfigurations -TenantId $TenantId -PolicyName $PolicyName `
    #       -UpdatedConnectorConfigurations $config
    #
    # UNVERIFIED: the shape of $config. Microsoft Learn does not document it;
    # the Microsoft-owned Terraform provider sends:
    #   @{ endpointConfigurations = @(@{ connectorId = '<HTTP connector id>';
    #        endpointRules = @(@{ order = 1; behavior = 'Allow'; endpoint = 'https://api.contoso.com' },
    #                          @{ order = 2; behavior = 'Deny';  endpoint = '*' }) }) }
    # Prefer the Terraform pack (http_allowed_endpoints) for endpoint filtering.
}

# ── 2. Managed Environment agent sharing limits ──────────────────────────────
if ($EnvironmentName) {
    $environment = Get-AdminPowerAppEnvironment -EnvironmentName $EnvironmentName
    $governanceConfiguration = $environment.Internal.properties.governanceConfiguration

    if ($null -eq $governanceConfiguration -or $governanceConfiguration.protectionLevel -ne 'Standard') {
        # protectionLevel 'Standard' = Managed Environment, 'Basic' = not managed.
        throw "Environment $EnvironmentName is not a Managed Environment. Run: pac admin set-governance-config --environment $EnvironmentName --protection-level Standard"
    }

    $settings = $governanceConfiguration.settings.extendedSettings
    # Agents: individuals only (no security groups), capped viewers, no Editor grants.
    $settings | Add-Member -MemberType NoteProperty -Name 'bot-limitSharingMode' -Value 'ExcludeSharingToSecurityGroups' -Force
    $settings | Add-Member -MemberType NoteProperty -Name 'bot-maxLimitUserSharing' -Value ([string]$MaxAgentViewers) -Force
    $settings | Add-Member -MemberType NoteProperty -Name 'bot-authoringSharingDisabled' -Value 'True' -Force
    # Canvas apps and solution-aware cloud flows.
    $settings | Add-Member -MemberType NoteProperty -Name 'limitSharingMode' -Value 'excludeSharingToSecurityGroups' -Force
    $settings | Add-Member -MemberType NoteProperty -Name 'maxLimitUserSharing' -Value ([string]$MaxCanvasUsers) -Force
    $settings | Add-Member -MemberType NoteProperty -Name 'solutionCloudFlows-limitSharingMode' -Value 'disableSharing' -Force

    if ($PSCmdlet.ShouldProcess($EnvironmentName, 'Set-AdminPowerAppEnvironmentGovernanceConfiguration')) {
        Set-AdminPowerAppEnvironmentGovernanceConfiguration -EnvironmentName $EnvironmentName -UpdatedGovernanceConfiguration $governanceConfiguration
        Write-Output "Applied agent sharing limits to $EnvironmentName."
    }
}
