# Editions

**AI Governance Compliance as Code is free and open source** under the
[Apache License 2.0](../LICENSE). Everything in this repository — the
catalogue, the 22 controls, the risk catalogue, the gate, the vendor packs,
the inventory, hooks, reports, the API and the MCP server — can be used,
modified and redistributed without charge, including commercially, subject
only to the [trademark policy](../TRADEMARKS.md).

**NexGuide.AI GovMap** is the commercial edition built on this repository by
its author. It adds what needs a server, a database and a team behind it:
evidence storage, approvals, PDF audit packs, hosted API and webhooks,
platform imports and support. The open-source edition is not a trial: it is
complete for teams that run governance from git.

## Side by side

| Capability | Open source (this repository) | NexGuide.AI GovMap |
|---|---|---|
| Catalogue: 30 frameworks, 22 controls, 36 risks, 70 country × sector profiles, 8 vendor packs | ✅ | ✅ same catalogue, updated continuously with a change log per obligation |
| MLOps gate (OPA/Rego), reusable GitHub Actions workflow, SARIF | ✅ | ✅ plus a hosted gate endpoint for any CI (GitLab, Azure DevOps, Jenkins) |
| System records and inventory | ✅ YAML in `systems/`, Markdown/CSV/JSON register | ✅ database-backed register with search, ownership views, bulk edit, history |
| Platform import of models, agents and deployments | — | ✅ import from Azure AI Foundry, Amazon Bedrock and Copilot Studio inventory exports; direct API sync on the roadmap |
| Evidence | ✅ evidence-as-code block with freshness checks | ✅ evidence vault: upload, hash, versioning, reuse across systems, expiry reminders, reviewer sign-off |
| Workflow | ✅ CODEOWNERS, required reviews, review-reminder issues | ✅ approval workflows with roles (owner, risk, privacy, security, legal), audit trail; SLAs and delegation on the roadmap |
| Runtime hooks | ✅ webhook receiver → incident records in git | ✅ hosted receivers, triage queue, automatic gate re-evaluation, promotion block on critical incidents |
| Notifications | GitHub issues | Slack and Microsoft Teams (incoming webhooks); Jira and ServiceNow on the roadmap |
| Reports | ✅ Markdown audit pack per system | ✅ PDF audit packs with the evidence register attached, portfolio dashboard; board packs and trends on the roadmap |
| API and MCP | ✅ read-only, self-hosted | ✅ API with write operations, API keys and roles; SSO (OIDC) on the roadmap |
| Multi-organisation / multi-tenant | — | roadmap |
| Regulatory watch | ✅ weekly issue from the catalogue | ✅ same watch; Slack/Teams delivery with affected systems on the roadmap |
| FinOps and BCP/DR tooling | ✅ | ✅ (same tooling) |
| Support | Community (issues, discussions) | Commercial support, onboarding, catalogue advisory |
| Licence | Apache-2.0 | Commercial subscription |

## How the two stay compatible

- The **record schema** (`mlops/schema/ai-system.schema.json`), the control
  and risk identifiers, and the gate decision shape are the same in both
  editions. Records move between them without conversion.
- GovMap **reads this repository** as its catalogue source, pinned to a
  release tag; corrections flow back here as pull requests.
- The commercial edition does not fork the policies: a gate result in
  GovMap is the same Rego evaluated against the same catalogue version.

## Where the pointers are

Inside the open-source tools you will see short notes such as "available in
NexGuide.AI GovMap" where a capability begins that this edition does not
include (PDF export in `tools/report.py`, the evidence database in
`systems/README.md`, triage in `incidents/README.md`). They mark the boundary;
they never remove function from the open edition.

## Contact

Discussions on this repository or https://www.linkedin.com/in/caiotk.
NexGuide.AI, NexGuide.AI GovMap and NXGD-AIGovMap are trademarks of Caio
Augusto Tkalec ([TRADEMARKS.md](../TRADEMARKS.md)).
