# `systems/` — your AI inventory, in git

One YAML file per AI system, model or agent, in the shape of
[`mlops/schema/ai-system.schema.json`](../mlops/schema/ai-system.schema.json).
This directory **is** the inventory: the gate evaluates every file on pull
requests, the inventory workflow publishes the register, and the review
reminders open issues when something falls due. Nothing else to install.

```
systems/
  customer-support-assistant.yaml   # example — copy it
  <your-system-id>.yaml
```

## Add a system

1. Start from the pre-filled template for your country and sector
   (`profiles/<cc>/<sector>.system.yaml`) or copy the example here.
2. Complete every field. `metadata.id` becomes the file name and the id used
   in the inventory, incidents and reports.
3. Add an `evidence` block listing where the proof for each control lives and
   the date it was last reviewed (see the example). Leave `enforce: false`
   until the evidence is maintained; then switch it on so expired evidence
   blocks promotion.
4. Open a pull request. The **AI governance gate** comments the findings and
   fails on any `deny`; a code owner's review is required to merge.

## What runs on this directory

| Trigger | Workflow | Output |
|---|---|---|
| Pull request touching `systems/**` | [`ai-governance-gate.yml`](../.github/workflows/ai-governance-gate.yml) | Findings as a PR comment, job summary and SARIF in the Security tab |
| Push to `main`, weekly | [`inventory.yml`](../.github/workflows/inventory.yml) | `docs/INVENTORY.md`, CSV and JSON (artifact) |
| Weekly | [`review-reminders.yml`](../.github/workflows/review-reminders.yml) | One issue per system with reviews falling due in 30 days |
| Webhook from a platform | [`hooks/receiver.py`](../hooks/README.md) | Incident record in `incidents/`, linked to the system |

Local equivalents: `make gate`, `make inventory`, `make reviews`,
`make report`.

## Conventions

- Ids are lowercase kebab-case (`^[a-z0-9][a-z0-9-]{1,62}$`).
- Dates are `YYYY-MM-DD`. The gate evaluates on `context.evaluation_date`
  when set, otherwise today, so obligations with a start date switch from
  `warn` to `deny` automatically.
- Owners are email addresses of accountable people, not teams.
- Keep records honest: a `true` here is a statement that the control is in
  place, which the evidence block should back.

## Scale and the commercial edition

A directory of YAML files works well up to a few hundred systems. The
NexGuide.AI GovMap edition keeps the same records in a database with search,
ownership views, approval workflows and an evidence vault, and imports
inventories from Azure AI Foundry, Amazon Bedrock and Copilot Studio
([docs/EDITIONS.md](../docs/EDITIONS.md)).
