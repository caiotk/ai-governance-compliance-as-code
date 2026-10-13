# BCP/DR for LLM workloads — verified facts (push-button failover, policy-as-code)

Collected 2026-10-13. Every item labelled **primary** (read directly from the first-party source on this date) or **UNVERIFIED** (could not read the first-party text). Terraform facts come from `hashicorp/terraform-provider-*` `main` branch docs on GitHub (raw). Quotes are verbatim unless marked (paraphrase).

---

## 1. Amazon Bedrock — cross-Region inference, Terraform, quotas, Guardrails, service tiers

### 1.1 Inference profile ID formats — primary

Source: model card (markdown) https://docs.aws.amazon.com/bedrock/latest/userguide/model-card-anthropic-claude-haiku-4-5.md and https://docs.aws.amazon.com/bedrock/latest/userguide/model-card-anthropic-claude-sonnet-4.md

| Prefix | Type | Example (verbatim from model cards) |
|---|---|---|
| `us.` | Geo (US) | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |
| `eu.` | Geo (EU) | `eu.anthropic.claude-haiku-4-5-20251001-v1:0` |
| `apac.` | Geo (APAC) | `apac.anthropic.claude-sonnet-4-20250514-v1:0` |
| `au.` | Geo (AU) | `au.anthropic.claude-haiku-4-5-20251001-v1:0` |
| `jp.` | Geo (JP) | `jp.anthropic.claude-haiku-4-5-20251001-v1:0` |
| `in.` | Geo (India) | `in.anthropic.claude-haiku-4-5-20251001-v1:0` |
| `global.` | Global | `global.anthropic.claude-haiku-4-5-20251001-v1:0` |
| `ca.`, `uk.`, `gov.` | Geo (seen only as Guardrails profile prefixes, see 1.6) | `ca.guardrail.v1:0`, `uk.guardrail.v1:0`, `gov.guardrail.v1:0` |

Model-card table header (verbatim): `| **Endpoint** | **Model ID** | **In-Region endpoint URL** | **Geo inference ID** | **Global inference ID** |` — rows: `bedrock-runtime` (geo/global profile IDs) and `bedrock-mantle | anthropic.claude-haiku-4-5 | https://bedrock-mantle.{region}.api.aws/anthropic/v1/messages`.

> "For this model, the `bedrock-runtime` endpoint requires a geo or global inference profile ID. The bare model ID isn't supported for on-demand throughput. Geo and global inference profiles can route requests outside the source Region and don't provide single-Region data residency. For single-Region inference, use the `bedrock-mantle` endpoint with the bare model ID." (Claude Haiku 4.5 model card)

> "Amazon Bedrock offers three inference options: **In-Region** keeps requests within a single Region for strict compliance, **Geo Cross-Region** routes across Regions within a geography (such as US, EU, and APAC) while respecting data residency, and **Global Cross-Region** routes anywhere worldwide when there are no residency constraints." (same model card, "Regional availability at a glance")

Geo routing example (Haiku 4.5, Geo: AU): source `ap-southeast-6 (New Zealand)` → destinations `ap-southeast-2 (Sydney), ap-southeast-4 (Melbourne), ap-southeast-6 (New Zealand)`; source `ap-southeast-2` → `ap-southeast-2, ap-southeast-4`. Global profile destinations for Haiku 4.5 include 8 Americas, 12 EMEA and 13 Asia-Pacific Regions (incl. `ap-southeast-6 (New Zealand)`).

### 1.2 How to find profile IDs — primary

Source: https://docs.aws.amazon.com/bedrock/latest/userguide/inference-profiles-support.html

- "Each model's inference profile IDs and Regional availability are now documented on the model's detail page." (models at a glance: https://docs.aws.amazon.com/bedrock/latest/userguide/model-cards.html ; regional availability: https://docs.aws.amazon.com/bedrock/latest/userguide/models-region-compatibility.html)
- "**Query a source Region:** Send a ListInferenceProfiles request to an Amazon Bedrock control plane endpoint in the Region that you plan to use."

```
aws bedrock list-inference-profiles --region ap-southeast-2 --type-equals SYSTEM_DEFINED \
  --query "inferenceProfileSummaries[?status=='ACTIVE' && starts_with(inferenceProfileId, 'au.')].[inferenceProfileId,inferenceProfileName]" --output table
aws bedrock get-inference-profile --region ap-southeast-2 --inference-profile-identifier inference-profile-id --query 'models[].modelArn'
```

> **Important:** "If you have data residency requirements, call GetInferenceProfile from every source Region that you plan to use and verify all destination Regions in the response. Available inference profiles and destination Regions can differ depending on the source Region. Don't rely on the geographic prefix in an inference profile ID alone to determine where requests can be routed."

Other verbatim facts (same page): "If any destination Region in a cross-Region inference profile is blocked in your SCPs, the request will fail even if other Regions remain allowed." / "if an inference profile is tied to a geography (such as US, EU, or APAC), its destination Region list will never change." / Global profile destination list "can change over time".

### 1.3 Cross-Region inference overview — primary

Source: https://docs.aws.amazon.com/bedrock/latest/userguide/cross-region-inference.html

- "There's no additional routing cost for using cross-Region inference. The price is calculated based on the Region from which you call an inference profile."
- "Inference profiles currently don't support Provisioned Throughput."
- "Cross-Region inference can route requests to AWS Regions that are not manually enabled in your AWS account."
- Global profile: data residency "Any supported AWS commercial Region worldwide"; cost "Approximately 10% savings"; SCP requirement `Allow "aws:RequestedRegion": "unspecified"`.
- Audit: "CloudTrail logs all cross-Region inference requests in your source Region. Look for the `additionalEventData.inferenceRegion` field to identify where requests were processed."

### 1.4 Terraform (hashicorp/terraform-provider-aws, main) — primary

`aws_bedrock_inference_profile` (resource) — https://github.com/hashicorp/terraform-provider-aws/blob/main/website/docs/r/bedrock_inference_profile.html.markdown

| Argument | Req | Verbatim description |
|---|---|---|
| `model_source` | Required | "Source of the model this inference profile will track metrics and cost for." Block with `copy_from` - (Required) "ARN of the model." |
| `name` | Required | "Name of the inference profile." |
| `description` | Optional | "Description of the inference profile." |
| `region` | Optional | "Region where this resource will be managed." |
| `tags` | Optional | "Key-value mapping of resource tags for the inference profile." |

Exported: `arn`, `created_at`, `id`, `models` (list of `model_arn`), `status` ("`ACTIVE` means that the inference profile is available to use."), `tags_all`, `type` (`SYSTEM_DEFINED` / `APPLICATION`), `updated_at`. Timeouts create/update/delete `5m`. Import by `id`.

Example `copy_from` values from the doc: `arn:aws:bedrock:us-west-2::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0` and (commented) `arn:aws:bedrock:eu-central-1:${data.aws_caller_identity.current.account_id}:inference-profile/eu.anthropic.claude-3-5-sonnet-20240620-v1:0` ("Include account ID to use inference profiles").

`aws_bedrock_inference_profiles` (data source) — https://github.com/hashicorp/terraform-provider-aws/blob/main/website/docs/d/bedrock_inference_profiles.html.markdown

| Argument | Verbatim |
|---|---|
| `region` (Optional) | "Region where this resource will be managed." |
| `type` (Optional) | "Filters for inference profiles that match the type you specify. Valid values are: `SYSTEM_DEFINED`, `APPLICATION`." |

Attribute `inference_profile_summaries` → `created_at`, `description`, `inference_profile_arn`, `inference_profile_id`, `inference_profile_name`, `models` (`model_arn`), `status`, `type`, `updated_at`.

### 1.5 Quotas / regional availability / resilience page — primary

- Quotas: https://docs.aws.amazon.com/bedrock/latest/userguide/quotas.html — "Model inference in Amazon Bedrock is controlled by quotas on token usage." / "Traffic to the two endpoints is tracked against separate quotas, even when calling the same underlying model." (bedrock-runtime vs bedrock-mantle) / "Quota increases aren't granted automatically." Page does NOT state per-inference-profile quota names — UNVERIFIED.
- Regional availability by model: https://docs.aws.amazon.com/bedrock/latest/userguide/models-region-compatibility.html (replaces the former `models-regions.html`, which now says "Information previously on this page has moved.")
- Resilience page: https://docs.aws.amazon.com/bedrock/latest/userguide/disaster-recovery-resiliency.html — title "Resilience in Amazon Bedrock"; content is the generic AWS statement: "The AWS global infrastructure is built around AWS Regions and Availability Zones." It contains **no** Bedrock-specific multi-Region/DR guidance; cross-Region inference is the only documented multi-Region routing mechanism (1.3).
- SLA: https://aws.amazon.com/bedrock/sla/ ("Last Updated: October 4, 2023") — Service Commitment per "AWS region"; credit tiers "Less than 99.9% but greater than or equal to 99.0%" and "Less than 99.0% but greater than or equal to 95.0%"; "“Monthly Uptime Percentage” for a given AWS region is calculated as the average of the Availability for all 5-minute intervals in a monthly billing cycle."

### 1.6 Guardrails cross-Region — primary

Source: https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-cross-region.html ("Distribute guardrail inference across AWS Regions") and API ref https://docs.aws.amazon.com/bedrock/latest/APIReference/API_CreateGuardrail.html

- "routes inference requests during guardrail policy evaluation to an AWS Region within your geography." / "There's no additional cost for using cross-Region inferencing."
- "Cross-Region inference requests are kept within the Regions that are part of the geography where the data originally resides. For example, a request made in the US is kept within Regions in the US."
- "Although your guardrail configuration remains stored only in the primary Region, your input prompts and output results might move outside of your primary Region when using cross-Region inference."
- API: `CreateGuardrail`/`UpdateGuardrail` request field `crossRegionConfig` (type `GuardrailCrossRegionConfig`) with member `guardrailProfileIdentifier`.
- Guardrail profile IDs (from https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-cross-region-support.html): `us.guardrail.v1:0`, `eu.guardrail.v1:0`, `apac.guardrail.v1:0`, `au.guardrail.v1:0`, `ca.guardrail.v1:0`, `uk.guardrail.v1:0`, `gov.guardrail.v1:0`.

### 1.7 Service tiers — primary

Source: https://docs.aws.amazon.com/bedrock/latest/userguide/service-tiers-inference.html ("Service tiers for optimizing performance and cost") and API type https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_ServiceTier.html

| Tier | Request value | Verbatim |
|---|---|---|
| Reserved | `reserved` | "The Reserved tier provides the ability to reserve prioritized compute capacity for your mission-critical applications that cannot tolerate any downtime." |
| Priority | `priority` | "The Priority tier delivers the fastest response times for a price premium over standard on-demand pricing." / "Priority tier requests are prioritized over Standard and Flex tier requests." |
| Standard | `default` (or omit) | "The Standard tier provides consistent performance for everyday AI tasks" / "By default all inference requests are routed to the Standard tier" |
| Flex | `flex` | "For workloads that can handle longer processing times, the Flex tier offers cost-effective processing for a pricing discount." |

Converse API: request field `serviceTier` of type `ServiceTier`, member `type` — "Valid Values: priority | default | flex | reserved". Model cards show it as JSON `"service_tier": "default|priority|flex"` (Haiku 4.5 card: Standard and Reserved supported; Priority and Flex not supported for that model).

---

## 2. Azure OpenAI / Microsoft Foundry

### 2.1 Deployment types — primary

Source: https://learn.microsoft.com/en-us/azure/ai-foundry/openai/how-to/deployment-types ("Understanding deployment types in Microsoft Foundry Models")

| Deployment type | SKU code | Data processing (verbatim) | Billing |
|---|---|---|---|
| Global Standard | `GlobalStandard` | Any Azure region | Pay-per-token |
| Global Provisioned | `GlobalProvisionedManaged` | Any Azure region | Reserved PTU |
| Global Batch | `GlobalBatch` | Any Azure region | 50% discount, 24-hr |
| Data Zone Standard | `DataZoneStandard` | Within data zone | Pay-per-token |
| Data Zone Provisioned | `DataZoneProvisionedManaged` | Within data zone | Reserved PTU |
| Data Zone Batch | `DataZoneBatch` | Within data zone | 50% discount |
| Standard | `Standard` | Within Azure geography | Pay-per-token |
| Regional Provisioned | `ProvisionedManaged` | Within Azure geography | Reserved PTU |
| Developer | `DeveloperTier` | Any Azure region | "24-hour lifetime, no SLA or data-residency guarantee" |

Data residency (verbatim, "Important" box): "**Data residency for all deployment types**: Data stored at rest remains in the designated Azure geography. However, inferencing data is processed as follows: **Global** types: May be processed in any Azure region / **Data Zone** types: The service processes data only within the Microsoft-specified data zone (US, EU, or Asia Pacific (APAC)). / **Standard and Regional Provisioned** types: Prompts and responses are processed within the customer-specified Azure geography and might be processed between regions within that geography for operational purposes."

Data zones: "**United States**: The service processes data anywhere within the US. **European Union**: The service processes data within the Azure EU Data Boundary. **Asia Pacific**: The service processes data within the APAC data zone." / "Microsoft can add regions to either data zone without prior notice".

Failover semantics (verbatim Note): "With Global Standard and Data Zone Standard deployment types, if the primary region experiences an interruption in service, all traffic initially routed to this region is affected." → links to the HA/DR guide (2.2).

Processing tiers: "Global Standard supports request-level processing tiers. Use Flex processing for lower-cost, delay-tolerant workloads, or use Priority processing for faster response times on a pay-as-you-go basis." / "Data Zone Standard supports priority processing".

SLA: "SLA guarantees vary by deployment type. Provisioned types provide guaranteed throughput and lower latency variance. Standard types offer best-effort service. Developer deployments don't include an SLA." SLA doc link: https://www.microsoft.com/licensing/docs/view/Service-Level-Agreements-SLA-for-Online-Services (percentages UNVERIFIED — not read).

### 2.2 Official HA/DR guidance — primary

Source: https://learn.microsoft.com/en-us/azure/ai-foundry/how-to/high-availability-resiliency ("High availability and resiliency for Microsoft Foundry projects and Agent Services")

- "**Important** Foundry itself doesn't provide automatic failover or disaster recovery."
- "Global Standard and Data Zone Standard deployments can route inference across their permitted processing scope, but that routing doesn't replace application-level regional failover. Use an API gateway or application logic when your workload must switch between regional project or resource endpoints."
- "If your data-residency requirements allow it, prefer Global Standard deployments. Data Zone deployments (US/EU) are the next best option".
- Step 5: "If a regional outage makes the primary deployment unreachable, route traffic to the secondary deployment by using your application or Generative AI Gateway failover logic. — Use a Generative AI Gateway that supports load balancing and the circuit-breaker pattern, such as Azure API Management, in front of the Azure OpenAI endpoints to minimize disruption during a regional outage."
- PTU: "Place your primary enterprise PTU deployment in a different region than your primary Standard Zone deployment." / "PTU spillover is documented for routing overage requests to a corresponding Standard deployment; don't assume automatic PTU-to-PTU failover."
- Topologies named: "Hot/warm: The primary region is active. The secondary region has critical resources (for example, deployed models) ready to start." / "Hot/cold: ... Deploy resources such as models, model deployments, and pipelines manually."
- Gateway provides: "**Load balancing** across multiple Azure OpenAI endpoints. **Circuit-breaker pattern** to detect and route around unhealthy endpoints automatically. **Rate limiting and throttling** ... **Centralized logging and observability** ... **Priority routing**".

Architecture Center: https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/azure-openai-gateway-multi-backend ("Use a gateway in front of multiple model deployments or instances") — "API Management is preferred because the service provides a PaaS-based solution that uses built-in features such as back-end pools, circuit-breaking policies, and custom policies if needed." / "The gateway should retry the current request against another back-end instance in the pool when a fault occurs, before falling back to returning a gateway error." / "handle `429`, `500`, and `503` HTTP status codes as a signal to circuit-break".

AI gateway capabilities: https://learn.microsoft.com/en-us/azure/api-management/genai-gateway-capabilities — "The backend load balancer supports round-robin, weighted, priority-based, and session-aware load balancing." / "The backend circuit breaker features dynamic trip duration, applying values from the `Retry-After` header provided by the backend."

### 2.3 APIM backend pool + circuit breaker — primary

Source: https://learn.microsoft.com/en-us/azure/api-management/backends ("Azure API Management Backends")

Load balancing options (verbatim table):

| Option | Behaviour |
|---|---|
| Round-robin | "Requests are distributed evenly across the backends in the pool by default." |
| Weighted | "Assign weights to the backends in the pool, and distribute requests based on the relative weight of each backend. Useful for scenarios such as blue-green deployments." |
| Priority-based | "Organize backends into priority groups. Send requests to higher priority groups first; within a group, distribute requests evenly or according to assigned weights." |

Failover rule: "The API Management service uses backends in lower priority groups only when all backends in higher priority groups are unavailable because circuit breaker rules are tripped."

Limits: "You can include up to 30 backends in a pool." / "Currently, you can configure only one rule for a backend circuit breaker." / "Currently, the backend circuit breaker isn't supported in the **Consumption** tier of API Management." / "backend load balancing is approximate. Different instances of the gateway don't synchronize".

Circuit breaker: "When the circuit breaker trips, API Management stops sending requests to the backend service for a defined time, and returns a 503 Service Unavailable response to the client." / "With Azure OpenAI backends, implement circuit breaker rules to handle the `429` responses and accept the `Retry-After` duration."

Bicep (verbatim, API version `2023-09-01-preview`):

```bicep
resource symbolicname 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' = {
  name: 'myAPIM/myBackend'
  properties: {
    url: 'https://mybackend.com'
    protocol: 'http'
    circuitBreaker: {
      rules: [
        {
          failureCondition: {
            count: 3
            errorReasons: [ 'Server errors' ]
            interval: 'PT1H'
            statusCodeRanges: [ { min: 500, max: 599 } ]
          }
          name: 'myBreakerRule'
          tripDuration: 'PT1H'
          acceptRetryAfter: true
        }
      ]
    }
  }
}

resource symbolicname 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' = {
  name: 'myAPIM/myBackendPool'
  properties: {
    description: 'Load balancer for multiple backends'
    type: 'Pool'
    pool: {
      services: [
        { id: '/subscriptions/<subscriptionID>/resourceGroups/<resourceGroupName>/providers/Microsoft.ApiManagement/service/<APIManagementName>/backends/backend-1', priority: 1, weight: 3 }
        { id: '.../backends/backend-2', priority: 1, weight: 1 }
      ]
      // optional: sessionAffinity: { sessionId: { source: 'Cookie', name: 'SessionId' } }
    }
  }
}
```

"Set the `type` property of the backend entity to `Pool` and specify the backends in the pool." Policy context: `context.Backend.Type` — "The type of the backend: `Single` or `Pool`."

### 2.4 APIM `retry` policy — primary

Source: https://learn.microsoft.com/en-us/azure/api-management/retry-policy

```xml
<retry condition="Boolean expression or literal" count="number of retry attempts" interval="retry interval in seconds"
       max-interval="maximum retry interval in seconds" delta="retry interval delta in seconds" first-fast-retry="boolean expression or literal">
  <!-- One or more child policies. No restrictions. -->
</retry>
```

| Attribute | Required | Verbatim |
|---|---|---|
| `condition` | Yes | "Specifies whether retries should be stopped (`false`) or continued (`true`)." |
| `count` | Yes | "A positive number between 1 and 50 specifying the number of retries to attempt." |
| `interval` | Yes | "wait interval between the retry attempts" |
| `max-interval` | No | "maximum wait interval ... used to implement an exponential retry algorithm" |
| `delta` | No | "wait interval increment ... linear and exponential retry algorithms" |
| `first-fast-retry` | No (default `false`) | "If set to `true`, the first retry attempt is performed immediately." |

Sections: inbound, outbound, backend, on-error. Example condition: `condition="@(context.Response.StatusCode == 500)"`. Note: the Backends page itself does not mention `retry`; the pattern "retry against another backend in the pool" is stated in the Architecture Center page (2.2).

### 2.5 Terraform `azurerm_api_management_backend` — primary (hashicorp/terraform-provider-azurerm main)

Source: https://github.com/hashicorp/terraform-provider-azurerm/blob/main/website/docs/r/api_management_backend.html.markdown (API provider `Microsoft.ApiManagement` - `2024-05-01`)

Arguments: `name`, `api_management_name`, `resource_group_name` (Required, ForceNew); `protocol` (Required, "`http` or `soap`"); `url` (Required); `circuit_breaker_rule` (Optional); `credentials`, `description`, `proxy`, `resource_id`, `service_fabric_cluster`, `title`, `tls` (Optional).

`circuit_breaker_rule` block: `name` (Required), `trip_duration` (Required, ISO 8601), `failure_condition` (Required), `accept_retry_after_enabled` (Optional, default `false`). `failure_condition`: `interval_duration` (Required), `count` (Optional, 1–10000) **or** `percentage` (Optional, 1–100) — "Exactly one of `percentage` or `count` must be specified."; `error_reasons` (Optional), `status_code_range` (`min`/`max`, 200–599) — "At least one of `status_code_range`, and `error_reasons` must be set."

**No `type`/`pool` argument exists** in the resource schema (confirmed in `internal/services/apimanagement/api_management_backend_resource.go` — only `circuit_breaker_rule` is present; no `type`, `pool`, or `services`). Terraform cannot create a `type = Pool` backend with `azurerm_api_management_backend`. Alternatives: `Microsoft.ApiManagement/service/backends@2023-09-01-preview` (or later) via Bicep/ARM as in 2.3, or Terraform `azapi_resource` (AzAPI provider) targeting the same ARM type (AzAPI usage not verified here — UNVERIFIED).

### 2.6 Terraform `azurerm_cognitive_deployment` — primary

Source: https://github.com/hashicorp/terraform-provider-azurerm/blob/main/website/docs/r/cognitive_deployment.html.markdown (API provider `Microsoft.CognitiveServices` - `2026-03-01`)

| Argument | Verbatim |
|---|---|
| `name` (Required) | ForceNew |
| `cognitive_account_id` (Required) | ForceNew |
| `model` (Required, ForceNew) | `format` (Required; e.g. `OpenAI`, "found by running `az cognitiveservices account list-models`"), `name` (Required), `version` (Optional; "If `version` is not specified, the default version of the model at the time will be assigned.") |
| `sku` (Required) | `name` (Required): "Possible values include `Standard`, `DataZoneBatch`, `DataZoneStandard`, `DataZoneProvisionedManaged`, `GlobalBatch`, `GlobalProvisionedManaged`, `GlobalStandard`, and `ProvisionedManaged`." ForceNew. `tier`, `size`, `family` (Optional). `capacity` (Optional): "Tokens-per-Minute (TPM). The unit of measure for this field is in the thousands of Tokens-per-Minute. Defaults to `1`". |
| `dynamic_throttling_enabled` (Optional) | "Whether dynamic throttling is enabled." |
| `rai_policy_name` (Optional) | "The name of RAI policy." |
| `version_upgrade_option` (Optional) | "Possible values are `OnceNewDefaultVersionAvailable`, `OnceCurrentVersionExpired`, and `NoAutoUpgrade`. Defaults to `OnceNewDefaultVersionAvailable`." |

Note (verbatim): "`DataZoneProvisionedManaged`, `GlobalProvisionedManaged`, and `ProvisionedManaged` are purchased on-demand at an hourly basis based on the number of deployed PTUs ... Currently, this step [reservation purchase] cannot be completed using Terraform." No Terraform argument exists for `spilloverDeploymentName` (see 2.7) — UNVERIFIED whether supported via `azapi`.

### 2.7 PTU spillover — primary

Source: https://learn.microsoft.com/en-us/azure/ai-foundry/openai/how-to/spillover-traffic-management

- "When your provisioned deployment is fully utilized and returns non-200 responses (such as a `429` when PTUs are exhausted), spillover redirects those requests to the standard deployment".
- Deployment-level: ARM property `spilloverDeploymentName` — "must be set to the name of a standard deployment within the same Azure OpenAI resource as your provisioned deployment." (PUT `.../deployments/{name}?api-version=2024-10-01`, body `{"sku":{"name":"GlobalProvisionedManaged","capacity":100},"properties":{"spilloverDeploymentName":"spillover-standard-deployment", ...}}`).
- Per-request: header `x-ms-spillover-deployment`; response headers `x-ms-spillover-from-deployment`, `x-ms-spillover-error` ("contains the response code from the provisioned deployment that triggered the spillover (for example 429, 500, or 503)").

---

## 3. Google Vertex AI / Gemini Enterprise Agent Platform

Note: `cloud.google.com/vertex-ai/generative-ai/docs/...` URLs now 302-redirect to `docs.cloud.google.com/gemini-enterprise-agent-platform/...` (observed 2026-10-13).

### 3.1 Global vs regional endpoints — primary

Source: https://docs.cloud.google.com/gemini-enterprise-agent-platform/resources/locations

- "Google and Partner models and generative AI features on Agent Platform are exposed as specific regional endpoints and a global endpoint. Global endpoints cover the entire world and provide higher availability and reliability than single regions."
- "**Important:** Endpoints don't guarantee data residency or in-region ML processing."
- Global endpoint: "Selecting a global endpoint for your requests can improve overall availability and reduce resource exhausted (429) errors. Don't use the global endpoint if you have ML processing requirements, because you can't control or know which region your ML processing requests are sent to when a request is made."
- URL form: `https://aiplatform.googleapis.com/v1/projects/${GOOGLE_CLOUD_PROJECT}/locations/global/publishers/google/models/${MODEL_ID}:generateContent` "instead of a service endpoint prepended with `https://${GOOGLE_CLOUD_LOCATION}-aiplatform.googleapis.com`." Location value: `global`.
- Limitations on global endpoint (verbatim list): "Tuning / Batch prediction for Anthropic and OpenMaaS models / Retrieval-augmented generation (RAG) corpus (RAG requests are supported)"; "Usage of the global endpoint with Provisioned Throughput is available only for the following models:" (model list on page).
- Partner models: "The global endpoint can have a separate set of quotas from the regional endpoint and doesn't support data residency requirements."

### 3.2 Data residency statement — primary

Source: https://docs.cloud.google.com/gemini-enterprise-agent-platform/resources/data-residency

- "Data stored at rest in the customer selected location remains at rest in that location, independent of the Agent Platform endpoint called by that customer's request."
- "Requests submitted to a global endpoint may be processed in any Google Cloud location around the world, and therefore don't provide any data residency guarantees."
- "**Jurisdictional multi-region endpoints**: When you use jurisdictional endpoints, ML processing stays within that specific geographical region (such as the United States or the European Union)." / "The European Union multi-region (`eu`) endpoint strictly covers data residency within EU member states. Geographies outside the European Union political boundary, including the United Kingdom and Switzerland, are excluded from this endpoint."
- "**Locational endpoints**: These endpoints (like `us-central1`, `europe-west1`) ensure that ML processing remains entirely within the broader multi-regional or country jurisdiction associated with that region".
- "**Global endpoints**: Global endpoints route and process data anywhere globally ... they don't provide regional isolation or data residency guarantees."

### 3.3 Provisioned Throughput overflow — primary

Source: https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/provisioned-throughput/use-provisioned-throughput

- "**Default behavior** If a request exceeds the remaining Provisioned Throughput quota, the entire request is processed as an on-demand request by default and is billed at the pay-as-you-go rate. When this occurs, the traffic appears as spillover on the monitoring dashboards." / "You don't have to change your code to begin consuming your order as long as you are consuming it in the region provisioned."
- "**Use only Provisioned Throughput** ... Requests which exceed the Provisioned Throughput order amount return an error 429. When sending requests to the API, set the X-Vertex-AI-LLM-Request-Type HTTP header to dedicated."
- "**Use only pay-as-you-go** ... set the X-Vertex-AI-LLM-Request-Type HTTP header to shared."
- Monitoring dimension `request_type`: `dedicated`, `spillover`, `shared`. Metric path prefix `aiplatform.googleapis.com/publisher/online_serving`.
- Value `both` for the header: NOT found on this page — UNVERIFIED.
- Multi-region PT (data-residency page): "you can deploy a single Provisioned Throughput commitment that covers your entire jurisdictional boundary (such as the United States)."

### 3.4 SLA — primary

- Gemini on Vertex SLA: https://cloud.google.com/vertex-ai/generative-ai/sla — "Gemini Online Inference API on Gemini Enterprise Agent Platform Service Level Agreement (SLA)": Covered Service "generateContent and streamGenerateContent methods" — Monthly Uptime Percentage **99.5%** (footnote: models designated for shorter availability 95%). "Downtime" = "more than a five percent Error Rate and is measured based on server side Error Rate." Separate latency SLO (99% Monthly Latency Target Attainment) for Provisioned Throughput on the "Global Endpoint" (Covered Endpoint).
- Vertex AI Platform SLA: https://cloud.google.com/vertex-ai/sla — covers Training/Deployment/Batch Prediction (≥99.9%), Custom Model Online Prediction ≥99.5% (2+ nodes), etc.; does not list Gemini.
- SLA index: https://cloud.google.com/terms/sla

### 3.5 Terraform (hashicorp/terraform-provider-google main) — primary

Gemini (Google publisher model) inference has **no** Terraform resource; you call `publishers/google/models/...` directly via the regional or `global` endpoint. Resources that do exist (confirmed present under `website/docs/r/`): `google_vertex_ai_endpoint`, `google_vertex_ai_endpoint_with_model_garden_deployment` (args seen: `publisher_model_name`, `hugging_face_model_id`, `location`, `model_config { accept_eula }`; for self-deployed Model Garden models, not Gemini API), `google_vertex_ai_deployment_resource_pool`, `google_vertex_ai_index`, `google_vertex_ai_feature_online_store`, `google_vertex_ai_rag_engine_config`. No Terraform resource for Provisioned Throughput orders was found — UNVERIFIED (not exhaustively searched).

---

## 4. OpenAI and Anthropic first-party APIs

### 4.1 OpenAI — primary

- Status page: https://status.openai.com (HTTP 200).
- Scale Tier page https://openai.com/api-scale-tier/ : "Scale Tier traffic offers a 99.9% uptime SLA and prioritized compute." / "If you exceed your quota, additional requests will be processed using the regular Standard processing service." / "As of July 2026 traffic sent to Scale Tier will automatically spill over to Fast mode." / "For GPT‑5.6 and future model releases, see Reserved Tier".
- Fast/Priority processing https://developers.openai.com/api/docs/guides/priority-processing : `service_tier: "fast"` or `"priority"`; "If your traffic ramps too fast, the system may downgrade some Fast mode requests to standard speeds and charge standard rates. When this happens, the response contains `service_tier: "default"`." / "Fast mode for GPT-6 Astra does not include a latency SLA. For GPT-5.6 and earlier models, Fast mode and Scale Tier receive the same service-level agreement treatment".
- Data residency https://developers.openai.com/api/docs/guides/your-data : "Data residency controls are a project configuration option" ; "Data residency endpoints are charged a 10% uplift for models released on or after March 5, 2026". Per-request region selection via prefixed domain with a Global-project key.

| Region | Domain prefix | Regional storage | Regional processing |
|---|---|---|---|
| United States | `us.api.openai.com` | Yes | Yes |
| Europe (EEA + Switzerland) | `eu.api.openai.com` | Yes | Yes (ZDR/MAM etc. required) |
| Australia | `au.api.openai.com` | Yes | No |
| Canada | `ca.api.openai.com` | Yes | No |
| Japan | `jp.api.openai.com` | Yes | No |
| India | `in.api.openai.com` | Yes | No |
| Singapore | `sg.api.openai.com` | Yes | No |
| South Korea | `kr.api.openai.com` | Yes | No |
| United Kingdom | `gb.api.openai.com` | Yes | No |
| United Arab Emirates | `ae.api.openai.com` | Yes | Yes |

"If your selected Region does not support regional processing ... OpenAI may also process and temporarily store Customer Content outside of the Region". "To use data residency with any region other than the United States, you must be approved for abuse monitoring controls, and execute a Modified Retention amendment."

- Failover: no first-party OpenAI document describing cross-region or cross-provider failover for the API was found; the only automatic behaviours are tier downgrade (`service_tier` → `default`) and Scale Tier spillover. Multi-vendor failover must be implemented at the gateway (section 5) — statement of absence, primary (searched docs; absence cannot be proven).

### 4.2 Anthropic — primary

- Status page: https://status.claude.com (https://status.anthropic.com redirects there).
- Service tiers https://platform.claude.com/docs/en/api/service-tiers : "**Priority Tier:** Available only to organizations with an existing capacity commitment / **Standard:** Default tier ... / **Batch**". Warning: "Priority Tier capacity commitments are no longer available for purchase." Standard: "best-effort availability." Priority: "helps minimize “server overloaded” errors". Request param `service_tier`: `"auto"` (default) / `"standard_only"`. No public uptime-percentage SLA is published in the docs — UNVERIFIED (absent).
- Data residency https://platform.claude.com/docs/en/manage-claude/data-residency : "The `inference_geo` parameter controls where model inference runs for a specific API request. Add it to any `POST /v1/messages` call." Values: `"global"` — "Default. Inference may run in any available geography for optimal performance and availability." ; `"us"` — "Inference runs only in US-based infrastructure." Response `usage.inference_geo` echoes where it ran. "The `inference_geo` parameter is supported on Claude 4.6 and later models." Workspace settings: `allowed_inference_geos`, `default_inference_geo`. "US-only inference is priced at 1.1x on Claude 4.6 and later models". "On Amazon Bedrock and Google Cloud, the inference region is determined by the endpoint URL or inference profile, so `inference_geo` is not applicable."
- Claude Platform on AWS https://platform.claude.com/docs/en/build-with-claude/claude-platform-on-aws : base URL `aws-external-anthropic.{region}.api.aws`; "Workspaces are bound to a single AWS region." ; "All AWS commercial regions are supported."
- Failover: no first-party Anthropic document prescribing failover between the first-party API and Bedrock/Vertex/Foundry was found; the same models are offered on all four surfaces, so cross-cloud failover is a gateway decision (section 5).

---

## 5. LiteLLM proxy failover — primary (docs.litellm.ai)

Sources: https://docs.litellm.ai/docs/proxy/reliability , https://docs.litellm.ai/docs/routing , https://docs.litellm.ai/docs/proxy/config_settings , https://docs.litellm.ai/docs/proxy/health , https://docs.litellm.ai/docs/proxy/model_management , https://docs.litellm.ai/docs/proxy/users

"Fallbacks are how LiteLLM does automatic failover. If a call fails after num_retries, LiteLLM falls back to another model group". "Fallbacks are done in-order". "There are 3 types of fallbacks: content_policy_fallbacks ... context_window_fallbacks ... fallbacks: For all remaining errors - e.g. litellm.RateLimitError".

| `router_settings` key | Type / default (config_settings table) | Verbatim |
|---|---|---|
| `fallbacks` | array of objects, `[]` | "Specifies fallback models for all types of errors." e.g. `fallbacks: [{"gpt-5.6-luna": ["gpt-5.6-terra"]}]` |
| `context_window_fallbacks` | `List[Dict[str, List[str]]]`, `[]` | "Fallback models for context window violations." |
| `content_policy_fallbacks` | array of objects, `[]` | "Specifies fallback models for content policy violations." |
| `default_fallbacks` | `Optional[List[str]]`, null | "Fallbacks to try if no model group-specific fallbacks are defined." e.g. `default_fallbacks: ["claude-opus"]` |
| `max_fallbacks` | `Optional[int]`, 5 | "The maximum number of fallbacks to try before exiting the call." |
| `num_retries` | int, 2 | "Number of retries for a request." (precedence: request body > deployment `litellm_params` > `litellm_settings`) |
| `retry_after` | int, 0 s | "Time to wait before retrying a request in seconds. If x-retry-after is received from LLM API, this value is overridden." |
| `retry_policy` | object, null | "Specifies the number of retries for different types of exceptions." e.g. `{"RateLimitErrorRetries": 3, "NotFoundErrorRetries": 0, "DefaultRetries": 2}` |
| `allowed_fails` | integer, 3 | "The number of failures allowed before cooling down a model." |
| `allowed_fails_policy` | object, null | e.g. `{"RateLimitErrorAllowedFails": 100}`; also settable per deployment under `model_info` |
| `cooldown_time` | integer, 5 s | "The duration (in seconds) to cooldown a model if it exceeds the allowed failures." |
| `disable_cooldowns` | boolean, false | "If true, disables cooldowns for all models." |
| `enable_weighted_failover` | boolean, false | "a retryable failure on one deployment re-picks (weighted) across other deployments in the same model group before cross-group fallbacks." |
| `enable_pre_call_checks` | boolean, false | "checks if a call is within the model's context window before making the call." |
| `routing_strategy` | `simple-shuffle` | options `"simple-shuffle", "least-busy", "usage-based-routing", "latency-based-routing"` |

Access gating of fallbacks: `general_settings.enforce_fallback_model_access: true` — "a fallback configured in router_settings (fallbacks, context_window_fallbacks, content_policy_fallbacks, default_fallbacks) only runs if the calling key, its team and its project are allowed to call the fallback model". Spend logs record `attempted_fallbacks` and `original_model_group`. Client-side: request body `"fallbacks": ["gpt-5.6-luna"]`. Note: "Starting in LiteLLM Proxy v1.85.0, mock_testing_fallbacks ... are stripped from incoming Proxy requests".

Health endpoints (health page):

| Endpoint | Verbatim |
|---|---|
| `GET /health/liveliness` | "“I'm alive!” (200), or {"status": "shutting_down"} (503) during graceful shutdown. The process is up. No dependencies are checked. GET /health/liveness is an alias" |
| `GET /health/readiness` | "{"status": "healthy", "db": ...} (200) when ready; 503 when a configured database is unreachable" |
| `GET /health` | "accepts any valid key. It runs a real test request against every configured model, so it costs a few tokens per model." Returns `healthy_endpoints` / `unhealthy_endpoints`. |
| `GET /health/readiness/details`, `/health/history`, `/health/latest`, `/health/backlog`, `/health/drain` (needs `general_settings.enable_drain_endpoint: true`) | as listed on page |

Background checks: `general_settings: background_health_checks: true  # run checks in the background / health_check_interval: 300  # seconds between runs (default 300) / health_check_details: true`. Per-model opt-out `model_info.disable_background_health_check: true`; scope with `general_settings.background_health_check_model_groups: ["prod-openai"]`.

Runtime enable/disable of a deployment (model_management page; requires `STORE_MODEL_IN_DB="True"` or `general_settings.store_model_in_db: true`):

| Operation | Verbatim |
|---|---|
| Add | `POST /model/new` ("with it off, POST /model/new fails because there is nowhere to persist the model") |
| List | `GET /model/info` "Returns the full model list with API keys masked" |
| Update | `POST /model/update` "Change litellm_params or model_info for an existing model" |
| Delete | `POST /model/delete` "Body {"id": "<model_id>"}, admin only. This is a POST; there is no DELETE-verb route" |

Model access groups (users page): `model_info: access_groups: ["beta-models"]` on a deployment; grant via `POST /user/new` or `/key/generate` with `"models": ["beta-models"]`. Per-deployment kill-switch alternative: `model_info: allowed_fails: 1 / cooldown_time: 0` (doc: "cooldown_time: 0 # disable cooldowns for this deployment") — note `allowed_fails` "must be set under `model_info`, not `litellm_params`".

---

## 6. Standards to cite

| Standard | Item | Status | Verbatim / note |
|---|---|---|---|
| ISO 22301:2019 | 8.2.2 BIA, 8.3 BC strategies and solutions, 8.4 BC plans and procedures, 8.5 Exercise programme, 8.6 Evaluation of BC documentation and capabilities | **UNVERIFIED** | ISO OBP is a JavaScript app; https://www.iso.org/standard/75106.html confirms only title "Security and resilience — Business continuity management systems — Requirements", Edition 2, 2019-10, status 90.92 "International Standard to be revised" (2025-12-05), Amd 1:2024. Clause numbers above are the commonly cited ones; verify against the purchased text. |
| NIST SP 800-34 Rev. 1 | Seven-step process | **primary** | §3 (p.14 of PDF text): "1. Develop the contingency planning policy; 2. Conduct the business impact analysis (BIA); 3. Identify preventive controls; 4. Create contingency strategies; 5. Develop an information system contingency plan; 6. Ensure plan testing, training, and exercises; and 7. Ensure plan maintenance." https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-34r1.pdf |
| NIST CSF 2.0 (CSWP 29, Feb 26 2024) | RC.RP-01..06, RC.CO-03, RC.CO-04, PR.IR-03, PR.IR-04, ID.IM-02, ID.IM-04 | **primary** | RC.RP "Restoration activities are performed to ensure operational availability of systems and services affected by cybersecurity incidents": RC.RP-01 "The recovery portion of the incident response plan is executed once initiated from the incident response process"; RC.RP-02 "Recovery actions are selected, scoped, prioritized, and performed"; RC.RP-03 "The integrity of backups and other restoration assets is verified before using them for restoration"; RC.RP-04 "Critical mission functions and cybersecurity risk management are considered to establish post-incident operational norms"; RC.RP-05 "The integrity of restored assets is verified, systems and services are restored, and normal operating status is confirmed"; RC.RP-06 "The end of incident recovery is declared based on criteria, and incident-related documentation is completed". RC.CO: only RC.CO-03 "Recovery activities and progress in restoring operational capabilities are communicated to designated internal and external stakeholders" and RC.CO-04 "Public updates on incident recovery are shared using approved methods and messaging" exist (no RC.CO-01/02 in 2.0). PR.IR-03 "Mechanisms are implemented to achieve resilience requirements in normal and adverse situations"; PR.IR-04 "Adequate resource capacity to ensure availability is maintained". ID.IM-02 "Improvements are identified from security tests and exercises, including those done in coordination with suppliers and relevant third parties"; ID.IM-04 "Incident response plans and other cybersecurity plans that affect operations are established, communicated, maintained, and improved". https://nvlpubs.nist.gov/nistpubs/CSWP/NIST.CSWP.29.pdf |
| APRA CPS 230 (July 2025 version; "commences on 1 July 2025", para 6) | paras 35–44 | **primary** | Para 35: "Critical operations are processes undertaken by an APRA-regulated entity or its service provider which, if disrupted beyond tolerance levels, would have a material adverse impact on its depositors, policyholders, beneficiaries or other customers, or its role in the financial system." Para 36(d): "for all APRA-regulated entities: customer enquiries and the systems and infrastructure needed to support critical operations." Para 38: "For each critical operation, an APRA-regulated entity must establish tolerance levels for: (a) the maximum period of time the entity would tolerate a disruption to the operation; (b) the maximum extent of data loss the entity would accept as a result of a disruption; and (c) minimum service levels the entity would maintain while operating under alternative arrangements during a disruption." Para 40 BCP contents (register, triggers, actions, execution-risk assessment, communications). Para 41: "must monitor compliance with its tolerance levels and report any failure to meet tolerance levels, together with a remediation plan, to the Board." Para 43: "must have a systematic testing program for its BCP that covers all critical operations and includes an annual business continuity exercise. The program must test the effectiveness of the entity’s BCP and its ability to meet tolerance levels in a range of severe but plausible scenarios." Para 44: "include a range of severe but plausible scenarios, including disruptions to services provided by material service providers and scenarios where contingency arrangements are required." Source PDF: https://www.apra.gov.au/sites/default/files/2023-07/Prudential%20Standard%20CPS%20230%20Operational%20Risk%20Management%20-%20clean.pdf |
| DORA — Reg (EU) 2022/2554 | Art 11, 12, 24–27 | **primary** (via Cellar http://publications.europa.eu/resource/celex/32022R2554 ; EUR-Lex HTML is WAF-blocked for bots) | Art 11 "Response and recovery": 11(1) "financial entities shall put in place a comprehensive ICT business continuity policy"; 11(2)(a) "ensure the continuity of the financial entity’s critical or important functions"; 11(4) "put in place, maintain and periodically test appropriate ICT business continuity plans, notably with regard to critical or important functions outsourced or contracted through arrangements with ICT third-party service providers"; 11(5) BIA; 11(6)(a) "test the ICT business continuity plans and the ICT response and recovery plans in relation to ICT systems supporting all functions at least yearly" and (non-micro) "scenarios of cyber-attacks and switchovers between the primary ICT infrastructure and the redundant capacity, backups and redundant facilities". Art 12 "Backup policies and procedures, restoration and recovery procedures and methods": 12(1)(a) "backup policies and procedures specifying the scope of the data that is subject to the backup and the minimum frequency of the backup"; 12(2) "Testing of the backup procedures and restoration and recovery procedures and methods shall be undertaken periodically."; 12(4) "shall maintain redundant ICT capacities"; 12(6) "In determining the recovery time and recovery point objectives for each function, financial entities shall take into account whether it is a critical or important function". Art 24 "General requirements for the performance of digital operational resilience testing" (24(6): "at least yearly ... on all ICT systems and applications supporting critical or important functions"); Art 25 "Testing of ICT tools and systems" (lists "scenario-based tests ... performance testing, end-to-end testing and penetration testing"); Art 26 "Advanced testing of ICT tools, systems and processes based on TLPT" ("at least every 3 years"); Art 27 "Requirements for testers for the carrying out of TLPT". |
| EU AI Act — Reg (EU) 2024/1689 | Art 15 | **primary** (Cellar 32024R1689) | Art 15 "Accuracy, robustness and cybersecurity". 15(1) "High-risk AI systems shall be designed and developed in such a way that they achieve an appropriate level of accuracy, robustness, and cybersecurity, and that they perform consistently in those respects throughout their lifecycle." 15(4) "High-risk AI systems shall be as resilient as possible regarding errors, faults or inconsistencies that may occur within the system or the environment in which the system operates ... The robustness of high-risk AI systems may be achieved through technical redundancy solutions, which may include backup or fail-safe plans." 15(5) "High-risk AI systems shall be resilient against attempts by unauthorised third parties to alter their use, outputs or performance by exploiting system vulnerabilities." |
| ISO/IEC 42001:2023 | Annex A resilience control | **UNVERIFIED** | https://www.iso.org/standard/42001 confirms title "Information technology — Artificial intelligence — Management system", Edition 1, 2023-12, 51 pages; Annex A text not readable. Do not cite a specific A.6.2.x number without the text. |
| RBNZ BS11 Outsourcing Policy (Sept 2022) | section numbers | **UNVERIFIED** (PDF 403 for non-browser clients) | Web page https://www.rbnz.govt.nz/regulation-and-supervision/banks/prudential-requirements/outsourcing-policy (paraphrase via fetch): requires "large banks to have the legal and practical ability to control and execute outsourced functions"; a bank in a foreign-owned group must meet outcomes "as a stand-alone entity in the event of separation from its parent"; obligations met "both before the start of the first business day after the day of failure and thereafter" (clearing, settlement, time-critical); applies to banks with net liabilities ≥ $10 billion. Section numbers not read. |

---

## 7. RTO / RPO / MTD definitions — NIST SP 800-34 Rev. 1 — primary

Location: §3.2.1 "Determine Business Processes and Recovery Criticality", p.17 (footnotes 18–20); glossary Appendix G, p.G-2.

| Term | Verbatim (§3.2.1, p.17) |
|---|---|
| MTD | "**Maximum Tolerable Downtime (MTD).** The MTD represents the total amount of time the system owner/authorizing official is willing to accept for a mission/business process outage or disruption and includes all impact considerations." |
| RTO | "**Recovery Time Objective (RTO).** RTO defines the maximum amount of time that a system resource can remain unavailable before there is an unacceptable impact on other system resources, supported mission/business processes, and the MTD." / "Because the RTO must ensure that the MTD is not exceeded, the RTO must normally be shorter than the MTD." |
| RPO | "**Recovery Point Objective (RPO).** The RPO represents the point in time, prior to a disruption or system outage, to which mission/business process data can be recovered (given the most recent backup copy of the data) after an outage. Unlike RTO, RPO is not considered as part of MTD." |
| MAO (footnote 18) | "The first version of NIST SP 800-34 used the term Maximum Allowable Outage (MAO) to describe the downtime threshold. To further delineate business process and information system downtime, Maximum Tolerable Downtime (MTD) and Recovery Time Objective (RTO) terms are used." |

Glossary (App. G): "Maximum Tolerable Downtime: The amount of time mission/business process can be disrupted without causing significant harm to the organization’s mission." / "Recovery Point Objective: The point in time to which data must be recovered after an outage." / "Recovery Time Objective: The overall length of time an information system’s components can be in the recovery phase before negatively impacting the organization’s mission or mission/business processes."

**Not in SP 800-34 Rev.1:** "Work Recovery Time (WRT)" and "Maximum Acceptable Downtime (MAD)" do not appear anywhere in the document (grep of full text). Use MTD/RTO/RPO only when citing NIST; WRT/MAD are industry (e.g. DRI/BCI) terms — UNVERIFIED here.

---

## 8. Chaos / drill tooling — primary

### AWS Fault Injection Service — https://docs.aws.amazon.com/fis/latest/userguide/fis-actions-reference.html

| Action | Resource type | Verbatim / parameters |
|---|---|---|
| `aws:network:disrupt-connectivity` | `aws:ec2:subnet` | "Denies the specified traffic to the target subnets by temporarily cloning the original network access control list". `scope`: `all`, `availability-zone`, `dynamodb`, `prefix-list` ("Denies traffic to and from the specified prefix list", `prefixListIdentifier`, max 10 entries), `s3`, `s3express`, `vpc`; `duration` "from one minute to 12 hours" ISO 8601 (e.g. `PT1M`). No `bedrock` scope exists — to simulate a Bedrock endpoint outage, use `prefix-list` with Bedrock endpoint CIDRs, or `aws:network:disrupt-vpc-endpoint`. |
| `aws:network:disrupt-vpc-endpoint` | `aws:ec2:vpc-endpoint` | "Blocks inbound and outbound traffic of the target interface VPC endpoints." (usable against a `com.amazonaws.<region>.bedrock-runtime` interface endpoint — applicability inferred, UNVERIFIED) |
| `aws:network:route-table-disrupt-cross-region-connectivity` | `aws:ec2:subnet` | "Blocks traffic that originates in the target subnets and is destined for the specified Region." param `region` e.g. `eu-west-1` |
| `aws:network:transit-gateway-disrupt-cross-region-connectivity` | `aws:ec2:transit-gateway` | listed in reference |
| `aws:fis:inject-api-throttle-error`, `aws:fis:inject-api-unavailable-error`, `aws:fis:inject-api-internal-error` | `aws:iam:role` | "The supported value is `ec2` and `kinesis`." → **not** usable for Bedrock API errors. |
| `aws:cloudwatch:assert-alarm-state`, `aws:fis:wait`, `aws:ssm:send-command` | — | useful for drill orchestration |

No Bedrock-specific FIS action exists in the reference (full action-name grep).

### Azure Chaos Studio — https://learn.microsoft.com/en-us/azure/chaos-studio/chaos-studio-fault-library

| Fault | URN | Verbatim |
|---|---|---|
| NSG Security Rule | `urn:csci:microsoft:networkSecurityGroup:securityRule/1.0` (also `/1.1`) | "Enables manipulation or rule creation in an existing Azure network security group (NSG) ... Useful for: - Simulating an outage of a downstream or cross-region dependency/nondependency. - Simulating an event that's expected to trigger a logic to force a service failover." Params `name`, `protocol` (Any/TCP/UDP/ICMP), `sourceAddresses`/`destinationAddresses` (CIDR JSON array or service tag) |
| Network Disconnect (agent) | `urn:csci:microsoft:agent:networkDisconnect/1.2` | "Blocks network traffic for specified port range and network block." Windows, Linux (outbound only) |
| Network Disconnect (Via Firewall) | `urn:csci:microsoft:agent:networkDisconnectViaFirewall/1.1` | agent-based |
| Network Latency / Packet Loss / Isolation / DNS Failure | `urn:csci:microsoft:agent:networkLatency/1.2`, `...:networkPacketLoss/1.2`, `...:networkIsolation/1.0`, `...:dnsFailure/1.0` | agent-based |
| App Service Stop | `urn:csci:microsoft:appService:stop/1.0` | service-direct |

No API Management- or Cognitive Services/OpenAI-specific fault exists in the library (grep). Page title notes "Experiments (classic)".

---

## Could not verify (first-party text not readable during collection on 2026-10-13)

1. ISO 22301:2019 clause numbers/titles (8.2.2, 8.3, 8.4, 8.5, 8.6) — ISO OBP requires JavaScript; only the store metadata page was readable.
2. ISO/IEC 42001:2023 Annex A control IDs (e.g. any "A.6.2.x" resilience control) — text not accessible.
3. RBNZ BS11 section numbers — PDF downloads return HTTP 403 to non-browser clients; only the policy overview web page was readable.
4. Azure OpenAI SLA uptime percentages — Microsoft licensing SLA document not fetched (link captured only).
5. Bedrock: exact Service Quotas names for cross-Region inference profiles (quotas page does not list them).
6. Google: `X-Vertex-AI-LLM-Request-Type: both` — not present on the current page (only `dedicated` and `shared`).
7. Terraform `azapi_resource` as the workaround for APIM `type = Pool` backends and for Azure `spilloverDeploymentName` — not verified against AzAPI docs.
8. Terraform resource for Google Provisioned Throughput orders — none found; not exhaustively searched.
9. Anthropic published uptime SLA percentage — none found in docs (absence).
10. OpenAI / Anthropic official cross-provider failover guidance — none found (absence; gateway-level failover is the practical answer).
11. "WRT" / "MAD" definitions — absent from NIST SP 800-34 Rev. 1; not sourced elsewhere.
12. FIS `aws:network:disrupt-vpc-endpoint` applicability to a Bedrock runtime interface endpoint — action is generic to interface endpoints; Bedrock not named.
