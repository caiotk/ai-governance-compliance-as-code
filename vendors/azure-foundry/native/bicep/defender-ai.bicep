// ─────────────────────────────────────────────────────────────────────────────
// Defender for Cloud "threat protection for AI services" on a subscription.
// AIG-02 AIG-13 AIG-16
//
// Deploy:
//   az deployment sub create --location <region> -f defender-ai.bicep
//
// Microsoft.Security/pricings 2024-01-01 (latest stable). The pricing name
// equals the plan name, "AI".
// ─────────────────────────────────────────────────────────────────────────────
targetScope = 'subscription'

@description('Expose suspicious prompt/response snippets as alert evidence (AIPromptEvidence extension).')
param enablePromptEvidence bool = false

// AIG-02 AIG-13 AIG-16
resource defenderForAi 'Microsoft.Security/pricings@2024-01-01' = {
  name: 'AI'
  properties: {
    pricingTier: 'Standard'
    extensions: enablePromptEvidence
      ? [
          {
            name: 'AIPromptEvidence'
            isEnabled: 'True'
          }
        ]
      : []
  }
}

output pricingId string = defenderForAi.id
