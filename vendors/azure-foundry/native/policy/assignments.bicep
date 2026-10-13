// ─────────────────────────────────────────────────────────────────────────────
// Built-in Azure Policy assignments for Microsoft Foundry / Azure OpenAI /
// Azure AI services, at management-group scope. Same set as
// terraform/policy.tf.
//
// Deploy:
//   az deployment mg create --management-group-id <mg> --location <region> \
//     -f assignments.bicep -p approvedModelAssetIds='["azureml://registries/azure-openai/models/gpt-5/"]'
//
// Microsoft.Authorization/policyAssignments API 2026-07-01 (template reference,
// verified 2026-10-13). Definition GUIDs and parameter names checked against
// github.com/Azure/azure-policy built-in definition JSON.
// ─────────────────────────────────────────────────────────────────────────────
targetScope = 'managementGroup'

@description('Default enforces Deny effects; DoNotEnforce evaluates without blocking (use for the first rollout).')
@allowed([
  'Default'
  'DoNotEnforce'
])
param enforcementMode string = 'Default'

@description('Effect for the CMK policy (67121cc7-...).')
@allowed([
  'Audit'
  'Deny'
  'Disabled'
])
param cmkEffect string = 'Audit'

@description('excludedKinds for the CMK policy. The built-in default excludes AIServices; empty evaluates every kind.')
param cmkExcludedKinds array = []

@description('Effect for the managed identity policy (fe3fd216-...).')
@allowed([
  'Audit'
  'Deny'
  'Disabled'
])
param managedIdentityEffect string = 'Deny'

@description('Effect for the approved-models policy (aafe3651-...).')
@allowed([
  'Audit'
  'Deny'
  'Disabled'
])
param approvedModelsEffect string = 'Deny'

@description('allowedPublishers for the approved-models policy.')
param approvedModelPublishers array = []

@description('allowedAssetIds for the approved-models policy (prefix match, case-sensitive).')
param approvedModelAssetIds array = [
  'azureml://registries/azure-openai/models/gpt-5/'
]

@description('Assign the built-in EU AI Act 2024 1689 initiative in audit mode.')
param assignEuAiActInitiative bool = true

var builtin = '/providers/Microsoft.Authorization/policyDefinitions'

var simpleAssignments = [
  {
    // AIG-07
    name: 'aigov-ai-no-local-auth'
    displayName: 'AIGov: AI Services key access disabled'
    definition: '71ef260a-8f18-47b7-abcb-62d0673d94dc'
    effect: 'Deny'
    message: 'AI Services accounts must disable key (local) authentication. Use Microsoft Entra ID.'
  }
  {
    // AIG-08
    name: 'aigov-ai-restrict-net'
    displayName: 'AIGov: AI Services restrict network access'
    definition: '037eea7a-bd0a-46c5-9a66-03aea78705d3'
    effect: 'Deny'
    message: 'AI Services accounts must disable public network access or set networkAcls.defaultAction to Deny.'
  }
  {
    // AIG-08
    name: 'aigov-ai-private-link'
    displayName: 'AIGov: AI Services use Private Link'
    definition: 'd6759c02-b87f-42b7-892e-71b3f471d782'
    effect: 'Audit'
    message: 'AI Services accounts should be reached through a private endpoint.'
  }
  {
    // AIG-13
    name: 'aigov-ai-diag-logs'
    displayName: 'AIGov: AI Services diagnostic logs'
    definition: '1b4d1c4e-934c-4703-944c-27c82c06bebb'
    effect: 'AuditIfNotExists'
    message: 'AI Services accounts must send resource logs to a diagnostic setting.'
  }
  {
    // AIG-07
    name: 'aigov-ai-managed-id'
    displayName: 'AIGov: Cognitive Services managed identity'
    definition: 'fe3fd216-4f83-4fc1-8984-2bbec80a3418'
    effect: managedIdentityEffect
    message: 'Cognitive Services accounts must have a managed identity.'
  }
]

// AIG-07 AIG-08 AIG-13
resource simple 'Microsoft.Authorization/policyAssignments@2026-07-01' = [
  for a in simpleAssignments: {
    name: a.name
    properties: {
      displayName: a.displayName
      policyDefinitionId: '${builtin}/${a.definition}'
      enforcementMode: enforcementMode
      parameters: {
        effect: {
          value: a.effect
        }
      }
      nonComplianceMessages: [
        {
          message: a.message
        }
      ]
    }
  }
]

// AIG-09
resource cmk 'Microsoft.Authorization/policyAssignments@2026-07-01' = {
  name: 'aigov-ai-cmk'
  properties: {
    displayName: 'AIGov: AI Services encrypt with CMK'
    policyDefinitionId: '${builtin}/67121cc7-ff39-4ab8-b7e3-95b84dab487d'
    enforcementMode: enforcementMode
    parameters: {
      effect: {
        value: cmkEffect
      }
      excludedKinds: {
        value: cmkExcludedKinds
      }
    }
    nonComplianceMessages: [
      {
        message: 'AI Services accounts holding regulated data must use a customer-managed key.'
      }
    ]
  }
}

// AIG-06
resource approvedModels 'Microsoft.Authorization/policyAssignments@2026-07-01' = {
  name: 'aigov-approved-models'
  properties: {
    displayName: 'AIGov: Foundry approved models only'
    policyDefinitionId: '${builtin}/aafe3651-cb78-4f68-9f81-e7e41509110f'
    enforcementMode: enforcementMode
    parameters: {
      effect: {
        value: approvedModelsEffect
      }
      allowedPublishers: {
        value: approvedModelPublishers
      }
      allowedAssetIds: {
        value: approvedModelAssetIds
      }
    }
    nonComplianceMessages: [
      {
        message: 'Only models on the approved-model register can be deployed.'
      }
    ]
  }
}

// AIG-13 AIG-08 (EU AI Act evidence). Default parameters = audit effects.
resource euAiAct 'Microsoft.Authorization/policyAssignments@2026-07-01' = if (assignEuAiActInitiative) {
  name: 'aigov-eu-ai-act'
  properties: {
    displayName: 'AIGov: EU AI Act 2024 1689 (audit)'
    policyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/1308bccf-446a-4283-a4e0-0c983fe7a572'
    enforcementMode: enforcementMode
  }
}

output simpleAssignmentIds array = [for (a, i) in simpleAssignments: simple[i].id]
output cmkAssignmentId string = cmk.id
output approvedModelsAssignmentId string = approvedModels.id
