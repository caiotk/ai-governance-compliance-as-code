# Push-button BCP/DR for LLM workloads

**Verified as of 2026-10-13** — sources in [docs/sources/finops-bcp-dr.md](../docs/sources/finops-bcp-dr.md). Not legal advice.

## What "push-button" means here

Every workload that goes through `tools/select_model.py` ends up with a **routing state** (`finops/decisions/<workload>.routing.yaml`): a primary route plus fallbacks on another platform and another vendor, and a broker config that already contains the fallback chain. Continuity is therefore a *state change*, not a rebuild:

| Button | Command | What happens |
|---|---|---|
| Status | `python3 tools/dr.py status` | Active route, RTO, last drill and its age for every workload. |
| Failover | `python3 tools/dr.py failover --workload W --to fallback-1 --reason "…"` | `active` flips, the broker config is regenerated with the fallback at the head of the chain (and the old primary as its last resort), the failed primary trips into cooldown on its first error, the switch is timed, an optional health probe runs. The workflow commits the change. |
| Failback | `python3 tools/dr.py failback --workload W` | Reverse of failover, recorded separately. |
| Drill | `python3 tools/dr.py drill --workload W --rto-minutes 30 --health-url …` | Failover + failback, timed against the RTO, original state restored even on error, a dated record written to `bcp/drills/`. Without `--health-url` the record says so ("state change only"): elapsed time then measures the routing change, not gateway convergence — pass the broker's readiness URL for continuity evidence. |

In GitHub: **Actions → AI BCP/DR → Run workflow**. Failover and failback run in the `production` environment — add required reviewers to that environment and the button becomes a two-person control. Drills run automatically on the first day of every quarter; a failed drill opens an issue, because it is a tolerance-level breach to report (CPS 230 para 41).

The cloud side is declared, not improvised:

- **Azure** — `bcp/terraform/azure` deploys the same model in two regions with the same content-filter policy and `NoAutoUpgrade`; `finops/iac/gateway/apim/backends.bicep` puts them in an API Management backend pool with circuit breakers and priority groups (priority 2 is used only when every priority-1 backend has tripped). Microsoft's own guidance: Foundry "doesn't provide automatic failover or disaster recovery" and Global/Data Zone routing "doesn't replace application-level regional failover".
- **AWS** — `bcp/terraform/aws` wraps geo cross-Region inference profiles (`au.`, `eu.`, `us.`, …) in tagged application profiles for the primary and secondary routes; a `check` block asserts the primary profile is visible from the source Region, because AWS says not to rely on the prefix alone for residency.
- **Google** — Gemini's `global` endpoint raises availability but gives no residency guarantee; jurisdictional (`us`/`eu`) endpoints keep processing in-region. Provisioned Throughput overflows to pay-as-you-go by default (visible as `request_type=spillover`, alerted in `finops/iac/terraform/gcp`).
- **OpenAI / Anthropic first-party** — no vendor-documented cross-region or cross-provider failover; the only automatic behaviours are tier downgrade (`service_tier` → `default`) and Scale Tier spillover. Multi-vendor failover is a gateway decision, which is why every routing state carries a second vendor.

## Tolerance levels

Define per critical operation (CPS 230 para 38; DORA Art 12(6)) and record them in the system record (`resilience.*`) and the routing state (`rto_minutes`):

| Term | NIST SP 800-34 Rev. 1 definition (§3.2.1) | Typical LLM workload value |
|---|---|---|
| MTD | total outage time the business owner will accept | 4 h for customer-facing assistants; 1 h for control-room advisory |
| RTO | max time a system resource can remain unavailable before impacting the MTD | 15–30 min via gateway failover |
| RPO | point in time to which data can be recovered | conversation state: minutes (externalised memory); prompts/configs: 0 (in git) |
| Minimum service level | CPS 230 para 38(c) | degraded mode: daily-driver model only, no agentic tools |

## Scenarios the drill programme must cover

1. **Primary vendor/region outage** — gateway or broker fails over to the secondary route (this repository's default drill).
2. **Quota exhaustion / throttling** — Bedrock `InvocationThrottles`, Azure 429 with `Retry-After`, Vertex 429 with `X-Vertex-AI-LLM-Request-Type: dedicated`; circuit breakers trip, priority group 2 takes traffic.
3. **Model retirement** — vendor notice periods differ (OpenAI ≥ 6 months GA; Anthropic ≥ 60 days; Mistral 6 months; Bedrock 6-month or 45-day Legacy; Azure 18-month lifecycle; Google ≥ 12 months). The weekly catalogue-freshness check and `lifecycle.retirement` in the catalogue feed this.
4. **Guardrail or moderation outage** — fail closed (`block_on_error`, APIM `llm-content-safety`), degrade to human-only.
5. **Credential compromise** — rotate via the vendor pack scripts; the broker's virtual keys are the blast-radius boundary.
6. **Price shock** — scheduled price changes are warned by the selector (e.g. Gemini 3.8 Flash doubling on 2027-01-01); budgets in `finops/iac/terraform/*` alert at 50/80/100 %.

Chaos tooling: AWS FIS `aws:network:disrupt-connectivity` (prefix-list scope) or `aws:network:disrupt-vpc-endpoint` against the Bedrock interface endpoint; Azure Chaos Studio NSG security-rule fault to simulate a cross-region dependency outage. Neither has a Bedrock- or Azure-OpenAI-specific fault.

## Standards the records map to

| Standard | What the drill record / routing state evidences |
|---|---|
| NIST SP 800-34 Rev. 1 | seven-step contingency process (policy, BIA, preventive controls, strategies, plan, testing/training/exercises, maintenance); MTD/RTO/RPO terms |
| NIST CSF 2.0 | RC.RP-01…06 recovery execution and verification, RC.CO-03/04 communication, PR.IR-03/04 resilience and capacity, ID.IM-02/04 improvements from exercises |
| NIST SP 800-61r3 | ID.IM lessons learned after each failover (the failover issue asks for it) |
| APRA CPS 230 | para 38 tolerance levels; para 41 monitor and report breaches; para 43 systematic testing incl. an annual exercise; para 44 severe-but-plausible scenarios incl. material service providers |
| DORA (Reg (EU) 2022/2554) | Art 11(4)/(6) yearly tests incl. switchovers between primary and redundant capacity; Art 12(6) RTO/RPO per function; Art 24–26 testing programme |
| EU AI Act Art 15(4) | robustness through technical redundancy, backup or fail-safe plans for high-risk systems |
| ISO 22301:2019 | BIA, strategies, plans, exercise programme, evaluation (clause numbers commonly cited as 8.2.2–8.6; not re-read — confirm against the purchased text) |
| RBNZ BS11 | large banks must be able to run critical functions independently of an outsourced provider; section numbers not re-read |

The governance gate reads `resilience.secondary_route`, `resilience.rto_minutes`/`rpo_minutes` and `resilience.last_dr_drill` from the system record: critical operations without a second route, tolerance levels or a drill within 12 months are warned everywhere (baseline framework `bcp-dr`); for APRA-regulated entities a missing or stale annual exercise is a **deny** (CPS 230 para 43).
