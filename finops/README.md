# AI FinOps as code — token cost management, model selection and brokerage

**Verified as of 2026-10-13** — sources in [docs/sources/finops-models.md](../docs/sources/finops-models.md) and [docs/sources/finops-tooling.md](../docs/sources/finops-tooling.md). Prices change monthly; the `AI model selection` workflow opens an issue when the catalogue is older than 30 days.

```
finops/
  catalog/models.yaml        verified model catalogue: prices, caching/batch rules, context, capabilities,
                             residency, RAI facts, lifecycle, functional tier; platform overlays
  schema/workload.schema.json  the workload profile the selector consumes
  examples/*.yaml            three worked workloads (EU support chatbot, AU contract agent, batch extraction)
  decisions/                 generated: decision.json, summary.md, litellm.yaml, routing.yaml, finops.yaml
  iac/terraform/{azure,aws,gcp}  budgets, token alarms, cost-allocation profiles (validated in CI)
  iac/gateway/apim/          llm-token-limit + token metrics policy, backend pool with circuit breakers (Bicep)
  iac/observability/         OpenTelemetry collector (GenAI semconv) and Prometheus alert rules
  tests/                     unit tests for the selector
tools/select_model.py        the selector and broker-config generator
tools/dr.py                  push-button failover / failback / drill on the routing state (see bcp/)
```

## Functional tiers

The catalogue classifies every model into a tier (this repository's classification, not a vendor label):

| Tier | Role | Examples (as of 2026-10-13) | Quality prior |
|---|---|---|---|
| **daily-driver** | high-volume, low-stakes, latency-sensitive; still supports tools and structured output | GPT-6 Luna, Claude Haiku 5.5, Gemini 3.5 Flash-Lite, Mistral Small 4, Ministral 3, Nova Lite/Micro | 0.60 |
| **workhorse** | default production tier for assistive and agentic work | GPT-6.1 Sol, Claude Sonnet 5.5, Gemini 3.8 Flash, Mistral Large 3 / Medium 3.5, Nova 2 Lite / Pro, DeepSeek Flash | 0.80 |
| **specialist-reasoning** | flagship reasoning for hard, consequential or long-horizon tasks; escalation target, not a default | GPT-6 Astra, Claude Fable 5.1 / Opus 5.5, Gemini 3.1 Pro (preview), Mistral Large 4 (preview), Nova Premier, DeepSeek V4 Pro | 0.95 |
| **specialist-code** | code completion / FIM | Codestral 25.08 | 0.85 |
| **safety** | moderation classifiers, never a primary | Mistral Moderation 2 | — |

The prior is only used when the workload carries no measured evaluation scores, and every output says so. **Accuracy is the organisation's evidence (AIG-14), not the vendor's claim**: fill `quality.evals` from your evaluation suite and the recommendation becomes "measured".

## How the selector decides

1. **Hard constraints** per model × platform: modalities, tools, structured output, reasoning, context window, lifecycle (preview/legacy off by default), vendor and platform allow/deny lists, the approved-model list (AIG-06), **residency** per model × platform (first-party uses the model's own processing geos; a cloud platform uses that model's platform entry or its inference-profile prefixes, never a generic overlay — Claude on Bedrock `eu.` passes an EU constraint, Claude first-party does not, a US-only Bedrock profile does not; `residency: [global]` or `[]` means no constraint), **zero data retention** per platform (a vendor's first-party ZDR says nothing about Bedrock/Vertex/Foundry retention, which is unverified here), required attestations (e.g. `42001`), a vendor moderation API when required, regulated data without verified attestations.
2. **Cost per request** from the verified price table: cached vs uncached input, long-context steps (OpenAI 272K, Haiku 5.5 100K, Gemini Pro 200K), batch/flex discount on the batchable share, regional/data-zone uplift (OpenAI +10 %, Anthropic US-only 1.1×, Mistral regional 1.1×, Gemini non-global 1.1×, Azure Data Zone 1.1×, Bedrock geo 1.1×), scheduled price changes (Gemini 3.8 Flash doubles on 2027-01-01).
3. **Score** = weighted cost (log-normalised), quality (measured or prior), RAI (attestations, ZDR, moderation), latency class, lifecycle. Weights are per workload (`weights`), default 35/35/15/10/5.
4. **Routing**: a `complexity_mix` maps difficulty to minimum tiers (simple → floor, standard → workhorse, hard → specialist). A single model must serve the hardest class present; a **cascade** pays the cheap tier for the easy share and escalates on `context_window`, `tool_error`, `low_confidence`, `policy_refusal` or an explicit tag (hard requests pay twice — that is in the maths). The cascade wins when it saves ≥ `min_savings_for_multi` (15 % default).
5. **Continuity**: the primary gets the same model on another platform first (no quality change), then a different vendor of equal or higher tier, until `min_vendors_for_resilience` is met; otherwise the decision warns that BCP depends on one vendor.

```bash
python3 tools/select_model.py finops/examples/eu-support-chatbot.yaml --out-dir finops/decisions
python3 -m unittest discover -s finops/tests
```

Worked result (EU support chatbot, 40k requests/day, personal data, EU-only, ZDR required): cascade of GPT-6 Luna (70 %) → Mistral Large 3 on the EU endpoint (25 %) → GPT-6 Astra (5 %) at about $2.6k/month versus $38.8k/month for the best single model that could handle the hard tail; Mistral is the cross-vendor fallback. Relax `zdr_required` and Claude on Bedrock EU and Luna on Azure Foundry become admissible.

## Token cost brokerage

`<workload>.litellm.yaml` is a LiteLLM proxy config: one model group per role (`-primary`, `-escalation`, `-specialist`, `-fallback-n`), **per-deployment budgets** (`max_budget` / `budget_duration` sized to each role's share with 20 % headroom), **provider budgets** (`provider_budget_config`), a **global cap** (`litellm_settings.max_budget`), tags for spend attribution (`workload:<id>`; tag *filtering* is off so untagged requests still route), fallbacks (continuity routes before the escalation tier) and context-window fallbacks to larger windows only, cooldowns, background health checks, Prometheus + OTel callbacks, and `reject_clientside_metadata_tags` so callers cannot move themselves onto someone else's budget. Budgets need the proxy database. Virtual keys and teams are created against the running proxy (`/key/generate`, `/team/new` — fields in the research note), not in this file.

At the edge, `iac/gateway/apim/token-limit-policy.xml` enforces `llm-token-limit` (tokens per minute + monthly quota per subscription → 429 / 403), emits token metrics with a workload dimension, semantic-caches responses, and runs prompt shields before the request reaches a backend pool whose priority groups are the DR topology.

## Operational metrics

- **Broker**: `litellm_spend_metric`, `litellm_total_tokens_metric`, remaining team/key/provider budget, `litellm_deployment_state`, fallback counters, latency histograms — alert rules in `iac/observability/prometheus-rules.yaml` (budget burn 80 %, exhaustion, 3× spend-rate anomaly, zero-cost requests, outage, failing fallbacks, p95 latency).
- **Applications**: OpenTelemetry GenAI semantic conventions (Development status): `gen_ai.client.inference.usage.input_tokens` / `output_tokens` / `cache_read.input_tokens` / `reasoning.output_tokens`, `gen_ai.client.inference.duration`, `gen_ai.server.time_to_first_token`; attribute `gen_ai.provider.name` (`gen_ai.system` is deprecated). The collector drops prompt/response content before export.
- **Cloud**: Azure `TokenTransaction` / `ProcessedPromptTokens` / `GeneratedTokens` (namespace `Microsoft.CognitiveServices/accounts`), Bedrock `InputTokenCount` / `OutputTokenCount` / `InvocationThrottles` (`AWS/Bedrock`, dimension `ModelId`), Vertex `publisher/online_serving/token_count` with `request_type` dedicated/spillover/shared.
- **Vendor-side**: OpenAI Usage/Costs API and project spend alerts (cents, monthly, email); Anthropic `usage_report/messages` and `cost_report` grouped by model, workspace, `service_tier`, `inference_geo`; Mistral `GET /v1/admin/usage` and `POST /v1/admin/spend-limit`.

## FinOps Framework mapping

| FinOps capability (Framework 2026) | Where it lives here |
|---|---|
| Data Ingestion, Allocation | application inference profiles and tags (AWS), workload dimension (APIM), `tags` in the broker; FOCUS 1.4 has no token column — allocate by tag, unit `Tokens` |
| Reporting & Analytics, Anomaly Management | Prometheus rules, cloud alarms, LiteLLM Prometheus metrics |
| Planning & Estimating, Forecasting, Budgeting | selector cost model; cloud budgets at 50/80/100 % actual and 100 % forecast |
| Unit Economics | `$/request` and `$/month` per candidate in every decision |
| Rate Optimization | caching, batch/flex, scheduled price changes, regional uplifts in the cost model |
| Architecting & Workload Placement, Usage Optimization | tiering, cascade routing, platform choice |
| Governance, Policy & Risk | control AIG-22 in the gate: no budget → deny; no token limits, no selection record, no allocation tags → warn |

## Known gaps and unverified items

- Azure budget filters use `ResourceId` because the `ServiceName`/`MeterCategory` value strings for Azure OpenAI were not verified; AWS budget `Service` values for Bedrock model usage and the Vertex AI billing service id are unverified (see variables).
- OpenAI has spend *alerts* but no hard project budget in its API; Anthropic's Spend Limits API is Claude Enterprise only; Mistral has an org monthly spend limit (`POST /v1/admin/spend-limit`). Hard caps therefore live in the broker.
- LiteLLM provider prefixes `mistral/` and `deepseek/`, `aws_region_name`, `vertex_project/vertex_location` come from LiteLLM's provider pages and were not re-verified in the research note.
- DeepSeek has no vendor pack: attestations, retention and training terms are unverified and it is excluded whenever ZDR, attestations or non-CN residency are required.
- Quality priors are not benchmarks; measure. When `quality.min_eval_score` is set, a model without a measured score never clears the floor.
- Catalogue `lifecycle.retirement` is recorded for the runbook; the selector only filters on `lifecycle.status` (preview/legacy).
