# Changelog

All notable changes to this repository are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and versions follow
[Semantic Versioning](https://semver.org/): a MAJOR bump when the system
record schema or the gate decision shape changes incompatibly, MINOR for new
frameworks, controls, risks, tools or workflows, PATCH for catalogue
corrections and fixes.

## [Unreleased]

## [1.0.0] - 2026-10-14

### Changed
- Licence changed from MIT to **Apache License 2.0** with an explicit patent
  grant; added `NOTICE`, `TRADEMARKS.md` (reserving NexGuide.AI, NexGuide.AI
  GovMap and NXGD-AIGovMap) and a contributor licence agreement (`CLA.md`,
  enforced by the CLA workflow).
- The elements-table visual is now **NXGD-AIGovMap** with the tagline
  "NexGuide.AI Governance Map" (`docs/NXGD-AIGovMap.png`).
- The reusable gate workflow takes a `policy_repo` input, so forks can point
  it at their own copy, and emits SARIF for the GitHub code-scanning tab.

### Added
- **Risk catalogue** `catalog/risks.yaml`: 36 AI risks across 9 categories
  mapped to the 22 controls and to the OWASP, ATLAS and NIST references;
  generated `docs/RISKS.md`; risks surface per system in reports.
- **Evidence as code**: an `evidence` block in the system record schema with
  per-control evidence items, freshness (`valid_days`) and an `enforce`
  switch; the gate warns on missing evidence and denies on stale evidence
  when enforcement is on.
- **Inventory**: `systems/` convention with an example record,
  `tools/inventory.py` producing Markdown, CSV and JSON inventories with gate
  status per system, and the `inventory.yml` workflow that publishes it.
- **Workflow on GitHub**: `CODEOWNERS`, pull-request and issue templates,
  review reminders (`tools/reviews.py` + `review-reminders.yml`) that open
  issues for impact-assessment reviews, audits, DR drills and evidence
  expiring in the next 30 days.
- **Runtime hooks**: `hooks/receiver.py` turns Amazon Bedrock Guardrails,
  Microsoft Defender for AI, Google Model Armor, OpenAI/Anthropic/Mistral
  moderation and generic JSON events into incident records under
  `incidents/`; `tools/incident.py` lists and closes them; open high
  incidents surface in the inventory and reports.
- **Audit report**: `tools/report.py` builds a Markdown audit pack per system
  (decision, frameworks, controls with evidence status, applicable risks,
  incidents).
- **Read-only API and MCP server**: `api/server.py` (HTTP/JSON over the
  catalogue, profiles, inventory and gate) and `mcp/server.py` (Model Context
  Protocol over stdio with the same tools) so assistants and pipelines can
  query the catalogue.
- Bootstrap: `Makefile`, `requirements.txt`, `.devcontainer/`, Dependabot,
  release workflow, `SECURITY.md`, `CONTRIBUTING.md`, `docs/EDITIONS.md`.

## [0.9.0] - 2026-10-13

- Catalogue verified as of 13 Oct 2026; AI FinOps, model selection,
  push-button BCP/DR and the energy sector added; NXGD elements-table visual
  published.
