# Runtime hooks — platform events into governance records

`hooks/receiver.py` is a small, dependency-free HTTP receiver that turns
events from the AI platforms into incident records in `incidents/`, linked
to the AI system they concern. That closes the loop between the paper
controls (AIG-10 guardrails, AIG-13 logging, AIG-16 incident management,
AIG-22 budgets) and what happens at runtime.

```
platform event ──▶ /hooks/<source> ──▶ incidents/INC-<date>-<hash>.yaml ──▶ inventory, reports, review reminders
```

## Run it

```bash
export AIGOV_WEBHOOK_SECRET="$(openssl rand -hex 32)"
python3 hooks/receiver.py --port 8081 --incidents incidents/
curl -s -X POST localhost:8081/hooks/generic \
  -H "Authorization: Bearer $AIGOV_WEBHOOK_SECRET" -H "Content-Type: application/json" \
  -d '{"system":"customer-support-assistant","event_type":"moderation_flagged","severity":"medium","title":"Moderation gate flagged an output","details":{"category":"harassment","confidence":0.93}}'
```

Put it behind TLS (a reverse proxy, an API gateway or a function host) and
restrict ingress to the platforms' egress ranges. Run it in the pipeline
runner that has write access to the repository, then commit `incidents/` —
or let the NexGuide.AI GovMap edition host it for you.

## Authentication

Every `POST` must carry either

- `X-AIGov-Signature: sha256=<hex HMAC-SHA256 of the raw body with AIGOV_WEBHOOK_SECRET>`, or
- `Authorization: Bearer <AIGOV_WEBHOOK_SECRET>` for senders that cannot sign
  (EventBridge API destinations with API-key auth, Event Grid with a
  custom header, Pub/Sub push with an `Authorization` header set by you).

Comparison is constant-time. The only unauthenticated request accepted is the
Event Grid subscription validation handshake, which carries no data.

## Sources

| Endpoint | Sender | How to wire it | Becomes |
|---|---|---|---|
| `/hooks/aws-eventbridge` | EventBridge rule → **API destination** (connection with API-key auth header `Authorization: Bearer …`) | Rules on `aws.bedrock` events (guardrail interventions where the account emits them), `aws.guardduty` findings, `aws.cloudwatch` alarms (token budgets from `finops/`) | `guardrail_intervened`, `defender_alert`, `budget_alarm`, `platform_event` |
| `/hooks/azure-eventgrid` | Event Grid **webhook** subscription (system topic or custom topic) | Defender for Cloud security alerts, Azure Monitor alerts on Foundry content-filter metrics, custom events from Content Safety | `defender_alert`, `content_filtered`, `platform_event` |
| `/hooks/gcp-pubsub` | Pub/Sub **push** subscription | Cloud Logging sink of Model Armor sanitisation logs or Vertex AI audit logs → topic → push | `model_armor_match`, `platform_event` |
| `/hooks/generic` | Anything that can POST JSON | `vendors/openai/native/moderation-gate.py`, `vendors/mistral/native/moderation-gate.sh`, Anthropic/LiteLLM/SIEM rules, a Slack workflow | whatever `event_type` you send |

The envelopes (EventBridge `source`/`detail-type`/`detail`, Event Grid
`eventType`/`subject`/`data`, Pub/Sub `message.data` base64 JSON with
`attributes`) are stable, documented formats. The **inner** payloads differ
by service and change over time, so the receiver keeps only allow-listed
keys (`action`, `severity`, `guardrailId`, `alertType`, `matchState`, …)
and never stores prompts, completions or identifiers that are not on the
list. If you need another key, add it to `KEEP_KEYS` with a review.

## Linking an event to a system

The receiver looks, in order, for: a `system` field (generic), a resource tag
or label `aigov-system`, a `workload` tag (the same tag `finops/` uses for
cost allocation), or `?system=<id>` on the URL — one URL per system is the
simplest wiring. Events with no match are stored as `system: unassigned`;
`python3 tools/incident.py link INC-… --system <id>` assigns them.

## Record shape

```yaml
apiVersion: aigov/v1
kind: AIIncident
id: INC-20261014-3fa9c1d2
system: customer-support-assistant
source: aws-bedrock
event_type: guardrail_intervened
severity: medium           # low | medium | high | critical
title: Bedrock Guardrail Intervention
occurred: "2026-10-14T01:02:03Z"
opened: "2026-10-14T01:02:05Z"
status: open               # open | closed
controls: [AIG-10, AIG-16] # from the event type
details: {...}             # allow-listed keys only
notes: []
```

Severity comes from the event (`severity`, `sev1…4`, `p1…4`, alarm state) or,
failing that, from a default per event type (`prompt_attack_detected` and
`defender_alert` are high). High and critical open incidents are listed in
the weekly review-reminder issue for the system.

## Re-running the gate on an incident

A runtime incident does not change the record's declared controls, so the
gate result does not flip automatically. What the free edition gives you is
visibility: the inventory and the audit report show open incidents next to
the gate result, and the reminder issue asks the owner to act. Automatic
re-evaluation, blocking promotion while a critical incident is open, and
routing to Slack, Teams, Jira or ServiceNow are part of the NexGuide.AI
GovMap edition.
