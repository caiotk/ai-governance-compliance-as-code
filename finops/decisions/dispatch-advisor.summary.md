## Model selection — `dispatch-advisor`

Catalogue as of 2026-10-13 · evaluated 2026-10-13 · quality basis: **mixed**

**Routing:** single-model · expected **$4,742.40/month** across anthropic

Primary: `anthropic/claude-sonnet-5-5@aws-bedrock` on aws-bedrock (workhorse)

**Fallbacks (BCP):** `anthropic/claude-sonnet-5-5@gcp-vertex` — same model, different platform

✅ Budget: $4,742.40 of $12,000.00 (40%)

### Ranking

| # | Model | Tier | $/request | $/month | Quality | RAI | Score | Notes |
|---|---|---|---|---|---|---|---|---|
| 1 | `anthropic/claude-haiku-5-5@aws-bedrock` | daily-driver | 0.004050 | 246.24 | 0.60 (prior) | 0.60 | 0.740 | below quality floor |
| 2 | `anthropic/claude-haiku-5-5@gcp-vertex` | daily-driver | 0.004050 | 246.24 | 0.60 (prior) | 0.60 | 0.740 | below quality floor |
| 3 | `anthropic/claude-sonnet-5-5@aws-bedrock` | workhorse | 0.078000 | 4,742.40 | 0.92 (measured) | 0.60 | 0.721 |  |
| 4 | `anthropic/claude-sonnet-5-5@gcp-vertex` | workhorse | 0.078000 | 4,742.40 | 0.92 (measured) | 0.60 | 0.721 |  |
| 5 | `anthropic/claude-opus-5-5@aws-bedrock` | specialist-reasoning | 0.156000 | 9,484.80 | 0.95 (measured) | 0.60 | 0.667 |  |
| 6 | `anthropic/claude-opus-5-5@gcp-vertex` | specialist-reasoning | 0.156000 | 9,484.80 | 0.95 (measured) | 0.60 | 0.667 |  |
| 7 | `google/gemini-3.8-flash@gcp-vertex` | workhorse | 0.033412 | 2,031.48 | 0.80 (prior) | 0.30 | 0.654 | price changes on 2027-01-01: input 1.5, cached_input 0.15, cache_storage_per_hour 1.0, output 7.5; 1.1x regional; below quality floor |
| 8 | `anthropic/claude-fable-5-1@aws-bedrock` | specialist-reasoning | 0.382500 | 23,256.00 | 0.95 (prior) | 0.60 | 0.618 | below quality floor |
| 9 | `anthropic/claude-fable-5-1@gcp-vertex` | specialist-reasoning | 0.382500 | 23,256.00 | 0.95 (prior) | 0.60 | 0.618 | below quality floor |
| 10 | `google/gemini-3.5-flash-lite@gcp-vertex` | daily-driver | 0.015015 | 912.91 | 0.60 (prior) | 0.30 | 0.608 | 1.1x regional; below quality floor |

<details><summary>Excluded model/platform combinations</summary>

- `openai/gpt-6-astra@openai`: platform openai not allowed; cannot process in ['au'] via openai
- `openai/gpt-6-astra@azure-foundry`: cannot process in ['au'] via azure-foundry
- `openai/gpt-6.1-sol@openai`: platform openai not allowed; cannot process in ['au'] via openai
- `openai/gpt-6.1-sol@azure-foundry`: cannot process in ['au'] via azure-foundry
- `openai/gpt-6-luna@openai`: platform openai not allowed; cannot process in ['au'] via openai
- `openai/gpt-6-luna@azure-foundry`: cannot process in ['au'] via azure-foundry
- `anthropic/claude-fable-5-1@anthropic`: platform anthropic not allowed; cannot process in ['au'] via anthropic
- `anthropic/claude-fable-5-1@azure-foundry`: cannot process in ['au'] via azure-foundry
- `anthropic/claude-opus-5-5@anthropic`: platform anthropic not allowed; cannot process in ['au'] via anthropic
- `anthropic/claude-opus-5-5@azure-foundry`: cannot process in ['au'] via azure-foundry
- `anthropic/claude-sonnet-5-5@anthropic`: platform anthropic not allowed; cannot process in ['au'] via anthropic
- `anthropic/claude-sonnet-5-5@azure-foundry`: cannot process in ['au'] via azure-foundry
- `anthropic/claude-haiku-5-5@anthropic`: platform anthropic not allowed; cannot process in ['au'] via anthropic
- `anthropic/claude-haiku-5-5@azure-foundry`: cannot process in ['au'] via azure-foundry
- `google/gemini-3.1-pro-preview@gcp-vertex`: preview model (allow_preview=false); cannot process in ['au'] via gcp-vertex
- `google/gemini-3.1-pro-preview@gemini-api`: preview model (allow_preview=false); platform gemini-api not allowed; cannot process in ['au'] via gemini-api
- `google/gemini-3.8-flash@gemini-api`: platform gemini-api not allowed
- `google/gemini-3.5-flash-lite@gemini-api`: platform gemini-api not allowed
- `mistral/mistral-large-4@mistral`: no reasoning mode; preview model (allow_preview=false); platform mistral not allowed; cannot process in ['au'] via mistral; missing attestation '42001'
- `mistral/mistral-large-2512@mistral`: no reasoning mode; platform mistral not allowed; cannot process in ['au'] via mistral; missing attestation '42001'
- `mistral/mistral-medium-3-5@mistral`: no reasoning mode; platform mistral not allowed; cannot process in ['au'] via mistral; missing attestation '42001'
- `mistral/mistral-small-2603@mistral`: platform mistral not allowed; cannot process in ['au'] via mistral; missing attestation '42001'
- `mistral/codestral-2508@mistral`: code-specialised model; task is not code; no reasoning mode; context window 128000 < 201500 needed; platform mistral not allowed; cannot process in ['au'] via mistral; missing attestation '42001'
- `mistral/ministral-8b-2512@mistral`: no reasoning mode; platform mistral not allowed; cannot process in ['au'] via mistral; missing attestation '42001'
- `mistral/mistral-moderation-2603@mistral`: safety classifier, not a generation model; no text input; no tool calling; no structured output; no reasoning mode; context window 128000 < 201500 needed; platform mistral not allowed; cannot process in ['au'] via mistral; missing attestation '42001'
- `amazon/nova-2-lite@aws-bedrock`: no structured output; cannot process in ['au'] via aws-bedrock
- `amazon/nova-pro@aws-bedrock`: no structured output; no reasoning mode; cannot process in ['au'] via aws-bedrock
- `amazon/nova-lite@aws-bedrock`: no structured output; no reasoning mode; cannot process in ['au'] via aws-bedrock
- `amazon/nova-micro@aws-bedrock`: no tool calling; no structured output; no reasoning mode; context window 128000 < 201500 needed; cannot process in ['au'] via aws-bedrock
- `amazon/nova-premier@aws-bedrock`: no structured output; no reasoning mode; cannot process in ['au'] via aws-bedrock
- `meta/llama4-maverick-17b@aws-bedrock`: no structured output; no reasoning mode; legacy model (allow_legacy=false); cannot process in ['au'] via aws-bedrock
- `meta/llama4-scout-17b@aws-bedrock`: no tool calling; no structured output; no reasoning mode; legacy model (allow_legacy=false); cannot process in ['au'] via aws-bedrock
- `deepseek/deepseek-flash@deepseek`: platform deepseek not allowed; cannot process in ['au'] via deepseek; no verified attestations for regulated data; missing attestation '42001'
- `deepseek/deepseek-v4-pro@deepseek`: platform deepseek not allowed; cannot process in ['au'] via deepseek; no verified attestations for regulated data; missing attestation '42001'

</details>

**Warnings**

- ⚠️ google/gemini-3.8-flash: price changes on 2027-01-01: input 1.5, cached_input 0.15, cache_storage_per_hour 1.0, output 7.5
- ⚠️ only 1 vendor(s) satisfy the constraints; min_vendors_for_resilience=2 not met — BCP depends on a single vendor
