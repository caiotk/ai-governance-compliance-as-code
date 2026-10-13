// ─────────────────────────────────────────────────────────────────────────────
// Reference hardened Microsoft Foundry account (kind AIServices) with content
// filter (raiPolicies), a sample model deployment bound to it, and diagnostic
// settings. Resource-group scope.
//
// Microsoft.CognitiveServices API version 2026-07-01 (latest stable on the
// template reference, 2026-10-13; accepted by Bicep CLI 0.48.1 without
// warnings). Property names checked against the 2026-07-01 template reference.
//
// Deploy:
//   az deployment group create -g <rg> -f foundry-account.bicep \
//     -p accountName=<name> customSubDomainName=<subdomain> logAnalyticsWorkspaceId=<id>
// ─────────────────────────────────────────────────────────────────────────────

@description('Name of the Foundry account.')
param accountName string

@description('Region. Pick one that satisfies your residency requirement (AIG-08/AIG-18).')
param location string = resourceGroup().location

@description('Globally unique custom subdomain. Required for networkAcls and Entra ID token authentication.')
param customSubDomainName string

@description('Optional IP ranges allowed through the account firewall. Empty = private endpoint only.')
param allowedIpRanges array = []

@description('Optional subnet resource IDs allowed through the account firewall.')
param allowedSubnetIds array = []

@description('networkAcls.bypass: AzureServices lets trusted Azure services through; None blocks them.')
@allowed([
  'None'
  'AzureServices'
])
param networkAclsBypass string = 'None'

@description('FQDNs the account may call when outbound access is restricted.')
param allowedFqdnList array = []

@description('Allow Foundry projects on this account.')
param allowProjectManagement bool = true

@description('Optional user-assigned identity resource ID (required for CMK at create time).')
param userAssignedIdentityId string = ''

@description('Optional CMK: Key Vault URI, e.g. https://<vault>.vault.azure.net/. Empty = Microsoft-managed keys.')
param cmkKeyVaultUri string = ''

@description('Optional CMK key name.')
param cmkKeyName string = ''

@description('Optional CMK key version. Empty = always use the latest version.')
param cmkKeyVersion string = ''

@description('Client ID of the user-assigned identity that can read the CMK key.')
param cmkIdentityClientId string = ''

@description('Log Analytics workspace resource ID for resource logs. Empty skips the diagnostic setting.')
param logAnalyticsWorkspaceId string = ''

@description('Content filter (RAI) policy name.')
param raiPolicyName string = 'aigov-baseline'

@description('Severity at which harm categories are blocked.')
@allowed([
  'Low'
  'Medium'
  'High'
])
param severityThreshold string = 'Medium'

@description('Deploy the sample model deployment.')
param deploySampleModel bool = true

@description('Sample deployment name.')
param deploymentName string = 'gpt-5'

@description('Sample model format (publisher format), e.g. OpenAI.')
param modelFormat string = 'OpenAI'

@description('Sample model name. Must also be on the approved-models allow-list (AIG-06).')
param modelName string = 'gpt-5'

@description('Sample model version. Empty = the default version at deployment time.')
param modelVersion string = ''

@description('Deployment SKU, e.g. Standard, DataZoneStandard, GlobalStandard.')
param deploymentSkuName string = 'DataZoneStandard'

@description('Deployment capacity (thousands of tokens per minute for Standard SKUs).')
param deploymentCapacity int = 10

param tags object = {}

var useUami = !empty(userAssignedIdentityId)
var useCmk = !empty(cmkKeyVaultUri) && !empty(cmkKeyName)

var harmCategories = [
  'Hate'
  'Sexual'
  'Violence'
  'Selfharm'
]

var severityFilters = flatten(map(harmCategories, c => [
  {
    name: c
    enabled: true
    blocking: true
    severityThreshold: severityThreshold
    source: 'Prompt'
  }
  {
    name: c
    enabled: true
    blocking: true
    severityThreshold: severityThreshold
    source: 'Completion'
  }
]))

var binaryFilters = [
  {
    name: 'Jailbreak'
    enabled: true
    blocking: true
    source: 'Prompt'
  }
  {
    name: 'Protected Material Text'
    enabled: true
    blocking: true
    source: 'Completion'
  }
  {
    name: 'Protected Material Code'
    enabled: true
    blocking: true
    source: 'Completion'
  }
]

// AIG-07 AIG-08 AIG-09
resource account 'Microsoft.CognitiveServices/accounts@2026-07-01' = {
  name: accountName
  location: location
  kind: 'AIServices'
  sku: {
    name: 'S0'
  }
  identity: useUami
    ? {
        type: 'SystemAssigned, UserAssigned'
        userAssignedIdentities: {
          '${userAssignedIdentityId}': {}
        }
      }
    : {
        type: 'SystemAssigned'
      }
  properties: {
    customSubDomainName: customSubDomainName
    // AIG-07: Entra ID only.
    disableLocalAuth: true
    // AIG-08: no public endpoint, default-deny firewall, outbound allow-list.
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: networkAclsBypass
      ipRules: [for ip in allowedIpRanges: { value: ip }]
      virtualNetworkRules: [for s in allowedSubnetIds: { id: s }]
    }
    restrictOutboundNetworkAccess: true
    allowedFqdnList: allowedFqdnList
    allowProjectManagement: allowProjectManagement
    // AIG-09: optional customer-managed key.
    encryption: useCmk
      ? {
          keySource: 'Microsoft.KeyVault'
          keyVaultProperties: {
            keyVaultUri: cmkKeyVaultUri
            keyName: cmkKeyName
            keyVersion: empty(cmkKeyVersion) ? null : cmkKeyVersion
            identityClientId: empty(cmkIdentityClientId) ? null : cmkIdentityClientId
          }
        }
      : null
  }
  tags: tags
}

// AIG-10
resource raiPolicy 'Microsoft.CognitiveServices/accounts/raiPolicies@2026-07-01' = {
  parent: account
  name: raiPolicyName
  properties: {
    basePolicyName: 'Microsoft.Default'
    mode: 'Blocking'
    contentFilters: concat(severityFilters, binaryFilters)
  }
}

// AIG-06 AIG-10 AIG-15
resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2026-07-01' = if (deploySampleModel) {
  parent: account
  name: deploymentName
  sku: {
    name: deploymentSkuName
    capacity: deploymentCapacity
  }
  properties: {
    model: {
      format: modelFormat
      name: modelName
      version: empty(modelVersion) ? null : modelVersion
    }
    raiPolicyName: raiPolicy.name
    versionUpgradeOption: 'NoAutoUpgrade'
  }
}

// AIG-13
resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  scope: account
  name: 'aigov-to-log-analytics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output accountId string = account.id
output endpoint string = account.properties.endpoint
output principalId string = account.identity.principalId
output raiPolicyName string = raiPolicy.name
