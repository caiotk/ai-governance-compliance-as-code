# Contributing

This project is free and open source under the [Apache License 2.0](LICENSE).
Contributions of catalogue facts, policies, vendor packs, tooling and
documentation are welcome.

## Before your first pull request

1. **Sign the CLA.** The CLA bot asks on your first pull request; reply with
   the sentence it quotes. The text is in [CLA.md](CLA.md): you keep your
   rights, you grant a copyright and patent licence, and you confirm the
   facts you add are sourced.
2. **Do not use the reserved names** for forks or products
   ([TRADEMARKS.md](TRADEMARKS.md)).

## Ground rules

- **Facts go in `catalog/`, never in generated files.** `profiles/`,
  `docs/CROSSWALK.md`, `docs/RISKS.md`, `mlops/data/catalog.json` and
  `site/data/catalog.json` are produced by `python3 tools/build.py`; CI fails
  if they are stale.
- **Every fact has a source and a label.** `primary` (checked against the
  issuer's text), `secondary` (reputable secondary source, re-check before
  reliance) or `unverified`. Add the citation to `docs/SOURCES.md` or the
  matching `docs/sources/*.md`. Do not reproduce the text of a standard.
- **Policies are tested.** A new Rego rule needs a test in
  `mlops/tests/aigov_test.rego` for both the violation and the compliant case.
- **Vendor packs follow the spec** in
  [docs/VENDOR_PACK_SPEC.md](docs/VENDOR_PACK_SPEC.md): verified syntax only,
  secure defaults, control IDs on every resource.
- **Not legal advice.** Describe obligations; do not advise.

## Local setup

```bash
git clone https://github.com/caiotk/ai-governance-compliance-as-code
cd ai-governance-compliance-as-code
make setup        # Python deps + checks for opa, terraform, bicep, cfn-lint
make build        # validate the catalogue and regenerate derived files
make test         # everything CI runs (terraform optional: make test TF=0)
```

Or open the repository in a dev container / GitHub Codespace: the
`.devcontainer` image has every tool pinned to the versions CI uses.

## Pull request checklist

- [ ] `make build` ran and the regenerated files are committed
- [ ] `make test` passes locally (or `make test TF=0` if you have no Terraform)
- [ ] New catalogue entries carry `verification:` and a source citation
- [ ] New Rego rules have tests; new tools have a `--help` and a CI step
- [ ] `CHANGELOG.md` has an entry under **Unreleased**
- [ ] No credentials, tenant IDs, account IDs or customer data

## Branches, reviews and releases

- `main` is protected: pull requests only, one approving review from a code
  owner (`.github/CODEOWNERS`), required status check **Validate policy
  packs**, linear history.
- Changes to `catalog/`, `mlops/policies/` and `vendors/` are owned by the
  maintainers listed in `CODEOWNERS`; their review is required.
- Releases are tagged `vMAJOR.MINOR.PATCH` and cut by the **Release**
  workflow, which attaches the catalogue bundle and the NXGD-AIGovMap visual.
  Consumers pin the reusable gate workflow to a tag:
  `uses: caiotk/ai-governance-compliance-as-code/.github/workflows/ai-governance-gate.yml@v1`.

## Reporting a security issue

See [SECURITY.md](SECURITY.md). Do not open a public issue for
vulnerabilities.

## Commercial edition

Features that need a server — an evidence database, approval workflows, PDF
audit packs, a hosted API — live in the NexGuide.AI GovMap edition
([docs/EDITIONS.md](docs/EDITIONS.md)). Contributions to this repository
stay open source; the CLA lets them also ship in that edition.
