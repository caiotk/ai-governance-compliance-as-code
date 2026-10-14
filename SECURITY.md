# Security policy

## Supported versions

| Version | Supported |
|---|---|
| `main` and the latest `v1.x` tag | Yes |
| Older tags | No — upgrade |

## Reporting a vulnerability

Please use **GitHub private vulnerability reporting** on this repository
(Security tab → "Report a vulnerability"). Do not open a public issue.

Include what you found, where (file and line, or workflow), how to reproduce
it, and what you think the impact is. You will get an acknowledgement within
5 working days and a fix or a decision within 30 days for confirmed issues.

## What counts

- A Rego rule that lets a non-compliant record pass (`allow` when a `deny`
  should fire), or that can be bypassed by a crafted record.
- A gate, inventory, API, MCP or webhook tool that executes untrusted input,
  writes outside its target directory, or leaks secrets into logs or job
  summaries.
- Workflow permissions wider than needed, unpinned third-party actions, or
  injection through `${{ }}` expressions.
- A vendor pack whose "secure by default" claim is false (for example a
  Terraform default that leaves public network access on).

Catalogue inaccuracies (a wrong date, clause or status) are not security
issues; open an ordinary issue with the "Catalogue correction" template.

## Design notes for reviewers

- `tools/gate.py` evaluates records with a local `opa` binary; records are
  data, never executed.
- `hooks/receiver.py` accepts only the event shapes documented in
  `hooks/README.md`, verifies the shared secret (`AIGOV_WEBHOOK_SECRET`)
  with a constant-time comparison, and writes incident records with
  sanitised identifiers only.
- `api/server.py` and `mcp/server.py` are read-only over the generated
  catalogue, the inventory and gate results; they take no write operations.
- Workflows run with `permissions: contents: read` unless a step needs more,
  and third-party actions are pinned to a major version maintained by its
  vendor.
