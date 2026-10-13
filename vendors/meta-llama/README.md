# Meta Llama pack (open weights)

**Verified as of 2026-10-13** against these sources:

- llama.com / dev.meta.ai
- github.com/meta-llama/PurpleLlama
- github.com/ogx-ai/ogx
- the provider schemas for hashicorp/google 8.6, hashicorp/azurerm 5.9 and hashicorp/aws 6.68
- the AWS, Microsoft and Google documentation cited in `mapping.yaml` and docs/SOURCES.md

## Purpose

Llama is released as open weights, so Meta runs no control plane you can configure. Governance happens in three places:

1. **Where the model is hosted.** On Vertex AI, Microsoft Foundry or Amazon Bedrock, this pack restricts which Llama models may be used (AIG-06).
2. **At runtime.** Llama Guard 4, Prompt Guard 2, LlamaFirewall and OGX moderation provide guardrails (AIG-10).
3. **Under the Llama 4 Community License and AUP.** The license obligations are tracked as a checklist: attribution, naming, NOTICE, the 700M MAU clause, the AUP and the EU multimodal restriction (AIG-06, AIG-12).

## What is enforced

| Control | Mechanism | File |
|---|---|---|
| AIG-06 approved models (Vertex) | `google_org_policy_policy` on `vertexai.allowedModels`, with values such as `publishers/meta/models/llama3:deploy` | `terraform/main.tf` |
| AIG-06 approved models (Foundry) | `azurerm_management_group_policy_assignment` of built-in policy `aafe3651-cb78-4f68-9f81-e7e41509110f` "Foundry model deployments should only use approved models" (`allowedPublishers`, `allowedAssetIds`, effect Deny) | `terraform/main.tf` |
| AIG-06 approved models (Bedrock) | `aws_organizations_policy` (SCP) that denies `bedrock:InvokeModel*` and `CreateModelInvocationJob` on any resource except the approved `foundation-model` and inference-profile ARNs | `terraform/main.tf` |
| AIG-06 / AIG-12 / AIG-18 license | Llama 4 Community License and AUP obligations, some with automatable rules | `native/license-compliance.yaml` |
| AIG-10 guardrails | Llama Guard 4 S1–S14 policy (block/flag, fail closed) | `native/llama-guard-policy.yaml` |
| AIG-10 guardrails | Prompt Guard 2 / LlamaFirewall input gate | `native/llamafirewall_gate.py` |
| AIG-10 guardrails | OGX `/v1/moderations` | `native/moderation-ogx.md` |
| AIG-14 testing | CyberSecEval 4 before release (see below) | this README |

## Apply with Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # set enable_* = true only for the hosts you use
terraform init
terraform plan -out=tfplan && terraform apply tfplan
```

Things to know before you apply:

- **Every host is off by default** (`enable_* = false`).
- **`terraform validate` needs no credentials, but `terraform plan` does.** Plan configures the google, azurerm and aws providers, so supply credentials for each. Alternatively, delete the provider blocks and resources for clouds you don't use.
- **Each mechanism is an allow-list for every model in its scope, not only Llama.**
  - `vertexai.allowedModels` blocks every Model Garden model that is not listed, including Gemini. Put approved non-Meta models in `additional_vertex_allowed_models`.
  - The Bedrock SCP denies inference on every foundation model that is not listed. Include approved non-Meta models, and the inference profiles your workloads call. Restricting only `foundation-model` ARNs may not cover calls made through an inference profile.
  - The Foundry policy matches `model.assetId` as a **case-sensitive prefix**. A trailing `/` limits the match to one model, and `/versions/N` pins a version. Add publisher `Microsoft` if you use model router.
- **Roll out in stages.** Start with `azure_policy_effect = "Audit"` and an SCP attached to a sandbox OU, then move to Deny.
- **The Bedrock guardrail and invocation logging are not repeated here.** They live in the Bedrock pack and apply to Llama on Bedrock unchanged.

## Apply natively

The native files are vendor-format artifacts for self-hosted or hosted Llama:

- **`native/llama-guard-policy.yaml`** holds the per-category policy for a Llama Guard 4 (`meta-llama/Llama-Guard-4-12B`) gate on both input and output. Match on the category **codes** (S1–S14). Labels differ between the model card and the llama.com prompt template for S3, S4 and S11, so both are listed.
- **`native/llamafirewall_gate.py`** is a PromptGuard 2 input gate (`pip install llamafirewall`). It is an example and is not executed in CI.
- **`native/moderation-ogx.md`** covers OGX >= 1.0: set `moderation_endpoint` on the `inline::builtin` responses provider. The Safety/Shields API was **removed** in OGX 1.0, and the v0.7.x shield YAML is included only as a clearly labelled legacy example.
- **`native/license-compliance.yaml`** feeds your model registry or OPA checks. One example is denying Llama 4 multimodal models for licensees whose principal place of business is in the EU.

Testing (AIG-14): run CyberSecEval 4 (`python3 -m CybersecurityBenchmarks.benchmark.run --benchmark=...`) against every approved Llama model or fine-tune before release. At minimum run `prompt-injection`, `interpreter`, `mitre-frr` and `instruct`. Keep the stat files as release evidence. CyberSOCEval and AutoPatchBench are the additions in version 4.

## Prerequisites

| Host | Permission needed |
|---|---|
| Vertex AI | Org Policy Administrator on the organization, folder or project parent |
| Azure | Resource Policy Contributor (or higher) on the management group |
| AWS | Organizations management account (or delegated policy administrator), with SCPs enabled |

The runtime gates need GPU or CPU capacity for Llama Guard 4 (12B, single GPU) and Prompt Guard 2 (86M or 22M).

## Unverified / known gaps

- **Exact Llama 4 model identifiers per cloud are UNVERIFIED.** This covers Vertex `publishers/meta/models/...` names, the Foundry `model.publisher` string and asset IDs, and Bedrock `meta.*` model IDs. Copy them from each catalog. The only verified value is the Google example `publishers/meta/models/llama3:deploy`.
- **The ScannerType values `AGENT_ALIGNMENT` and `CODE_SHIELD` are UNVERIFIED in the research set.** They appear in the LlamaFirewall README Trace example and in the package source, so they are left commented out in `llamafirewall_gate.py`.
- **The OGX `providers.responses` YAML nesting is UNVERIFIED.** The field names `moderation_endpoint` and `moderation_headers` are verified.
- **Llama-specific default content filters on hosted clouds are UNVERIFIED** (Bedrock Guardrails, Azure AI Content Safety, Model Armor). Apply the cloud packs' guardrails explicitly.
- **The CodeShield language count conflicts** between sources: the README says 8 languages and the llama.com Protections page says 7.
- **Operator responsibility for self-hosted Llama:**
  - identity (AIG-07)
  - network isolation (AIG-08)
  - prompt and response logging (AIG-13)
  - weight integrity

  Use the zero-trust controls: workload identity and mTLS in front of the inference server, private networking, and gateway logs sent to the SIEM.
- **Meta publishes no attestations for open weights.** The host's attestations apply (the AWS, Azure and Google Cloud packs).
