# FinOps model catalogue — verified vendor facts

Collected 2026-10-13 from first-party vendor pages only. All prices USD per 1M tokens unless stated. "primary" = number read on the vendor page/feed cited on that row; "unverified" = could not fetch, figure left blank. Numbers are copied as printed (no rounding, no conversion), except Bedrock where the vendor page prints per-1K rates multiplied by 1,000 (see note).

Current line-ups differ from the model names in the brief. Where the vendor's current generation is newer than the brief's naming, the current line-up is recorded and the change is noted.

---

## OpenAI (note: the brief asked for GPT-5 flagship/mini/nano + o-series; OpenAI's pricing page now lists the GPT-6 line as "Flagship models". No GPT-5 base/mini/nano or o-series rows remain on the current pricing page; GPT-5.x appears only as deprecated or specialized variants.)

Source pages: https://developers.openai.com/api/docs/pricing (platform.openai.com/docs/pricing redirects here), https://developers.openai.com/api/docs/models, https://developers.openai.com/api/docs/models/gpt-6-astra, …/gpt-6.1-sol, …/gpt-6-luna

| Model (vendor name) | API model id | Input | Cached input | Cache write | Output | Batch / Flex (50%) | Fast (2x) | Ultrafast (6x) | Context window | Max output | Capabilities (as printed) | Knowledge cutoff | Regions / data residency | Verification |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| GPT-6 Astra (flagship) | `gpt-6-astra` | $10.00 short / $20.00 long | $1.00 / $2.00 | $12.50 / $25.00 | $50.00 / $75.00 | Batch: $5.00/$25.00 (short), $10.00/$37.50 (long); Flex identical to Batch | $20.00/$100.00 (short), $40.00/$150.00 (long) | $60.00/$300.00 (short), $120.00/$450.00 (long) | 1,050,000 | 128,000 | Reasoning (effort low/medium/high/xhigh/max); text+image in, text out; function calling: Supported; structured outputs: Supported; audio: Not supported; video: Not supported; fine-tuning: Not supported; tools: web search, file search, image generation, code interpreter, hosted shell, apply patch, skills, computer use, MCP, tool search | Apr 30, 2026 | Regional processing adds 10% premium; Fast mode not available with EU data residency; Ultrafast supports US residency + global only | primary |
| GPT-6.1 Sol | `gpt-6.1-sol` | $2.00 / $4.00 | $0.10 / $0.20 | $2.50 / $5.00 | $10.00 / $15.00 | Batch: $1.00/$5.00 (short), $2.00/$7.50 (long); Flex identical | $4.00/$20.00, $8.00/$30.00 | $12.00/$60.00, $24.00/$90.00 | 1,050,000 | 128,000 | Reasoning (low/medium default/high/xhigh/max; none and minimal not supported); text+image in; function calling Supported (Responses API for tool calling; Chat Completions without tool calling); structured outputs Supported; audio/video Not supported; same tool list as Astra | Apr 30, 2026 | "supports US and EU data residency, including with Fast and Ultrafast modes" | primary |
| GPT-6 Luna (efficient) | `gpt-6-luna` | $0.10 / $0.20 | $0.01 / $0.02 | $0.125 / $0.25 | $0.50 / $0.75 | Batch: $0.05/$0.25 (short), $0.10/$0.375 (long); Flex identical | $0.20/$1.00, $0.40/$1.50 | not listed | 1,050,000 | 128,000 | Reasoning (none/low/medium default/high/xhigh/max); text+image in; function calling Supported (Chat Completions only with reasoning_effort none); structured outputs Supported; audio/video Not supported | May 18, 2026 | "EU data residency is available with Standard, Fast, Flex, and Batch processing" | primary |
| GPT-5.6 Sol (cyber/"Daybreak" line, promotional pricing through Nov 21, 2026) | `gpt-5.6-sol` | $4.00 / $8.00 | $0.40 / $0.80 | $5.00 / $10.00 | $20.00 / $30.00 | — | — | — | not on pricing page | not on pricing page | — | — | — | primary (price only) |
| GPT-5.6 Cyber | `gpt-5.6-cyber` | $12.50 (short only) | $1.25 | $15.625 | $75.00 | — | — | — | — | — | — | — | — | primary (price only) |
| Codex specialized | `gpt-5.3-codex` | $1.75 (Fast: $3.50) | $0.175 (Fast $0.35) | — | $14.00 (Fast $28.00) | — | — | — | — | — | — | — | — | primary; **deprecated, shutdown Apr 1, 2027 → gpt-6-sol** |
| ChatGPT alias | `chat-latest` | $5.00 | $0.50 | — | $30.00 | — | — | — | — | — | — | — | — | primary |
| o-series | — | — | — | — | — | — | — | — | — | — | — | — | — | Not listed on current pricing page except fine-tuned `o4-mini-2025-04-16` ($4.00 in / $1.00 cached / $16.00 out; fine-tuning platform "winding down"). No separately priced reasoning line. |

Rules printed on the model pages: "Prompts with more than 272K input tokens are priced at 2x input and cache rates and 1.5x output for the full request." "Cache writes are billed at 1.25x the uncached input token rate." "Batch and Flex are priced at 50% of Standard rates. Fast mode is priced at 2x the applicable rates." (Sol page: "Ultrafast mode prices are 6x Standard.") "Priority processing was renamed Fast mode on July 30, 2026." "Regional processing (data residency) endpoints are charged a 10% uplift for models released on or after March 5, 2026. FedRAMP endpoints are also charged a 10% uplift."

Data residency regions (https://developers.openai.com/api/docs/guides/your-data): us.api.openai.com (storage + processing), eu.api.openai.com (storage + processing; requires MAM or ZDR), au / ca / jp / in / sg / kr / gb / ae .api.openai.com (storage yes, processing no; require MAM or ZDR; UAE needs additional approval).

Rate-limit tiers (https://developers.openai.com/api/docs/guides/rate-limits): Free ($100/month), Build ($5 credit purchases; $500/month), Launch ($100; $5,000/month), Grow ($500; $200,000/month). Example Standard limits: Astra/Sol — Build 5,000 RPM / 1,000,000 TPM; Launch 10,000 / 4,000,000; Grow 15,000 / 40,000,000. Luna — Build 5,000 / 2,000,000; Launch 10,000 / 10,000,000; Grow 30,000 / 180,000,000.

---

## Anthropic (brief: Opus / Sonnet / Haiku; current line-up on the models overview is Fable 5.1, Opus 5.5, Sonnet 5.5, Haiku 5.5 — Fable is a new top tier above Opus)

Source pages: https://platform.claude.com/docs/en/about-claude/pricing, https://platform.claude.com/docs/en/about-claude/models/overview, https://platform.claude.com/docs/en/models/{fable-5-1,opus-5-5,sonnet-5-5,haiku-5-5}/overview

| Model | API model id (Claude API / Bedrock / Google Cloud / Foundry) | Input | 5m cache write | 1h cache write | Cache read | Output | Batch (50%) | Context window | Max output | Capabilities | Knowledge cutoff (reliable / training) | Regions / residency | Verification |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Claude Fable 5.1 | `claude-fable-5-1` / `anthropic.claude-fable-5-1` / `claude-fable-5-1` / `claude-fable-5-1` | $10 | $12.50 | $20 | $0.25 | $50 | $5 in / $25 out | 1M | 128K | Text+images → text; vision; tool use; adaptive thinking (always on, default effort high); web search + code execution server tools | Jun 2026 / Jun 2026 | inference_geo global or us (us = 1.1x); platforms: Claude API, Amazon Bedrock, Google Cloud, Microsoft Foundry, Claude Platform on AWS | primary |
| Claude Opus 5.5 | `claude-opus-5-5` / `anthropic.claude-opus-5-5` / `claude-opus-5-5` / `claude-opus-5-5` | $4 | $5 | $8 | $0.20 | $20 | $2 / $10 | 1M | 128K (300K on Batch API with `output-300k-2026-03-24` beta) | Text+images → text; tool use; adaptive thinking always on (default effort medium); Fast mode $8 in / $40 out (Claude API only) | Jun 2026 / Jun 2026 | as above | primary |
| Claude Sonnet 5.5 | `claude-sonnet-5-5` / `anthropic.claude-sonnet-5-5` / … | $2 | $2.50 | $4 | $0.10 | $10 | $1 / $5 | 1M | 128K (300K batch beta) | Text+images → text; tool use; adaptive thinking (default effort high) | Jun 2026 / Jun 2026 | as above | primary |
| Claude Haiku 5.5 (prompts ≤100K tokens) | `claude-haiku-5-5` / `anthropic.claude-haiku-5-5` / … | $0.10 | $0.125 | $0.20 | $0.01 | $0.50 | $0.05 / $0.25 | 1M | 128K (300K batch beta) | Text+images → text; tool use; adaptive thinking (default effort medium); newer tokenizer (~30% more tokens than Haiku 4.5) | Jun 2026 / Jun 2026 | as above | primary |
| Claude Haiku 5.5 (prompts >100K tokens) | same | $0.50 | $0.625 | $1 | $0.05 | $2.50 | $0.25 / $1.25 | — | — | — | — | — | primary |

Other rows on the pricing page (still Active): Opus 5 / 4.8 / 4.7 / 4.6 / 4.5 $5 / $25 (cache read $0.50); Sonnet 5 $2 / $10 (read $0.20); Sonnet 4.6 $3 / $15; Haiku 4.5 $1 / $5; Mythos 5.1 same as Fable 5.1 (gated).

Long context: "Claude 4.6 and later models (except Haiku 5.5) … include the full 1M-token context window at standard pricing." Haiku 5.5 is the only model with a price step (100,000 tokens).

Data residency (https://platform.claude.com/docs/en/build-with-claude/data-residency): `inference_geo` = "global" (default) or "us"; US-only inference priced at 1.1x across all token categories on Claude 4.6+; Workspace geo currently "us" only; on Microsoft Foundry the same 1.1x applies to the US Data Zone Standard deployment type.

Rate-limit tiers (https://platform.claude.com/docs/en/api/rate-limits): Evaluation (starting), Start ($500/month cap), Build ($1,000), Scale ($200,000), Custom (no cap).

---

## Google Gemini (brief: Pro / Flash / Flash-Lite; current page lists Gemini 3.8 Flash, Gemini 3.5 Flash-Lite and Gemini 3.1 Pro Preview — no newer stable Pro is listed; Gemini 2.5 models are restricted to prior users)

Source pages: https://ai.google.dev/gemini-api/docs/pricing, https://ai.google.dev/gemini-api/docs/models, https://ai.google.dev/gemini-api/docs/models/{gemini-3.8-flash,gemini-3.5-flash-lite,gemini-3.1-pro-preview}, https://cloud.google.com/vertex-ai/generative-ai/pricing

| Model | API model code | Input (paid tier) | Output (incl. thinking) | Context caching (read) + storage | Batch (50%) | Flex | Priority | Input token limit | Output token limit | Capabilities (model page) | Knowledge cutoff | Vertex AI prices (Global / Non-global) | Verification |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Gemini 3.8 Flash | `gemini-3.8-flash` | $0.75 through Dec 31, 2026; $1.50 from Jan 1, 2027 | $3.75 through Dec 31, 2026; $7.50 from Jan 1, 2027 | $0.075 (→ $0.15 in 2027); storage $0.50 / 1M tokens per hour (→ $1.00 in 2027) | $0.375 in / $1.875 out (→ $0.75 / $3.75); caching $0.0375 | same as Batch | $1.35 in / $6.75 out (→ $2.70 / $13.50); caching $0.135 | 1,048,576 | 65,536 | Inputs: text, image, video, audio, PDF; output text; function calling Supported; structured outputs Supported; thinking Supported (low, medium, high; minimal returns error); caching Supported; code execution Supported; search grounding Supported; computer use Supported (Preview); audio generation Not supported; Batch/Flex/Priority Supported | Not published (page shows "Latest update: September 2026") | Input $0.75 / $0.825; output $3.75 / $4.125; cached $0.075 / $0.0825 (through Dec 31, 2026; $1.50/$7.50 standard from Jan 1, 2027) | primary |
| Gemini 3.5 Flash-Lite | `gemini-3.5-flash-lite` | $0.30 (text / image / video / audio) | $2.50 | $0.03; storage $1.00 / 1M tokens per hour | $0.15 / $1.25; caching $0.02 | — (not listed) | — (not listed) | 1,048,576 | 65,536 | Inputs text, image, video, audio, PDF; function calling, structured outputs, thinking, caching, code execution, search grounding, file search Supported; computer use Supported (Preview); audio generation Not supported | Not published ("Latest update: July 2026") | $0.30 / $0.33 in; $2.50 / $2.75 out; cached $0.03 / $0.033; Priority $0.54 / $4.50 (Global); Flex/Batch $0.15 / $1.25 | primary |
| Gemini 3.1 Pro Preview | `gemini-3.1-pro-preview` (also `gemini-3.1-pro-preview-customtools`) | $2.00 prompts ≤200k tokens; $4.00 prompts >200k | $12.00 ≤200k; $18.00 >200k | $0.20 ≤200k / $0.40 >200k; storage $4.50 / 1M tokens per hour | $1.00 / $2.00 in; $6.00 / $9.00 out; caching same as Standard | same as Batch | $3.60 / $7.20 in; $21.60 / $32.40 out; caching $0.36 / $0.72, storage $8.10 | 1,048,576 | 65,536 | Inputs text, image, video, audio, PDF; function calling, structured outputs, thinking, caching, code execution, search grounding Supported; file search Supported (AI Studio only); audio generation Not supported; Live API Not supported | Not published ("Latest update: February 2026") | Global only: $2.00 / $4.00 in; $12.00 / $18.00 out; cached $0.20 / $0.40 | primary |

Free tier: Gemini 3.8 Flash and 3.5 Flash-Lite "Free of charge" (content used to improve products); 3.1 Pro Preview "Not available" on free tier. Grounding with Google Search: 5,000 free requests/month shared across Gemini 3+ models, then $14 per 1,000 requests.

Vertex note: "For non-global endpoints, pricing will go into effect for the Generally available Gemini 3 and later families … starting on July 1, 2026." Non-global = 1.1x Global as printed. "Gemini models are available in batch mode at 50% discount."

Regions: Gemini API available regions page https://ai.google.dev/gemini-api/docs/available-regions (not fetched); Vertex locations https://cloud.google.com/vertex-ai/generative-ai/docs/learn/locations (global endpoint plus regional endpoints; fetched, list not transcribed).

Rate-limit tiers (https://ai.google.dev/gemini-api/docs/rate-limits): Free; Tier 1 (linked billing; cap $250); Tier 2 (paid $100 + 3 days; cap $2,000); Tier 3 (paid $1,000 + 30 days; cap $20,000 – $100,000+).

---

## Mistral (brief: Large/Medium, Small, Codestral, Ministral, mistral-moderation; current docs list Mistral Large 4 (Public Preview), Mistral Large 3 (GA), Mistral Medium 3.5, Mistral Small 4, Ministral 3 3B/8B/14B, Codestral 25.08, Mistral Moderation 2)

Source pages: https://docs.mistral.ai/inference/pricing (mistral.ai/pricing now shows only consumer/Vibe plans plus an FAQ), model pages under https://docs.mistral.ai/models/…

| Model | API model id (+ alias) | Input | Cached input | Output | Context | Max output | Capabilities (model page "Features") | Licence / stage | Knowledge cutoff | Verification |
|---|---|---|---|---|---|---|---|---|---|---|
| Mistral Large 4 | `mistral-large-4` (page: "mistral-large-4 +1" alias) | Original $1.36 / Sale $0.68 | Original $0.14 / Sale $0.07 | Original $4.18 / Sale $2.09 | 1M | not published | Structured Outputs, Function Calling, Document QnA, Prefix, Chat Completions; multimodal (1.6B vision encoder) | Open weights; Public Preview, Oct 6, 2026, v26.10 | not published | primary |
| Mistral Large 3 | `mistral-large-2512` (+1 alias) | $0.5 | $0.05 | $1.5 | 256k | not published | Structured Outputs, Function Calling, Document QnA, Prefix, Chat Completions, Batching, Agents & Conversations, Built-In Tools; multimodal | Apache 2.0; GA Dec 2, 2025 | not published | primary |
| Mistral Medium 3.5 | `mistral-medium-3-5` (+2 aliases: `mistral-medium-latest`, `mistral-medium-3`) | $1.5 | $0.15 | $7.5 | 256k | not published | Structured Outputs, Function Calling, Predicted Outputs, Document QnA, Prefix, Batching, Agents, Chat Completions, Built-In Tools; multimodal | Modified MIT; GA Apr 28, 2026 | not published | primary |
| Mistral Small 4 | `mistral-small-2603` (+ `mistral-small-latest`) | $0.15 | $0.015 | $0.6 | 256k | not published | Structured Outputs, Function Calling, Document QnA, Prefix, Chat Completions, Batching; "hybrid model unifying instruct, reasoning, and coding" | Apache 2.0; GA Mar 16, 2026 | not published | primary |
| Codestral | `codestral-2508` (+ `codestral-latest`) | $0.3 | $0.03 | $0.9 | 128k | not published | Structured Outputs, Function Calling, Predicted Outputs, Document QnA, Prefix, Batching; FIM | Premier; GA Jul 30, 2025 | not published | primary |
| Ministral 3 14B | `ministral-14b-2512` (+1) | $0.2 | $0.02 | $0.2 | 256k | not published | Structured Outputs, Function Calling, Document QnA, Prefix, Chat Completions, Batching; text + vision | Apache 2.0; GA Dec 2, 2025 | not published | primary |
| Ministral 3 8B | `ministral-8b-2512` (+ `ministral-8b-latest`) | $0.15 | $0.015 | $0.15 | 256k | not published | same as above | Apache 2.0; GA | not published | primary |
| Ministral 3 3B | `ministral-3b-2512` (+1) | $0.1 | $0.01 | $0.1 | 256k | not published | same as above | Apache 2.0; GA | not published | primary |
| Mistral Moderation 2 | `mistral-moderation-2603` | Free | Free | Free | 128k | — | Moderations (/v1/moderations), Batching; jailbreak detection | Premier; GA Mar 1, 2026 | — | primary |

Regional inference (https://docs.mistral.ai/inference/regional-inference): endpoints api.mistral.ai (Global, no upcharge), api.eu.mistral.ai (EU + EFTA), api.us.mistral.ai (US); "billed at 1.1× standard list pricing (a 10% upcharge) for input tokens, output tokens, cached reads, and cache writes"; Batch, Agents and Files API not available on regional endpoints; only function calling tool supported regionally.

Rate-limit tiers: none named; limits are per model (tokens per minute, requests per second) in Admin Panel › API › Limits (https://docs.mistral.ai/admin/billing-usage/usage-limits). Plans: Free, Pro, Education, Team, Enterprise.

---

## Amazon Bedrock — Amazon Nova and Meta Llama (on-demand)

Source: https://aws.amazon.com/bedrock/pricing/ . Note on method: the page renders prices client-side from AWS's own pricing feed (https://b0.p.awsstatic.com/pricing/2.0/meteredUnitMaps/bedrock/USD/current/bedrock.json, referenced in the page as `data-pricing-endpoint`); the HTML prints `{priceOf … !*!1000}` placeholders (per-1K rate × 1,000 = per 1M). Values below were resolved from that feed for **US East (N. Virginia)** and are labelled primary (vendor feed). Model specs come from the Bedrock model cards (docs.aws.amazon.com/bedrock/latest/userguide/model-card-*.md).

| Model | Bedrock model id (+ inference profiles) | Table | Input | Output | Batch input | Batch output | Cache read | Context | Max output | Capabilities (model card) | Knowledge cutoff | Lifecycle (model card) | Verification |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Amazon Nova 2 Lite | `amazon.nova-2-lite-v1:0`; geo `us.`/`eu.`/`jp.amazon.nova-2-lite-v1:0`; global `global.amazon.nova-2-lite-v1:0` | Global cross-region, Standard tier | $0.30 | $2.50 | $0.15 (Batch tier) | $1.25 | "Cache read input tokens will be 75% less than on-demand input token price" | 1M tokens | 64K | Text, image, video in; text out; client-side tool calling Supported; structured outputs listed Not Supported; explicit prompt caching Yes (min 1K tokens/checkpoint, 4 checkpoints, TTL 5 min, max 20K cacheable); extended thinking ("Nova 2 Lite supports extended thinking", Nova 2 guide); batch Yes; service tiers Standard/Priority/Flex/Reserved | Oct 2025 | Launch Dec 02, 2025; EOL no sooner than Dec 02, 2026; Legacy period ≥6 months; Active | primary (feed) |
| Amazon Nova 2 Lite | same | Geo cross-region / in-region, Standard | $0.33 | $2.75 | $0.165 | $1.375 | as above | | | Priority (global) $0.525 / $4.375; Flex (global) $0.15 / $1.25 | | | primary (feed) |
| Amazon Nova 2 Pro (Preview) | not on model-cards index yet | Global cross-region, Standard | $1.25 (text/image/video/audio input) | $10 (text) | $0.625 | $5 | as above | — | — | — | — | Preview | primary (feed), specs unverified |
| Amazon Nova 2 Omni (Preview) | — | Global cross-region, Standard | $0.30 text/image/video; $1 audio | $2.50 text; $40 image | $0.20 / $1.30 | — | — | — | — | — | — | Preview | primary (feed), specs unverified |
| Amazon Nova Premier | `amazon.nova-premier-v1:0` | Geo/in-region, Standard | $2.50 | $12.50 | $1.25 | $6.25 | as above | 1M | 10K | Text, image, video in | — (card not fetched) | — | primary (feed) |
| Amazon Nova Pro | `amazon.nova-pro-v1:0`; `us.`/`eu.`/`apac.amazon.nova-pro-v1:0` | Geo/in-region, Standard | $0.80 (latency-optimized $1) | $3.20 (latency-opt $4) | $0.40 | $1.60 | $0.20 (custom-model on-demand table, "Price per 1M input tokens (cache read)") | 300K | 10K | Text, image, video in; implicit + explicit prompt caching; structured outputs Not Supported | Oct 2024 | Launch Dec 05, 2024; EOL no sooner than Dec 05, 2025; Active | primary (feed) |
| Amazon Nova Lite | `amazon.nova-lite-v1:0`; `us.`/`ca.`/`eu.`/`apac.` profiles | Geo/in-region, Standard | $0.06 | $0.24 | $0.03 | $0.12 | $0.015 | 300K | 10K | Text, image, video in | Oct 2024 | as Nova Pro | primary (feed) |
| Amazon Nova Micro | `amazon.nova-micro-v1:0`; `us.`/`eu.` | Geo/in-region, Standard | $0.035 | $0.14 | $0.0175 | $0.07 | $0.00875 | 128K | 10K | Text only | Oct 2024 | as Nova Pro | primary (feed) |
| Meta Llama 4 Maverick 17B Instruct | `meta.llama4-maverick-17b-instruct-v1:0`; geo `us.meta.llama4-maverick-17b-instruct-v1:0`; global Not supported | On-Demand and Batch | $0.24 | $0.97 | $0.12 | $0.485 | not listed | 1M tokens | 8K | Text + image in; client-side tool calling Supported; structured outputs Not Supported | Aug 2024 | Launch Apr 05, 2025; **Legacy**; EOL March 30, 2027 | primary (feed) |
| Meta Llama 4 Scout 17B Instruct | `meta.llama4-scout-17b-instruct-v1:0`; `us.meta.llama4-scout-17b-instruct-v1:0` | On-Demand and Batch | $0.17 | $0.66 | $0.085 | $0.33 | not listed | 10M tokens | 8K | Text + image in | Aug 2024 | Legacy; EOL March 30, 2027 | primary (feed) |
| Meta Llama 3.3 70B Instruct | `meta.llama3-3-70b-instruct-v1:0`; `us.meta.llama3-3-70b-instruct-v1:0` | On-Demand and Batch | $0.72 | $0.72 | $0.36 | $0.36 | not listed | 128K | 4K | Text; tool calling not in supported list; structured outputs Not Supported | Dec 2023 | Legacy; EOL March 30, 2027 | primary (feed) |

Bedrock service tiers as printed on the pricing page: "Amazon Bedrock supports a variety of tiers including Standard, Flex, Priority, and Reserved tiers." "* Priority tier pricing is at 75% premium to Standard tier pricing." "* Flex tier and Batch pricing are at 50% discount to Standard tier pricing." Three inference options on model cards: In-Region, Geo Cross-Region (US, EU, APAC geos), Global.

---

## Azure OpenAI / Microsoft Foundry

Source pages: https://azure.microsoft.com/en-us/pricing/details/cognitive-services/openai-service/ (page text; GPT-6 price cells render client-side as "$-" and the page carries the notice "GPT-6 Sol and Luna prices are currently in processing for publishing on this page"), Azure Retail Prices API (first-party) https://prices.azure.com/api/retail/prices?$filter=serviceName eq 'Foundry Models' and productName eq 'Azure OpenAI GPT6' (meters, eastus2, USD), https://learn.microsoft.com/en-us/azure/ai-foundry/openai/concepts/models, https://learn.microsoft.com/en-us/azure/ai-foundry/foundry-models/concepts/deployment-types

Deployment types printed on the pricing page: "Global Deployment – Global SKU"; "Data Zone Deployment – Geographic based (EU or US)"; "Regional Deployment – Local Region (up to 27 regions)". Batch: "available in the Batch API for global deployments and three regions, that returns completions within 24 hours for a 50% discount on Global Standard Pricing."

Meter prices from the Retail Prices API (per 1M tokens; Gl = Global Standard, DZ = Data Zone Standard, Flex Gl = Flex, PP = priority processing):

| Model (meter) | Context | Global input / cached / cache write / output | Data Zone input / cached / cache write / output | Flex (Global) | Priority processing (PP) Global / DZ | Regional meters | Matches OpenAI first-party? | Verification |
|---|---|---|---|---|---|---|---|---|
| gpt-6-astra | Short | $10.0 / $1.0 / $12.5 / $50.0 | $11.0 / $1.1 / $13.75 / $55.0 | $5.0 / $0.5 / $6.25 / $25.0 | none in feed | none in feed | Global Standard = OpenAI Standard exactly; Data Zone = 1.10x; Flex = 50% | primary (API) |
| gpt-6-astra | Long | $20.0 / $2.0 / $25.0 / $75.0 | $22.0 / $2.2 / $27.5 / $82.5 | $10.0 / $1.0 / $12.5 / $37.5 | none | none | yes / 1.10x / 50% | primary (API) |
| gpt-6.1-sol | Short | $2.0 / $0.1 / $2.5 / $10.0 | $2.2 / $0.11 / $2.75 / $11.0 | $1.0 / $0.05 / $1.25 / $5.0 | none | none | yes / 1.10x / 50% | primary (API) |
| gpt-6.1-sol | Long | $4.0 / $0.2 / $5.0 / $15.0 | $4.4 / $0.22 / $5.5 / $16.5 | $2.0 / $0.1 / $2.5 / $7.5 | none | none | yes | primary (API) |
| gpt-6-sol (not on OpenAI's current pricing page) | Short | $2.0 / $0.2 / $2.5 / $10.0 | $2.2 / $0.22 / $2.75 / $11.0 | $1.0 / $0.1 / $1.25 / $5.0 | $4.0 / $0.4 / $5.0 / $20.0 (Gl); $4.4 / $0.44 / $5.5 / $22.0 (DZ) | none | n/a (no OpenAI row to compare) | primary (API) |
| gpt-6-sol | Long | $4.0 / $0.4 / $5.0 / $15.0 | $4.4 / $0.44 / $5.5 / $16.5 | $2.0 / $0.2 / $2.5 / $7.5 | $8.0 / $0.8 / $10.0 / $30.0 (Gl); $8.8 / $0.88 / $11.0 / $33.0 (DZ) | none | n/a | primary (API) |
| gpt-6-luna | Short | $0.1 / $0.01 / $0.125 / $0.5 | $0.11 / $0.011 / $0.1375 / $0.55 | $0.05 / $0.005 / $0.0625 / $0.25 | none | none | yes / 1.10x / 50% | primary (API) |
| gpt-6-luna | Long | $0.2 / $0.02 / $0.25 / $0.75 | $0.22 / $0.022 / $0.275 / $0.825 | $0.1 / $0.01 / $0.125 / $0.375 | none | none | yes | primary (API) |

Azure model specs (models page): gpt-6-astra (2026-09-03), gpt-6-luna (2026-09-22), gpt-6-sol (2026-09-22), gpt-6.1-sol (2026-09-29): context 1,050,000 (Input: 922,000; Output: 128,000); max output 128,000; training data up to April 2026 (May 2026 for Luna); capabilities: reasoning, Responses API, Chat Completions, streaming, structured outputs, text+image input, functions/tools/parallel tool calling, computer use. "Standard pay-as-you-go deployments of GPT-6 models use separate pricing categories for short-context and long-context requests." "Some quota tiers require quota requests for the GPT-6 family … Tier 5 and Tier 6 subscriptions have quota by default."

Data residency (deployment-types page): "Global types: May be processed in any Azure region"; Data Zone = within EU or US geography; Standard and Regional Provisioned = within customer-specified Azure geography.

Quota tiers (https://learn.microsoft.com/en-us/azure/ai-foundry/openai/quotas-limits): "Seven tiers are available: Free Tier and Tiers 1 through 6".

---

## DeepSeek (non-Western-hosted option; hosted by DeepSeek, Inc., api.deepseek.com; no regional/data-residency options published)

Source: https://api-docs.deepseek.com/quick_start/pricing, https://api-docs.deepseek.com/quick_start/rate_limit

| Model | API model id (version) | Input, cache hit (peak / off-peak) | Input, cache miss (peak / off-peak) | Output (peak / off-peak) | Batch | Context | Max output | Capabilities | Concurrency limit | Knowledge cutoff | Verification |
|---|---|---|---|---|---|---|---|---|---|---|---|
| DeepSeek V4.1 Flash | `deepseek-flash` (legacy names `deepseek-v4-flash`, `deepseek-v4-flash-vision-exp` still accepted, served by V4.1 Flash) | $0.006 / $0.003 | $0.3 / $0.15 | $1.2 / $0.6 | not published | 1M | MAXIMUM: 384K | Thinking and non-thinking modes (thinking default); JSON output ✓; tool calls ✓; Responses API ✓; Anthropic-format API ✓; chat prefix completion (beta) ✓; FIM (non-thinking only); Vision ✓ | 2500 | not published | primary |
| DeepSeek V4 Pro | `deepseek-v4-pro` (DeepSeek-V4-Pro-0813) | $0.044 / $0.022 | $1.32 / $0.66 | $3.96 / $1.98 | not published | 1M | MAXIMUM: 384K | same, except Vision: Not supported | 500 | not published | primary |

"Off-peak rates are half of the peak rates. Peak hours are 01:00 - 04:00 and 06:00 - 10:00 UTC, Monday through Friday, excluding Chinese public holidays." Rate limits: concurrency limits only (no named tiers); "capacity expansion request" available at no extra cost.

---

## Caching and batch

| Vendor | Prompt-caching pricing rule (as printed) | Batch API discount | URL |
|---|---|---|---|
| OpenAI | GPT-5.6 and later: cache writes 1.25× uncached input; reads 0.1× on most models, 0.05× on GPT-6.1 Sol; up to four cache writes per request; cached_tokens rounded down to multiple of 128; retention in_memory or 24h (default 24h unless Zero Data Retention) | 50% ("50% lower costs … clear 24-hour turnaround"); Flex also 50% | https://developers.openai.com/api/docs/guides/prompt-caching ; https://developers.openai.com/api/docs/guides/batch |
| Anthropic | 5-minute cache write 1.25× base input; 1-hour write 2×; cache read 0.1× (0.025× on Fable 5.1 / Mythos 5.1; 0.05× on Opus 5.5 / Sonnet 5.5); multipliers stack with Batch and data-residency multipliers | 50% on input and output | https://platform.claude.com/docs/en/about-claude/pricing ; https://platform.claude.com/docs/en/build-with-claude/prompt-caching ; https://platform.claude.com/docs/en/build-with-claude/batch-processing |
| Google Gemini | "Context caching price" per model = 0.1× input as printed (3.8 Flash $0.075 vs $0.75; 3.1 Pro $0.20 vs $2.00; 3.5 Flash-Lite $0.03 vs $0.30) plus storage per 1M tokens per hour ($0.50 3.8 Flash through 2026, $4.50 Pro, $1.00 Flash-Lite); implicit caching on by default for 2.5+ models, minimum 4,096 tokens for 3.x models | "Batch API (50% cost reduction)"; target turnaround 24 hours; Vertex "batch mode at 50% discount" | https://ai.google.dev/gemini-api/docs/pricing ; https://ai.google.dev/gemini-api/docs/caching ; https://ai.google.dev/gemini-api/docs/batch-api |
| Mistral | Cached input = 0.1× input on every row (e.g. Large 3 $0.05 vs $0.5); FAQ: "cached input tokens reduce input cost by up to 90%"; no separate cache-write price printed; regional endpoints 1.1× on cached reads and cache writes | 50% ("Batch processing … reduces the price by 50%"; "large workloads at a 50% discount"); batch not available on regional endpoints | https://docs.mistral.ai/inference/pricing ; https://mistral.ai/pricing (FAQ) ; https://docs.mistral.ai/studio-api/batch-processing |
| Amazon Bedrock | Nova: "Cache read input tokens will be 75% less than on-demand input token price"; cache checkpoints min 512–4,096 tokens by model (Nova 1K, max 20K cacheable, 4 checkpoints, 5-minute TTL); Anthropic rows show separate "Cache write (30 min)" / "Cache read" columns | "batch inference at a 50% lower price compared to on-demand"; Flex tier also 50% | https://aws.amazon.com/bedrock/pricing/ ; https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-caching.html |
| Azure OpenAI | Meters mirror OpenAI: cached input 0.1× (Astra, Luna) / 0.05× (6.1 Sol, 6 Sol); cache write 1.25× input; Data Zone meters 1.1× | "50% discount on Global Standard Pricing", 24-hour return | https://azure.microsoft.com/en-us/pricing/details/cognitive-services/openai-service/ ; https://prices.azure.com/api/retail/prices |
| DeepSeek | Cache-hit input priced separately (Flash $0.006 vs $0.3 miss; Pro $0.044 vs $1.32 at peak) | not published | https://api-docs.deepseek.com/quick_start/pricing |

## Capacity and deprecation

| Vendor | Provisioned / reserved capacity option (name) | Rate-limit tier names | Deprecation / retirement policy (notice as printed) | URL |
|---|---|---|---|---|
| OpenAI | "Scale Tier" (eligible models) and "Reserved Tier" (GPT-5.6 and later) — named on the rate-limits page; openai.com/api-scale-tier/ and openai.com/api-reserved-tier/ returned HTTP 403, contents unverified | Free, Build, Launch, Grow | GA models ≥6 months; specialized variants ≥3 months; preview models may be ~2 weeks | https://developers.openai.com/api/docs/deprecations |
| Anthropic | "Priority Tier" (service_tier auto / standard_only; 99.5% uptime target; 1/3/6/12-month commitments) — "no longer available for purchase"; not supported on Fable 5.1, Opus 5.5, Sonnet 5.5, Haiku 5.5, Opus 5, Sonnet 5, Mythos | Evaluation, Start, Build, Scale, Custom | ≥60 days' notice before retirement; dates apply to Claude API, Claude Platform on AWS, Microsoft Foundry (Bedrock/Google Cloud set their own) | https://platform.claude.com/docs/en/about-claude/model-deprecations ; https://platform.claude.com/docs/en/api/service-tiers |
| Google | "Provisioned Throughput" (Vertex / Gemini Enterprise Agent Platform; "fixed-cost, fixed-term subscription"); Gemini API Enterprise plan lists "Provisioned throughput"; Priority inference tier priced 1.8× Standard | Free, Tier 1, Tier 2, Tier 3 | Gemini API: earliest shutdown dates listed per model, "exact shutdown date … with advance notice"; Vertex: "Models available for at least 12 months after release" (e.g. gemini-3.5-flash-lite retirement July 21, 2027 or later) | https://ai.google.dev/gemini-api/docs/deprecations ; https://cloud.google.com/vertex-ai/generative-ai/docs/learn/model-versions ; https://cloud.google.com/vertex-ai/generative-ai/docs/provisioned-throughput/overview |
| Mistral | "Priority Tier" (priority queueing, custom per-model limits, 99.5% uptime SLA; service_tier auto / standard_only; requires account setup) — queue priority, not reserved units | none named (per-model TPM / RPS limits in Admin Panel) | GA 6 months; Public Preview 1 month; Labs 1 month; third-party models 1 month; deprecation announced when replacement available | https://docs.mistral.ai/inference/model-lifecycle ; https://docs.mistral.ai/inference/priority-tier |
| Amazon Bedrock | "Provisioned Throughput" (Model Units; no commitment / 1 month / 6 months) and "Reserved" service tier (alongside Standard, Flex, Priority) | none named (account quotas) | Legacy period 6 months or 45 days ("Most models have a 6-month Legacy period"); model cards show "EOL no sooner than" date | https://docs.aws.amazon.com/bedrock/latest/userguide/model-lifecycle.html ; https://docs.aws.amazon.com/bedrock/latest/userguide/prov-throughput.html |
| Azure / Microsoft Foundry | "Provisioned Throughput Units (PTUs)" — Global Provisioned, Data Zone Provisioned, Regional Provisioned; hourly or Azure reservations (monthly/annual) | Free Tier, Tier 1 – Tier 6 | Standard 18-month lifecycle (retirement date set at launch; Deprecated at 12 months for new customers); Anthropic, DeepSeek, Fireworks, Mistral AI models 12-month lifecycle; emergency security retirements possible | https://learn.microsoft.com/en-us/azure/ai-foundry/openai/concepts/model-retirements ; https://learn.microsoft.com/en-us/azure/ai-foundry/openai/concepts/provisioned-throughput |
| DeepSeek | none published ("capacity expansion request" for higher concurrency, no extra cost) | none (concurrency limits: Flash 2500, Pro 500) | No policy page; change log gave 3 months' notice when retiring legacy names (`deepseek-chat`, `deepseek-reasoner` discontinued 2026-07-24) | https://api-docs.deepseek.com/updates ; https://api-docs.deepseek.com/quick_start/rate_limit |

## Discrepancies noticed

- OpenAI's pricing page no longer lists `gpt-6-sol`, but Azure (meters and models page) and Bedrock (lifecycle page) still sell it; OpenAI's deprecation page names `gpt-6-sol` as the replacement for gpt-5.3-codex / gpt-5.1.
- OpenAI first-party publishes no Regional-deployment price for GPT-6 (only a 10% regional-processing uplift); Azure's Retail Prices feed likewise contains no Regional (non-DZ) meters for GPT-6, only Global and Data Zone, although the pricing page lists "Regional Deployment – Local Region (up to 27 regions)" as a deployment type.
- Azure pricing page shows "$-" for all GPT-6 price cells and says Sol/Luna prices are still "in processing"; the Retail Prices API already carries them (effective 2026-09-01 / 2026-10-01).
- Anthropic's pricing page lists Haiku 5.5 as the only model with a long-context price step (100K), whereas OpenAI applies a 272K step to all GPT-6 models and Google a 200K step to Pro only.
- Gemini 3.8 Flash has introductory pricing ($0.75 / $3.75) through Dec 31, 2026, then doubles; Mistral Large 4 is shown as a "Sale price" (half of original) with no end date printed.
- Bedrock model cards list Nova 2 Lite "Structured outputs" under Not Supported while the model supports tool calling; Nova Pro lists Structured outputs Not Supported too.
- Bedrock Llama 4 Maverick/Scout and Llama 3.3 70B are already in Legacy state (EOL March 30, 2027).

## Could not verify

- OpenAI Scale Tier and Reserved Tier commercial pages (openai.com/api-scale-tier/, openai.com/api-reserved-tier/): HTTP 403 — names taken from the docs rate-limits page only.
- OpenAI GPT-5.6 Sol / Cyber context window, max output, cutoff: not on fetched pages.
- Anthropic Priority Tier pricing (page states commitments no longer sold; no prices printed).
- Google Gemini knowledge cutoffs: not published on model pages (only "Latest update" month).
- Gemini API available-regions page and Vertex regional list: not transcribed (URLs given above).
- Mistral: max output tokens and knowledge cutoffs for all models; Batch and Priority tab prices on docs.mistral.ai/inference/pricing (rendered client-side; only Standard tab text was retrievable); mistral.ai/pricing no longer carries an API price table (FAQ only).
- Amazon Nova 2 Pro (Preview) and Nova 2 Omni (Preview): model cards not on the model-cards index — context, max output, capabilities blank. Nova Premier card not fetched (context/max output taken from the Nova user guide https://docs.aws.amazon.com/nova/latest/userguide/what-is-nova.html). Nova cache-write price not printed.
- Bedrock Llama cache-read pricing: not listed.
- Azure Regional (non-Data-Zone) Standard prices for GPT-6 and PTU hourly/reservation prices: not in fetched sources.
- DeepSeek batch discount, knowledge cutoff, deprecation policy page: not published.
