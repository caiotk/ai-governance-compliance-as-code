# Sources and verification

Every fact in `catalog/` and every syntax claim in `vendors/` traces to the four verification notes in [`docs/sources/`](sources/), produced on **13 October 2026**:

| Note | Covers |
|---|---|
| [frameworks.md](sources/frameworks.md) | ISO/IEC 27001 and 42001, zero trust, EU AI Act (incl. Reg (EU) 2026/1744), US federal and state law, GDPR, APRA, RBNZ BS11, Australian and NZ privacy law |
| [countries.md](sources/countries.md) | Brazil, Chile, Argentina, Portugal, Spain, USA, Australia, New Zealand, Japan, Singapore — horizontal AI law, data protection, cyber, and six sectors each |
| [cloud-vendors.md](sources/cloud-vendors.md) | Microsoft Foundry / Azure AI services, Copilot Studio / Power Platform, Amazon Bedrock, Google Cloud Vertex AI (Gemini Enterprise Agent Platform) — native governance tooling, Terraform and native IaC syntax, attestations |
| [model-vendors.md](sources/model-vendors.md) | OpenAI, Anthropic Claude, Meta Llama — organisation governance APIs, policies, safety tooling, attestations |
| [standards-2.md](sources/standards-2.md) | ISO 19011:2026, ISO/IEC 42005:2025, OWASP GenAI Security Project (LLM Top 10 2026, Agentic Top 10), MITRE ATLAS 2026.09, NIST AI RMF 1.0 / AI 600-1, NIST SP 800-61 Rev. 3 (and the withdrawn Rev. 2) |
| [anthropic-zt-mistral.md](sources/anthropic-zt-mistral.md) | Anthropic zero trust for AI agents (blog, eBook, CISO guide, Claude Code managed settings, Workload Identity Federation, RSP/ASL-3); Mistral AI (organisation model, Admin API, audit logs, SSO, ZDR, moderation and guardrails, attestations) |

## How to read the labels

- **`verification: primary`** — checked against the issuer's or vendor's own text or site.
- **`verification: secondary`** — located through a reputable secondary source (law firm, regulator summary, trade press). Re-check the primary text before relying on it.
- **`verification: unverified`** — included for completeness; must be confirmed before use. Items the notes mark `UNVERIFIED:` carry this label in the catalogue, and every vendor README has an "Unverified / known gaps" section.

## Known limits

- The notes are a point-in-time snapshot. The `regulatory-watch` workflow warns when `catalog/frameworks.yaml` `asOf` is more than 90 days old.
- ISO/IEC 42001 Annex A control titles come from a secondary listing, not the purchased standard. ISO 19011:2026 and ISO/IEC 42005:2025 clause numbers and titles come from the ISO Online Browsing Platform previews and ISO's own summaries, not the purchased texts.
- NIST SP 800-61 Rev. 2 was withdrawn on 3 April 2025; the catalogue encodes Rev. 3 and keeps Rev. 2's four phases as aliases so older runbooks still map.
- "Anthropic zero trust" is encoded as what Anthropic published (the May 2026 blog and eBook, the July 2026 CISO guide, Claude Code managed settings and Workload Identity Federation); it is vendor guidance, not a standard, and is applied as a voluntary baseline for agentic systems.
- Mistral: the Admin API is Enterprise-only and its workspace/API-key response shapes, SCIM support, ISO/IEC 42001 status and audit-log retention are unverified; the moderation category key set is model-version dependent.
- The operative Art 113 text of the EU AI Act as amended could not be machine-extracted; the 2 Dec 2027 and 2 Aug 2028 dates are confirmed from the Omnibus recitals and multiple secondary sources.
- Several clause references in `catalog/controls.yaml` (for example ISO 27001 A.5.1/A.5.2/A.5.29/A.5.30, EU AI Act Art 25/26(2)/26(6)/43(4)/15(4), GDPR Art 24/34/15(1)(h), NZ Privacy Act s 201 and Part 6, AU Privacy Act Part IIIC, Japan APPI Art 28, Singapore PDPA ss 20 and 26, Argentina Ley 25.326 Arts 12 and 20) were added from the instruments' published structure rather than the verification notes. They are believed correct; confirm against the text before citing them in an audit.
- Nothing here is legal advice.
