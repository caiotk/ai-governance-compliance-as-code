// Azure API Management backends for an LLM pool with circuit breakers and
// priority-based failover (primary region → secondary region → other vendor).
// Controls: AIG-17 (resilience), AIG-08 (single egress point), AIG-13.
// Verified 2026-10-13 (docs/sources/finops-bcp-dr.md §2.3): Microsoft.ApiManagement/service/backends
// @2023-09-01-preview — type 'Pool', pool.services[].{id, priority, weight}, circuitBreaker.rules[]
// {failureCondition {count|percentage, interval, statusCodeRanges, errorReasons}, tripDuration, acceptRetryAfter}.
// Lower-priority groups are used only when every backend in higher groups has tripped.
// Terraform's azurerm_api_management_backend has no pool type, hence Bicep.

param apimName string
param primaryUrl string      // e.g. https://aoai-prod-weu.openai.azure.com/openai
param secondaryUrl string    // e.g. https://aoai-prod-sdc.openai.azure.com/openai
@description('Optional third backend (another vendor behind the LiteLLM broker, or a Data Zone deployment).')
param tertiaryUrl string = ''

resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' existing = {
  name: apimName
}

var breaker = {
  rules: [
    {
      name: 'llm-breaker'
      failureCondition: {
        count: 5
        interval: 'PT1M'
        statusCodeRanges: [
          { min: 429, max: 429 }
          { min: 500, max: 599 }
        ]
        errorReasons: [ 'Server errors' ]
      }
      tripDuration: 'PT2M'
      acceptRetryAfter: true
    }
  ]
}

resource primary 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' = {
  parent: apim
  name: 'llm-primary'
  properties: {
    url: primaryUrl
    protocol: 'http'
    circuitBreaker: breaker
  }
}

resource secondary 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' = {
  parent: apim
  name: 'llm-secondary'
  properties: {
    url: secondaryUrl
    protocol: 'http'
    circuitBreaker: breaker
  }
}

resource tertiary 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' = if (!empty(tertiaryUrl)) {
  parent: apim
  name: 'llm-tertiary'
  properties: {
    url: tertiaryUrl
    protocol: 'http'
    circuitBreaker: breaker
  }
}

resource pool 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' = {
  parent: apim
  name: 'llm-pool'
  properties: {
    description: 'LLM backend pool: priority 1 primary region, priority 2 secondary region, priority 3 alternate vendor'
    type: 'Pool'
    pool: {
      services: concat([
        { id: primary.id, priority: 1, weight: 100 }
        { id: secondary.id, priority: 2, weight: 100 }
      ], empty(tertiaryUrl) ? [] : [
        { id: tertiary.id, priority: 3, weight: 100 }
      ])
    }
  }
}

output poolId string = pool.id
