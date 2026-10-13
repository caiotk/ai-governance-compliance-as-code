# Mistral AI — data location, retention and training (AIG-05 AIG-08 AIG-18)

Verified 2026-10-13 against docs.mistral.ai, help.mistral.ai and legal.mistral.ai.

## Where data is processed

- Mistral's own API (La Plateforme) runs on **servers located in Europe (Sweden)** (help article 156206). No customer-selectable region is documented — **UNVERIFIED** whether one exists. For EU/EEA customers this is in-region processing; for AU, NZ, Japan, Singapore, LatAm and US customers it is a cross-border transfer to the EU that the system record must declare (`data.cross_border_transfer: true`, `transfer_mechanism`).
- Hosting providers are selected "within the European Union" as a priority, non-EU "in exceptional cases"; transfers rely on SCCs; the subprocessor list is at https://trust.mistral.ai/subprocessors (Privacy Policy effective 2026-09-03).
- **Other routes:** Mistral models are also served on Azure AI, Amazon Bedrock, Google Cloud Vertex AI Model Garden, Snowflake Cortex, IBM watsonx and Outscale, and can be self-deployed (vLLM recommended). On those routes identity, network, logging and residency are governed by the hosting platform — apply the `azure-foundry`, `aws-bedrock` or `gcp-vertex` pack instead of this one and record `model.vendor` accordingly.

## Retention and Zero Data Retention (ZDR)

- Default: API inputs and outputs are kept for generation and then for **30 rolling days** for abuse monitoring (Privacy Policy). Agents API data is kept until account termination; fine-tuning data until deleted.
- **ZDR** (docs: admin/monitor-comply/zero-data-retention): Mistral does not store or log inputs/outputs beyond generation for the stateless endpoints `/v1/chat/completions`, `/v1/fim/completions`, `/v1/embeddings`, `/v1/moderations`, `/v1/chat/moderations`, `/v1/classifications`, `/v1/chat/classifications`, `/v1/ocr`, `/v1/audio/speech`, `/v1/audio/transcriptions` (all models except Labs). **Not covered:** Agents, Batch files, Conversations, Libraries, `/v1/files`, Vibe Work, Chat. ZDR is granted **on request to support**, case by case, and shows at https://admin.mistral.ai/vibe/privacy — record the approval in the system record (`supplier.no_training_on_customer_data`, `data` section).

## Training on customer data

- Commercial Terms of Service (effective 2026-09-25) §4.2: Mistral "will not use Customer Data or Outputs to train" its models except in the listed cases (opt-in / non-opted-out users, Feedback, Order Form, Labs/Preview models). §4.3: **Labs/Preview models are training-eligible and ZDR does not apply to them** — keep them off the approved-model list (AIG-06) for regulated workloads.
- The training opt-out is a separate control under Privacy and data controls in the Admin Panel.

## Contractual artefacts to file as evidence

| Artefact | URL |
|---|---|
| Data Processing Addendum | https://legal.mistral.ai/terms/data-processing-addendum |
| Commercial Terms of Service | https://legal.mistral.ai/terms/commercial-terms-of-service |
| Privacy Policy | https://legal.mistral.ai/terms/privacy-policy |
| Usage Policy (effective 2026-06-11) | https://legal.mistral.ai/terms/usage-policy |
| Partner-served deployment terms | https://legal.mistral.ai/terms/partner-served-deployment-terms |
| SOC 2 Type II / ISO 27001 / ISO 27701 reports | https://trust.mistral.ai/resources (gated) |

Governing law (Commercial Terms §14.10): California for the Americas, Singapore for APAC, France for the rest of the world.
