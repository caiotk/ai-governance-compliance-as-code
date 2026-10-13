## Model selection — `eu-support-chatbot`

Catalogue as of 2026-10-13 · evaluated 2026-10-13 · quality basis: **mixed**

**Routing:** multi-model-cascade · expected **$2,646.78/month** across mistral, openai

| Role | Share | Model | Platform | Tier |
|---|---|---|---|---|
| primary | 70% | `openai/gpt-6-luna@openai` | openai | daily-driver |
| escalation | 25% | `mistral/mistral-large-2512@mistral` | mistral | workhorse |
| specialist | 5% | `openai/gpt-6-astra@openai` | openai | specialist-reasoning |

Cascade saves 93% vs the best single model (`openai/gpt-6-astra@openai`, $38,790.40/month). Escalate on: context_window, tool_error, low_confidence, explicit_tag.

**Fallbacks (BCP):** `mistral/mistral-large-2512@mistral` — different vendor (mistral), tier workhorse

✅ Budget: $2,646.78 of $15,000.00 (18%)

### Ranking

| # | Model | Tier | $/request | $/month | Quality | RAI | Score | Notes |
|---|---|---|---|---|---|---|---|---|
| 1 | `openai/gpt-6-luna@openai` | daily-driver | 0.000319 | 387.90 | 0.84 (measured) | 0.88 | 0.908 | 1.1x regional |
| 2 | `mistral/mistral-small-2603@mistral` | daily-driver | 0.000421 | 511.63 | 0.79 (measured) | 0.58 | 0.825 | 1.1x regional; below quality floor |
| 3 | `mistral/ministral-8b-2512@mistral` | daily-driver | 0.000247 | 300.96 | 0.60 (prior) | 0.58 | 0.797 | 1.1x regional; below quality floor |
| 4 | `mistral/mistral-large-2512@mistral` | workhorse | 0.001210 | 1,471.36 | 0.88 (measured) | 0.58 | 0.721 | 1.1x regional |
| 5 | `openai/gpt-6.1-sol@openai` | workhorse | 0.006215 | 7,557.44 | 0.91 (measured) | 0.88 | 0.658 | 1.1x regional |
| 6 | `mistral/mistral-medium-3-5@mistral` | workhorse | 0.004785 | 5,818.56 | 0.90 (measured) | 0.58 | 0.629 | 1.1x regional |
| 7 | `openai/gpt-6-astra@openai` | specialist-reasoning | 0.031900 | 38,790.40 | 0.95 (measured) | 0.88 | 0.554 | 1.1x regional |

<details><summary>Excluded model/platform combinations</summary>

- `openai/gpt-6-astra@azure-foundry`: zero data retention not documented
- `openai/gpt-6.1-sol@azure-foundry`: zero data retention not documented
- `openai/gpt-6-luna@azure-foundry`: zero data retention not documented
- `anthropic/claude-fable-5-1@anthropic`: cannot process in ['eu'] via anthropic; no vendor moderation API (bring your own guardrail)
- `anthropic/claude-fable-5-1@aws-bedrock`: zero data retention not documented
- `anthropic/claude-fable-5-1@gcp-vertex`: zero data retention not documented
- `anthropic/claude-fable-5-1@azure-foundry`: cannot process in ['eu'] via azure-foundry; zero data retention not documented
- `anthropic/claude-opus-5-5@anthropic`: cannot process in ['eu'] via anthropic; no vendor moderation API (bring your own guardrail)
- `anthropic/claude-opus-5-5@aws-bedrock`: zero data retention not documented
- `anthropic/claude-opus-5-5@gcp-vertex`: zero data retention not documented
- `anthropic/claude-opus-5-5@azure-foundry`: cannot process in ['eu'] via azure-foundry; zero data retention not documented
- `anthropic/claude-sonnet-5-5@anthropic`: cannot process in ['eu'] via anthropic; no vendor moderation API (bring your own guardrail)
- `anthropic/claude-sonnet-5-5@aws-bedrock`: zero data retention not documented
- `anthropic/claude-sonnet-5-5@gcp-vertex`: zero data retention not documented
- `anthropic/claude-sonnet-5-5@azure-foundry`: cannot process in ['eu'] via azure-foundry; zero data retention not documented
- `anthropic/claude-haiku-5-5@anthropic`: cannot process in ['eu'] via anthropic; no vendor moderation API (bring your own guardrail)
- `anthropic/claude-haiku-5-5@aws-bedrock`: zero data retention not documented
- `anthropic/claude-haiku-5-5@gcp-vertex`: zero data retention not documented
- `anthropic/claude-haiku-5-5@azure-foundry`: cannot process in ['eu'] via azure-foundry; zero data retention not documented
- `google/gemini-3.1-pro-preview@gcp-vertex`: preview model (allow_preview=false); cannot process in ['eu'] via gcp-vertex; zero data retention not documented; missing attestation '27001'
- `google/gemini-3.1-pro-preview@gemini-api`: preview model (allow_preview=false); cannot process in ['eu'] via gemini-api; zero data retention not documented; missing attestation '27001'
- `google/gemini-3.8-flash@gcp-vertex`: zero data retention not documented; missing attestation '27001'
- `google/gemini-3.8-flash@gemini-api`: zero data retention not documented; missing attestation '27001'
- `google/gemini-3.5-flash-lite@gcp-vertex`: zero data retention not documented; missing attestation '27001'
- `google/gemini-3.5-flash-lite@gemini-api`: zero data retention not documented; missing attestation '27001'
- `mistral/mistral-large-4@mistral`: preview model (allow_preview=false)
- `mistral/codestral-2508@mistral`: code-specialised model; task is not code
- `mistral/mistral-moderation-2603@mistral`: safety classifier, not a generation model; no text input; no tool calling; no structured output
- `amazon/nova-2-lite@aws-bedrock`: no structured output; zero data retention not documented; missing attestation '27001'
- `amazon/nova-pro@aws-bedrock`: no structured output; zero data retention not documented; missing attestation '27001'
- `amazon/nova-lite@aws-bedrock`: no structured output; zero data retention not documented; missing attestation '27001'
- `amazon/nova-micro@aws-bedrock`: no tool calling; no structured output; zero data retention not documented; missing attestation '27001'
- `amazon/nova-premier@aws-bedrock`: no structured output; cannot process in ['eu'] via aws-bedrock; zero data retention not documented; missing attestation '27001'
- `meta/llama4-maverick-17b@aws-bedrock`: no structured output; legacy model (allow_legacy=false); cannot process in ['eu'] via aws-bedrock; zero data retention not documented; missing attestation '27001'
- `meta/llama4-scout-17b@aws-bedrock`: no tool calling; no structured output; legacy model (allow_legacy=false); cannot process in ['eu'] via aws-bedrock; zero data retention not documented; missing attestation '27001'
- `deepseek/deepseek-flash@deepseek`: cannot process in ['eu'] via deepseek; zero data retention not documented; missing attestation '27001'; no vendor moderation API (bring your own guardrail)
- `deepseek/deepseek-v4-pro@deepseek`: cannot process in ['eu'] via deepseek; zero data retention not documented; missing attestation '27001'; no vendor moderation API (bring your own guardrail)

</details>
