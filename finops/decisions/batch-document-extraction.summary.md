## Model selection — `batch-document-extraction`

Catalogue as of 2026-10-13 · evaluated 2026-10-13 · quality basis: **mixed**

**Routing:** single-model · expected **$851.20/month** across anthropic, openai

Primary: `openai/gpt-6-luna@openai` on openai (daily-driver)

**Fallbacks (BCP):** `openai/gpt-6-luna@azure-foundry` — same model, different platform; `anthropic/claude-haiku-5-5@aws-bedrock` — different vendor (anthropic), tier daily-driver

✅ Budget: $851.20 of $6,000.00 (14%)

### Ranking

| # | Model | Tier | $/request | $/month | Quality | RAI | Score | Notes |
|---|---|---|---|---|---|---|---|---|
| 1 | `openai/gpt-6-luna@openai` | daily-driver | 0.000140 | 851.20 | 0.93 (measured) | 0.88 | 0.958 |  |
| 2 | `openai/gpt-6-luna@azure-foundry` | daily-driver | 0.000140 | 851.20 | 0.93 (measured) | 0.70 | 0.930 |  |
| 3 | `anthropic/claude-haiku-5-5@aws-bedrock` | daily-driver | 0.000140 | 851.20 | 0.94 (measured) | 0.60 | 0.919 |  |
| 4 | `anthropic/claude-haiku-5-5@gcp-vertex` | daily-driver | 0.000140 | 851.20 | 0.94 (measured) | 0.60 | 0.919 |  |
| 5 | `anthropic/claude-haiku-5-5@azure-foundry` | daily-driver | 0.000140 | 851.20 | 0.94 (measured) | 0.60 | 0.919 |  |
| 6 | `anthropic/claude-haiku-5-5@anthropic` | daily-driver | 0.000140 | 851.20 | 0.94 (measured) | 0.58 | 0.916 |  |
| 7 | `mistral/ministral-8b-2512@mistral` | daily-driver | 0.000150 | 912.00 | 0.86 (measured) | 0.58 | 0.883 | below quality floor |
| 8 | `google/gemini-3.5-flash-lite@gcp-vertex` | daily-driver | 0.000520 | 3,161.60 | 0.92 (measured) | 0.30 | 0.767 |  |
| 9 | `google/gemini-3.5-flash-lite@gemini-api` | daily-driver | 0.000520 | 3,161.60 | 0.92 (measured) | 0.30 | 0.767 |  |
| 10 | `mistral/mistral-large-2512@mistral` | workhorse | 0.000600 | 3,648.00 | 0.80 (prior) | 0.58 | 0.756 | below quality floor |
| 11 | `openai/gpt-6.1-sol@openai` | workhorse | 0.002800 | 17,024.00 | 0.80 (prior) | 0.88 | 0.684 | below quality floor |
| 12 | `google/gemini-3.8-flash@gcp-vertex` | workhorse | 0.001050 | 6,384.00 | 0.80 (prior) | 0.30 | 0.672 | price changes on 2027-01-01: input 1.5, cached_input 0.15, cache_storage_per_hour 1.0, output 7.5; below quality floor |

<details><summary>Excluded model/platform combinations</summary>

- `google/gemini-3.1-pro-preview@gcp-vertex`: preview model (allow_preview=false)
- `google/gemini-3.1-pro-preview@gemini-api`: preview model (allow_preview=false)
- `mistral/mistral-large-4@mistral`: preview model (allow_preview=false)
- `mistral/mistral-small-2603@mistral`: no vision input
- `mistral/codestral-2508@mistral`: code-specialised model; task is not code; no vision input
- `mistral/mistral-moderation-2603@mistral`: safety classifier, not a generation model; no text input; no vision input; no structured output
- `amazon/nova-2-lite@aws-bedrock`: no structured output
- `amazon/nova-pro@aws-bedrock`: no structured output
- `amazon/nova-lite@aws-bedrock`: no structured output
- `amazon/nova-micro@aws-bedrock`: no vision input; no structured output
- `amazon/nova-premier@aws-bedrock`: no structured output
- `meta/llama4-maverick-17b@aws-bedrock`: no structured output; legacy model (allow_legacy=false)
- `meta/llama4-scout-17b@aws-bedrock`: no structured output; legacy model (allow_legacy=false)
- `deepseek/deepseek-v4-pro@deepseek`: no vision input

</details>

**Warnings**

- ⚠️ google/gemini-3.8-flash: price changes on 2027-01-01: input 1.5, cached_input 0.15, cache_storage_per_hour 1.0, output 7.5
