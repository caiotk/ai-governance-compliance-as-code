# Vendor pack specification

Every vendor pack lives in `vendors/<vendor-id>/` and has the same shape, so CI and the profile generator can treat them uniformly.

```
vendors/<vendor-id>/
  README.md              what the pack enforces, how to apply it (Terraform and native), verified-as-of date, known gaps
  mapping.yaml           machine-readable control mapping (schema below)
  terraform/
    versions.tf          required_version >= 1.6 and pinned required_providers (~> major.minor)
    variables.tf         every input with description and type; secure defaults
    main.tf (or split)   resources
    outputs.tf
    terraform.tfvars.example
  native/                the vendor's own format(s): ARM/Bicep/Azure Policy JSON, CloudFormation/SCP JSON,
                         gcloud org-policy YAML, Power Platform DLP JSON + PowerShell, REST API scripts, etc.
```

## Rules

1. **Verified syntax only.** Resource types, argument names, policy GUIDs, constraint names, API paths and enum values must come from vendor documentation cited in `mapping.yaml` / `docs/SOURCES.md` or from the provider schema itself (`terraform providers schema -json`). Anything you could not confirm is left out or included commented out with a `# UNVERIFIED:` note.
2. **Secure by default.** Defaults deny: local keys disabled, public network disabled, approved-model allow-lists, guardrails on, logging on.
3. **Every resource carries its control IDs** in a comment above it, e.g. `# AIG-06 AIG-10`, and the same IDs appear in `mapping.yaml`.
4. **Validation must pass locally before you finish:**
   - `terraform fmt -check -recursive` and `terraform init -backend=false && terraform validate` in each `terraform/` directory.
   - Bicep: `bicep build <file> --stdout > /dev/null`.
   - CloudFormation: `cfn-lint <file>`.
   - JSON: `python3 -m json.tool`; YAML: `python3 -c "import yaml,sys;yaml.safe_load(open(sys.argv[1]))"`.
   - Shell: `bash -n`; PowerShell: syntax only (no runtime available — keep it simple and documented).
5. No credentials, tenant IDs or real account IDs — use variables and placeholders.
6. `tools/ci.sh` runs all of the above; it must pass before a pull request is opened.

## mapping.yaml schema

```yaml
apiVersion: aigov/v1
kind: VendorPack
vendor: <vendor-id>
name: <display name>
verified: "2026-10-13"
native_tools:
  - { name: <tool>, url: <vendor doc url> }
attestations:
  - { name: "ISO/IEC 42001:2023", url: <vendor url>, scope: <short scope note> }
implements:
  - control: AIG-07
    summary: <one line: what this pack does for the control>
    terraform: [terraform/main.tf#azurerm_cognitive_account.this]
    native: [native/bicep/ai-account.bicep]
gaps:
  - control: AIG-11
    note: <why the platform cannot enforce it and where it must be handled instead>
```

Control IDs (from `catalog/controls.yaml`):
AIG-01 governance & ownership · AIG-02 inventory · AIG-03 risk/impact assessment · AIG-04 data governance · AIG-05 personal data protection · AIG-06 approved models & supply chain · AIG-07 workload/agent identity & least privilege · AIG-08 network isolation & residency · AIG-09 encryption/CMK · AIG-10 runtime guardrails & content safety · AIG-11 human oversight · AIG-12 transparency · AIG-13 logging & monitoring · AIG-14 testing/red-teaming · AIG-15 change management · AIG-16 incidents · AIG-17 resilience/exit · AIG-18 cross-border · AIG-19 literacy · AIG-20 fairness · AIG-21 internal audit & assurance · AIG-22 AI FinOps (budgets, token limits, allocation).
