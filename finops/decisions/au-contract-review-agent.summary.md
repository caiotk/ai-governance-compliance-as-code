## Model selection — `au-contract-review-agent`

Catalogue as of 2026-10-13 · evaluated 2026-10-13 · quality basis: **tier prior (no evals supplied — run the evaluation suite before promotion, AIG-14)**

**Routing:** single-model · expected **$8,043.84/month** across anthropic, openai

Primary: `openai/gpt-6-astra@openai` on openai (specialist-reasoning)

**Fallbacks (BCP):** `openai/gpt-6-astra@azure-foundry` — same model, different platform; `anthropic/claude-opus-5-5@aws-bedrock` — different vendor (anthropic), tier specialist-reasoning

✅ Budget: $8,043.84 of $25,000.00 (32%)

### Ranking

| # | Model | Tier | $/request | $/month | Quality | RAI | Score | Notes |
|---|---|---|---|---|---|---|---|---|
| 1 | `openai/gpt-6-luna@openai` | daily-driver | 0.008820 | 80.44 | 0.60 (prior) | 0.88 | 0.796 | below quality floor |
| 2 | `openai/gpt-6-luna@azure-foundry` | daily-driver | 0.008820 | 80.44 | 0.60 (prior) | 0.70 | 0.760 | below quality floor |
| 3 | `openai/gpt-6.1-sol@openai` | workhorse | 0.173700 | 1,584.14 | 0.80 (prior) | 0.88 | 0.724 | below quality floor |
| 4 | `openai/gpt-6-astra@openai` | specialist-reasoning | 0.882000 | 8,043.84 | 0.95 (prior) | 0.88 | 0.704 |  |
| 5 | `anthropic/claude-opus-5-5@aws-bedrock` | specialist-reasoning | 0.347400 | 3,168.29 | 0.95 (prior) | 0.60 | 0.698 |  |
| 6 | `anthropic/claude-opus-5-5@gcp-vertex` | specialist-reasoning | 0.347400 | 3,168.29 | 0.95 (prior) | 0.60 | 0.698 |  |
| 7 | `anthropic/claude-opus-5-5@azure-foundry` | specialist-reasoning | 0.347400 | 3,168.29 | 0.95 (prior) | 0.60 | 0.698 |  |
| 8 | `anthropic/claude-opus-5-5@anthropic` | specialist-reasoning | 0.347400 | 3,168.29 | 0.95 (prior) | 0.58 | 0.694 |  |
| 9 | `openai/gpt-6.1-sol@azure-foundry` | workhorse | 0.173700 | 1,584.14 | 0.80 (prior) | 0.70 | 0.688 | below quality floor |
| 10 | `anthropic/claude-sonnet-5-5@aws-bedrock` | workhorse | 0.173700 | 1,584.14 | 0.80 (prior) | 0.60 | 0.668 | below quality floor |
| 11 | `anthropic/claude-sonnet-5-5@gcp-vertex` | workhorse | 0.173700 | 1,584.14 | 0.80 (prior) | 0.60 | 0.668 | below quality floor |
| 12 | `anthropic/claude-sonnet-5-5@azure-foundry` | workhorse | 0.173700 | 1,584.14 | 0.80 (prior) | 0.60 | 0.668 | below quality floor |

<details><summary>Excluded model/platform combinations</summary>

- `google/gemini-3.1-pro-preview@gcp-vertex`: preview model (allow_preview=false)
- `google/gemini-3.1-pro-preview@gemini-api`: preview model (allow_preview=false); platform gemini-api not allowed
- `google/gemini-3.8-flash@gemini-api`: platform gemini-api not allowed
- `google/gemini-3.5-flash-lite@gemini-api`: platform gemini-api not allowed
- `mistral/mistral-large-4@mistral`: no reasoning mode; preview model (allow_preview=false); platform mistral not allowed; missing attestation '42001'
- `mistral/mistral-large-2512@mistral`: no reasoning mode; context window 256000 < 406000 needed; platform mistral not allowed; missing attestation '42001'
- `mistral/mistral-medium-3-5@mistral`: no reasoning mode; context window 256000 < 406000 needed; platform mistral not allowed; missing attestation '42001'
- `mistral/mistral-small-2603@mistral`: no vision input; context window 256000 < 406000 needed; platform mistral not allowed; missing attestation '42001'
- `mistral/codestral-2508@mistral`: code-specialised model; task is not code; no vision input; no reasoning mode; context window 128000 < 406000 needed; platform mistral not allowed; missing attestation '42001'
- `mistral/ministral-8b-2512@mistral`: no reasoning mode; context window 256000 < 406000 needed; platform mistral not allowed; missing attestation '42001'
- `mistral/mistral-moderation-2603@mistral`: safety classifier, not a generation model; no text input; no vision input; no tool calling; no structured output; no reasoning mode; context window 128000 < 406000 needed; platform mistral not allowed; missing attestation '42001'
- `amazon/nova-2-lite@aws-bedrock`: no structured output
- `amazon/nova-pro@aws-bedrock`: no structured output; no reasoning mode; context window 300000 < 406000 needed
- `amazon/nova-lite@aws-bedrock`: no structured output; no reasoning mode; context window 300000 < 406000 needed
- `amazon/nova-micro@aws-bedrock`: no vision input; no tool calling; no structured output; no reasoning mode; context window 128000 < 406000 needed
- `amazon/nova-premier@aws-bedrock`: no structured output; no reasoning mode
- `meta/llama4-maverick-17b@aws-bedrock`: no structured output; no reasoning mode; legacy model (allow_legacy=false)
- `meta/llama4-scout-17b@aws-bedrock`: no tool calling; no structured output; no reasoning mode; legacy model (allow_legacy=false)
- `deepseek/deepseek-flash@deepseek`: platform deepseek not allowed; missing attestation '42001'
- `deepseek/deepseek-v4-pro@deepseek`: no vision input; platform deepseek not allowed; missing attestation '42001'

</details>

**Warnings**

- ⚠️ google/gemini-3.8-flash: price changes on 2027-01-01: input 1.5, cached_input 0.15, cache_storage_per_hour 1.0, output 7.5
- ⚠️ quality scores are tier priors, not measurements; the recommendation is provisional until quality.evals is filled from your evaluation suite
