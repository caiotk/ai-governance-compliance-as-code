# Changelog

All notable changes to this repository are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and versions follow
[Semantic Versioning](https://semver.org/): a MAJOR bump when the system
record schema or the gate decision shape changes incompatibly, MINOR for new
frameworks, controls, risks, tools or workflows, PATCH for catalogue
corrections and fixes.

## [Unreleased]

## [1.1.0] - 2026-10-26

### Added
- **ISO/IEC 27090:2026** (security threats and compromises to AI systems,
  published 14 Oct 2026) as an organisational baseline standard, mapped to
  AIG-04/05/06/07/10/13/14/15 and referenced from risks RSK-01/02/03/04/06.
- **EN 18286:2026**, the first harmonised standard under the EU AI Act
  (quality management system, Art 17), cited by Implementing Decision (EU)
  2026/2274 on 14 Oct 2026. Added to the EU layer (inherited by Portugal and
  Spain) and mapped to AIG-01/03/04/06/13/14/15/16 by Art 17(1) point. The
  `eu-ai-act` entry records the citation date and a `harmonised_standards`
  list, and notes that Art 17(2)–(4) are not covered and ISO/IEC 42001 is not
  harmonised.
- **IEEE 2863-2026** (recommended practice for organisational governance of
  AI, published 16 Oct 2026) as an organisational baseline, mapped to
  AIG-01/03/20.
- **Australian AI standards** (`au-ai-standards`): the Guidance for AI
  Adoption (AI6) mapped practice by practice to nine controls, with AS
  ISO/IEC 42001:2023, the Voluntary AI Safety Standard and the Australian
  Standards for AI announced on 15 Jul 2026. The announced standards are
  tracked as a `proposed` instrument in the Australian profiles.
- `tools/govmap.py` and `catalog/govmap.yaml`: the NXGDAI-GovMap visual is now
  generated from the catalogue (`make govmap`), so its counts, links and
  status markers cannot drift; CI validates the layout.
- `docs/sources/standards-3.md` with the sources for this release.

### Changed
- The visual is renamed **NXGDAI-GovMap** (`docs/NXGDAI-GovMap.png`); the
  former name NXGD-AIGovMap stays reserved in `TRADEMARKS.md`. It now shows 34
  laws, standards and frameworks.
- Catalogue `asOf` is 26 Oct 2026.

### Fixed
- NZ Privacy Act 2020 is `in-force`: IPP 3A has applied since 1 May 2026, and
  the biometric code has covered existing processing since 3 Aug 2026.
- MAS AI Risk Management Guidelines take effect on 7 Oct 2027 (sections 5–6
  by 7 Oct 2028), not 1 Oct; the gate's warning date moved with them.
- Guidance for AI Adoption was published on 21 Oct 2025, not 17 Oct 2025.
- The control catalogue header now says AIG-01 … AIG-22.

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
