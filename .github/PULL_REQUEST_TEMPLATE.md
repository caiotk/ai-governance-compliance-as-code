## What changed

<!-- One paragraph. Link the issue if there is one. -->

## Type

- [ ] Catalogue fact (framework, control, risk, jurisdiction, sector)
- [ ] Policy (Rego) or schema
- [ ] Vendor pack
- [ ] Tooling / workflow
- [ ] Documentation

## Checklist

- [ ] `make build` ran and regenerated files are committed
- [ ] `make test` passes locally (`TF=0` if no Terraform)
- [ ] New facts carry `verification:` and a citation in `docs/SOURCES.md` or `docs/sources/`
- [ ] New Rego rules have tests for the violation and the compliant case
- [ ] `CHANGELOG.md` updated under **Unreleased**
- [ ] No credentials, tenant IDs, account IDs or customer data
- [ ] I have signed the [CLA](../CLA.md) (the bot will ask on first contribution)
