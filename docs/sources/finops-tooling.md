# AI FinOps / token-cost-management infrastructure-as-code — verified syntax and facts

Collected 2026-10-13 from first-party documentation only (vendor docs, provider GitHub doc sources, project docs). Each item is labelled **primary** (read on the cited page) or **UNVERIFIED**. Code blocks are verbatim copies from the cited page unless marked otherwise.

Terraform Registry pages are JavaScript-rendered and could not be fetched directly; the same provider docs were read from the providers' own GitHub source (`website/docs/r/*.html.markdown` in `hashicorp/terraform-provider-{azurerm,aws,google}`), which is what the Registry renders. Those are labelled **primary (provider repo)**.

---

## 1. LiteLLM Proxy (docs.litellm.ai)

### 1.1 config.yaml top-level keys — primary
Source: https://docs.litellm.ai/docs/proxy/configs

| Key | Description (verbatim from page) |
|---|---|
| `model_list` | List of supported models on the server, with model-specific configs |
| `router_settings` | litellm Router settings, example routing_strategy="least-busy" |
| `litellm_settings` | litellm Module settings, example litellm.drop_params=True, litellm.set_verbose=True, litellm.api_base, litellm.cache |
| `general_settings` | Server settings, example setting master_key: sk-my_special_key |
| `environment_variables` | Environment Variables example, REDIS_HOST, REDIS_PORT |

Env-ref syntax (primary, same page): any value may be `os.environ/VAR_NAME` — "runs os.getenv("YOUR-ENV-VAR")". "This works for ANY value on the config.yaml".

### 1.2 `model_list` entry fields — primary
Sources: https://docs.litellm.ai/docs/proxy/configs ; https://docs.litellm.ai/docs/proxy/config_settings ; https://docs.litellm.ai/docs/proxy/provider_budget_routing ; https://docs.litellm.ai/docs/proxy/tag_routing

| Field | Where | Verified meaning |
|---|---|---|
| `model_name` | entry | "the name to pass TO litellm from the external client" (user-facing alias / model group) |
| `litellm_params.model` | entry | "the model string passed to the litellm.completion() function" e.g. `azure/gpt-4o-eu`, `bedrock/...`, `openai/...` |
| `litellm_params.api_base` | entry | provider endpoint |
| `litellm_params.api_key` | entry | e.g. `"os.environ/AZURE_API_KEY_EU"` |
| `litellm_params.api_version` | entry | Azure API version string |
| `litellm_params.rpm` | entry | "Rate limit for this deployment: in requests per minute (rpm)"; "When rpm/tpm set - litellm uses weighted pick for load balancing" |
| `litellm_params.tpm` | entry | "tpm = Tokens Per Minute" |
| `litellm_params.weight` | entry | weight-based shuffling (routing page) |
| `litellm_params.max_budget` | entry | "(USD)" — per-deployment model budget (provider_budget_routing page) |
| `litellm_params.budget_duration` | entry | "(Duration. can be 1s, 1m, 1h, 1d, 1mo)" (provider_budget_routing page) |
| `litellm_params.tags` | entry | e.g. `tags: ["free"]` for tag-based routing; requires `router_settings.enable_tag_filtering: True` |
| `litellm_params.input_cost_per_token` / `output_cost_per_token` | entry | custom pricing used by cost-based routing (routing page) |
| `litellm_params.litellm_credential_name` | entry | reference to `credential_list[].credential_name` |
| `model_info.id`, `model_info.mode`, `model_info.input_cost_per_token`, `model_info.output_cost_per_token`, `model_info.max_tokens`, `model_info.base_model` | entry | from config_settings schema block |
| `model_info.supported_environments` | entry | `["development","production","staging"]` |

Verbatim (provider_budget_routing page, "Model Budgets"):
```yaml
model_list:
  - model_name: gpt-5.6-terra
    litellm_params:
      model: openai/gpt-5.6-terra
      api_key: os.environ/OPENAI_API_KEY
      max_budget: 0.000000000001 # (USD)
      budget_duration: 1d # (Duration. can be 1s, 1m, 1h, 1d, 1mo)
  - model_name: gpt-5.6-luna
    litellm_params:
      model: openai/gpt-5.6-luna
      api_key: os.environ/OPENAI_API_KEY
      max_budget: 100 # (USD)
      budget_duration: 30d # (Duration. can be 1s, 1m, 1h, 1d, 1mo)
```

### 1.3 `router_settings` — primary
Source: https://docs.litellm.ai/docs/proxy/config_settings ("router_settings - Reference" table) unless noted.

| Key | Type | Default | Description (verbatim/abridged) |
|---|---|---|---|
| `routing_strategy` | string | `simple-shuffle` | Options: "simple-shuffle", "least-busy", "usage-based-routing", "latency-based-routing". (Reference table.) The routing page (https://docs.litellm.ai/docs/routing) additionally documents `usage-based-routing-v2` ("async implementation of usage-based-routing") and `cost-based-routing` ("Lowest Cost Routing (Async)"); the Session Affinity section lists the full set: "simple-shuffle, least-busy, usage-based-routing-v2, latency-based-routing, cost-based-routing". Proxy YAML example on routing page uses `routing_strategy: usage-based-routing-v2` inside `routing_groups`; `cost-based-routing` is shown only in SDK `Router(routing_strategy="cost-based-routing")` examples. |
| `routing_strategy_args` | dict | `{}` | e.g. `{"ttl": 10}` for latency routing window |
| `redis_host` / `redis_password` / `redis_port` / `redis_db` | string | null | shared tpm/rpm tracking across instances |
| `enable_pre_call_checks` | bool | — | "Before call is made check if a call is within model context window" |
| `fallbacks` | array of objects | `[]` | "Specifies fallback models for all types of errors." e.g. `[{"claude-sonnet-5": ["my-fallback-model"]}]` |
| `context_window_fallbacks` | List[Dict[str, List[str]]] | `[]` | "Fallback models for context window violations." |
| `content_policy_fallbacks` | array of objects | `[]` | "Specifies fallback models for content policy violations." |
| `default_fallbacks` | Optional[List[str]] | null | "Fallbacks to try if no model group-specific fallbacks are defined." |
| `max_fallbacks` | Optional[int] | 5 | max fallbacks to try |
| `allowed_fails` | integer | 3 | "The number of failures allowed before cooling down a model." |
| `allowed_fails_policy` | object | null | per-error-type allowed fails, e.g. `"BadRequestErrorAllowedFails": 1000` |
| `cooldown_time` | integer | 5 (seconds) | "The duration (in seconds) to cooldown a model if it exceeds the allowed failures." |
| `disable_cooldowns` | boolean | false | |
| `num_retries` | int | 2 | "Number of retries for a request." |
| `retry_policy` | Dict[str,int] | — | e.g. `"RateLimitErrorRetries": 3`, `"DefaultRetries": 2` |
| `timeout` | Optional[float] | null (uses litellm_settings.request_timeout) | "The default timeout for a request. Default is 10 minutes." |
| `stream_timeout` | Optional[float] | null (uses timeout) | |
| `model_group_alias` | dict | `{}` | "Model group alias mapping. E.g. {"claude-3-haiku": "claude-3-haiku-20240229"}" ; configs page example: `model_group_alias: {"gpt-5.6": "gpt-5.6-luna"} # all requests with gpt-5.6 will be routed to models with gpt-5.6-luna` |
| `provider_budget_config` | ProviderBudgetConfig | null | "Provider budget configuration. Use this to set llm_provider budget limits. example $100/day to OpenAI, $100/day to Azure" |
| `enable_tag_filtering` | bool | — | "Use tag based routing for requests" |
| `tag_filtering_match_any` | bool | — | ANY vs ALL requested tags |
| `optional_pre_call_checks` | List[str] | null | Supported: `router_budget_limiting`, `prompt_caching`, `responses_api_deployment_check`, `encrypted_content_affinity`, `deployment_affinity`, `session_affinity`, `forward_client_headers_by_model_group` |
| `routing_groups` | List[RoutingGroup] | null | each has `group_name`, `models`, `routing_strategy`, optional `routing_strategy_args` |
| `enable_weighted_failover` | boolean | false | |
| `cache_responses` | boolean | false | |

`provider_budget_config` spec (primary, https://docs.litellm.ai/docs/proxy/provider_budget_routing): key = provider name; value = `{budget_limit: float USD, time_period: "Xs"|"Xm"|"Xh"|"Xd"|"Xmo"}`.
```yaml
router_settings:
  provider_budget_config:
    openai:
      budget_limit: 0.000000000001 # float of $ value budget for time period
      time_period: 1d # can be 1d, 2d, 30d, 1mo, 2mo
    azure:
      budget_limit: 100
      time_period: 1d
    anthropic:
      budget_limit: 100
      time_period: 10d
    vertex_ai:
      budget_limit: 100
      time_period: 12d
    gemini:
      budget_limit: 100
      time_period: 12d
  # OPTIONAL: Set Redis Host, Port, and Password if using multiple instance of LiteLLM
  redis_host: os.environ/REDIS_HOST
  redis_port: os.environ/REDIS_PORT
  redis_password: os.environ/REDIS_PASSWORD
```

Note (primary, reliability page https://docs.litellm.ai/docs/proxy/reliability): `fallbacks`, `context_window_fallbacks`, `allowed_fails`, `cooldown_time`, `num_retries`, `request_timeout` are also shown under `litellm_settings:` in the "Fallbacks + Retries + Timeouts + Cooldowns" example; `content_policy_fallbacks` and `fallbacks` quick-start examples use `router_settings:`. Both placements appear in the docs.

### 1.4 `litellm_settings` — primary
Source: https://docs.litellm.ai/docs/proxy/config_settings ("litellm_settings - Reference") and https://docs.litellm.ai/docs/proxy/users

| Key | Type | Default | Description |
|---|---|---|---|
| `success_callback` | array of strings | `[]` | List of success callbacks e.g. `["langfuse"]` |
| `failure_callback` | array of strings | `[]` | e.g. `["sentry"]` |
| `callbacks` | array of strings | `[]` | "runs on success and failure", e.g. `["otel"]`, `["prometheus"]` |
| `service_callback` | array | — | e.g. `["datadog", "prometheus"]` "logs redis, postgres failures" |
| `max_budget` | float | 0 (no cap) | "Global spend cap in USD across all providers for this instance. 0 disables the cap." |
| `budget_duration` | str | — | "(str) frequency of reset - You can set duration as seconds ("30s"), minutes ("30m"), hours ("30h"), days ("30d")." (users page) |
| `budget_reset_time` | string | null (midnight) | `"HH:MM"` wall-clock reset for day/week/month budgets |
| `request_timeout` | integer | 6000 (seconds) | |
| `default_fallbacks` / `content_policy_fallbacks` / `context_window_fallbacks` | — | `[]` | as above |
| `cache` | boolean | false | "If true, enables caching." |
| `cache_params` | object | `{}` (type defaults to redis) | `type: redis|local|s3|gcs`, `host`, `port`, `password`, `namespace`, `ttl`, `mode: default_off`, `supported_call_types`, `similarity_threshold` (Qdrant semantic), s3/gcs keys |
| `tag_budget_config` | map | — | Enterprise. `{tag: {max_budget: USD, budget_duration: dur}}` |
| `upperbound_key_generate_params` | object | null | hard upper bounds for `/key/generate`: `max_budget`, `budget_duration`, `duration`, `max_parallel_requests`, `tpm_limit`, `rpm_limit` |
| `default_key_generate_params` | object | — | defaults for `/key/generate`: `max_budget`, `models`, `duration`, `metadata`, `team_id` |
| `default_team_params` | object | null | Sub-fields: `max_budget`, `budget_duration` (e.g. "30d"), `tpm_limit`, `rpm_limit`, `team_member_permissions`, `models` |
| `max_internal_user_budget` | float | null | default max budget (USD) for every internal user |
| `cost_discount_config` / `cost_margin_config` | map | — | per-provider discount/margin (e.g. `global: 0.05`, `openai: 0.10`) |
| `prometheus_initialize_budget_metrics` | bool | — | emit budget metrics for all keys/teams every 5 min (prometheus page) |
| `turn_off_message_logging` | boolean | false | |

Global budget verbatim (https://docs.litellm.ai/docs/proxy/users):
```yaml
general_settings:
  master_key: os.environ/LITELLM_MASTER_KEY
litellm_settings:
  # other litellm settings
  max_budget: 0 # (float) sets max budget as $0 USD
  budget_duration: 30d # (str) frequency of reset - You can set duration as seconds ("30s"), minutes ("30m"), hours ("30h"), days ("30d").
```
Page warning (primary): "Every budget on this page is enforced against spend read from the database, so none of them cap anything on a DB-less deployment."

### 1.5 `general_settings` — primary
Source: https://docs.litellm.ai/docs/proxy/config_settings ("general_settings - Reference")

| Key | Type | Default | Description |
|---|---|---|---|
| `master_key` | string | null (falls back to `LITELLM_MASTER_KEY`) | "The proxy will not start when it is not set, is empty, or has a known unsafe value." |
| `database_url` | string | null (falls back to `DATABASE_URL`) | |
| `alerting` | array of strings | null | "List of alerting methods" e.g. `["slack", "email"]` |
| `alerting_threshold` | integer | 600 (seconds) | |
| `alert_types` | List[str] | null (all) | includes `llm_exceptions`, `llm_too_slow`, `llm_requests_hanging`, `budget_alerts`, `spend_reports`, `db_exceptions`, `daily_reports`, `cooldown_deployment`, `new_model_added`, `region_outage_alerts` (alerting page https://docs.litellm.ai/docs/proxy/alerting) |
| `alerting_args` | dict | null | |
| `disable_reset_budget` | boolean | false | "turns off reset budget scheduled task" |
| `disable_spend_logs` | boolean | — | "turn off writing each transaction to the db" |
| `disable_budget_reservation` | boolean | false | disables pre-request cost reservation |
| `fail_closed_budget_enforcement` | boolean | false | reject 503 when spend cannot be verified |
| `fail_closed_rate_limit_enforcement` | boolean | false | |
| `token_rate_limit_type` | string | `"total"` | `"input"`, `"output"`, `"total"` (users page) |
| `disable_fallbacks_on_per_model_rate_limits` | boolean | false | per-model key/team limit returns 429 instead of fallback |
| `enforce_fallback_budget` | boolean | true | |
| `max_parallel_requests` / `global_max_parallel_requests` | int | 0 | |
| `proxy_budget_rescheduler_min_time` / `_max_time` | int | 597 / 605 (s) | budget reset check interval |
| `proxy_batch_write_at` | int | 10 (s) | spend log batch write |
| `maximum_spend_logs_retention_period` | string | e.g. `30d` | |
| `store_model_in_db` | bool | — | (configs page) DB overlays general/router/litellm settings |

NOTE (primary): `max_budget` / `budget_duration` are documented under **`litellm_settings`**, not `general_settings`.

### 1.6 Virtual keys — `/key/generate` fields — primary
Sources: https://docs.litellm.ai/docs/proxy/virtual_keys ; https://docs.litellm.ai/docs/proxy/users ; https://docs.litellm.ai/docs/proxy/tag_budgets

| Field | Verified |
|---|---|
| `models` | list of allowed model names, e.g. `["gpt-5.6-luna", "gpt-5.6-terra"]` |
| `max_budget` | float USD; "After the key crosses it's max_budget, requests fail"; default null |
| `budget_duration` | "Budget is reset at the end of specified duration. If not set, budget is never reset." Formats `"30s"`, `"30m"`, `"30h"`, `"30d"` |
| `budget_limits` | list of `{budget_duration, max_budget}` for multiple concurrent windows (`1h`, `24h`, `7d`, `30d`) |
| `model_max_budget` | Enterprise. `Dict[str, GenericBudgetInfo]` → `{"gpt-5.6-terra": {"budget_limit": "0.0000001", "time_period": "1d"}}` |
| `tpm_limit`, `rpm_limit`, `max_parallel_requests` | ints |
| `team_id` | string; key draws on team budget ("If a key belongs to a team, only the team (and team-member) budgets are enforced") |
| `duration` | key expiry e.g. `"30min"`, `"30d"` |
| `aliases` | `{"gpt-5.6-luna": "my-free-tier"}` — request-model → model_group remap per key (tiering) |
| `metadata` | object, e.g. `{"user": "..."}`; `metadata.tags` also supported |
| `tags` | top-level list, e.g. `["engineering"]` — inherits tag budget |
| `soft_budget` | alert threshold (alerting page) |
| `key_alias` | shown in reference text as `key_alias` (used for `enforce key_alias naming pattern`) |
| `/key/update` extras | `temp_budget_increase`, `temp_budget_expiry` (ISO date) |

Verbatim:
```bash
curl 'http://0.0.0.0:4000/key/generate' \
--header 'Authorization: Bearer <your-master-key>' \
--header 'Content-Type: application/json' \
--data-raw '{
  "team_id": "core-infra", # [OPTIONAL]
  "max_budget": 10,
  "budget_duration": "30s",
}'
```
Over-budget response (verbatim): `{"detail":"Authentication Error, ExceededTokenBudget: Current spend for token: 7.2e-05; Max Budget for Token: 2e-07"}`

`GenericBudgetInfo` (primary, users page): `budget_limit: float # The maximum budget amount in USD`, `time_period: str # Duration string like "1d", "30d", etc.`

### 1.7 Teams — `/team/new` — primary
Sources: https://docs.litellm.ai/docs/proxy/users ; https://docs.litellm.ai/docs/proxy/team_budgets

Request fields verified in examples: `team_alias`, `members_with_roles` (`[{"role": "admin", "user_id": "..."}]`), `max_budget`, `budget_duration`, `rpm_limit`, `tpm_limit`. Response object fields (verbatim sample): `team_alias, team_id, admins, members, members_with_roles, metadata, tpm_limit, rpm_limit, max_budget, models, spend, max_parallel_requests, budget_duration, budget_reset_at`.

```bash
curl -X POST 'http://0.0.0.0:4000/team/new' \
     -H "Authorization: Bearer $LITELLM_API_KEY" \
     -H 'Content-Type: application/json' \
     -d '{
            "team_alias": "QA Prod Bot",
            "max_budget": 0.000000001,
            "budget_duration": "1d"
        }'
```
Team-member budget: `/team/member_add` with `max_budget_in_team` (users page heading "Add User to an existing Team - set max_budget_in_team").

### 1.8 Tag budgets — primary
Source: https://docs.litellm.ai/docs/proxy/tag_budgets (`POST /tag/new`)

| Parameter | Type | Required | Description |
|---|---|---|---|
| `name` | string | Yes | Unique name for the tag |
| `description` | string | No | |
| `models` | list[string] | No | Restrict tag to specific models |
| `max_budget` | float | No | Maximum budget in USD |
| `budget_duration` | string | No | e.g. "30d", "1d" |
| `soft_budget` | float | No | Soft budget limit for warnings |
| `rpm_limit` | int | No | across all keys and teams |
| `tpm_limit` | int | No | across all keys and teams |

Tags set per request via `metadata.tags` or header `x-litellm-tags`, or attached to a key via `tags`. `general_settings.reject_clientside_metadata_tags: true` prevents clients influencing budgets via tags.

Config-file variant (Enterprise, provider_budget_routing page):
```yaml
litellm_settings:
  tag_budget_config:
    product:chat-bot: # (Tag)
      max_budget: 0.000000000001 # (USD)
      budget_duration: 1d # (Duration)
    product:chat-bot-2: # (Tag)
      max_budget: 100 # (USD)
      budget_duration: 1d # (Duration)
```

### 1.9 Tiered model groups / aliases — primary
- `router_settings.model_group_alias: {"gpt-5.6": "gpt-5.6-luna"}` — server-side alias (configs page).
- Per-key `aliases` on `/key/generate` (virtual_keys page "Model Aliases"): define `my-free-tier` and `my-paid-tier` model groups in `model_list`, then `"models": ["my-free-tier"], "aliases": {"gpt-5.6-luna": "my-free-tier"}`; "How to upgrade / downgrade request? Change the alias mapping".
- Tag-based routing (tag_routing page): `litellm_params.tags: ["free"|"paid"|"default"]` + `router_settings.enable_tag_filtering: True`; request carries `"tags": ["free"]`.

### 1.10 Prometheus metrics — primary
Source: https://docs.litellm.ai/docs/proxy/prometheus. Enable with:
```yaml
litellm_settings:
  callbacks:
    - prometheus
```
Multi-worker: `export PROMETHEUS_MULTIPROC_DIR="/prometheus_multiproc"`. Scrape `/metrics` (needs Bearer key) or `--prometheus_metrics_port 4001` (v1.101.0+).

| Metric | Description / labels (verbatim) |
|---|---|
| `litellm_spend_metric` | Total Spend, per "end_user", "hashed_api_key", "api_key_alias", "model", "team", "team_alias", "user", "user_email", "client_ip", "user_agent", "requested_model", "model_id", "api_provider", "service_tier" |
| `litellm_total_tokens_metric` | input + output tokens (same label set minus client_ip/user_agent/service_tier) |
| `litellm_input_tokens_metric` / `litellm_output_tokens_metric` | input / output tokens |
| `litellm_input_cached_tokens_metric` | prompt_tokens_details.cached_tokens |
| `litellm_input_cache_creation_tokens_metric` | Anthropic cache_creation_input_tokens |
| `litellm_output_reasoning_tokens_metric` | completion_tokens_details.reasoning_tokens |
| `litellm_input_audio_tokens_metric` / `litellm_output_audio_tokens_metric` | audio tokens |
| `litellm_cache_hits_metric` / `litellm_cache_misses_metric` / `litellm_cached_tokens_metric` | LiteLLM response cache |
| `litellm_team_max_budget_metric` / `litellm_remaining_team_budget_metric` / `litellm_team_budget_remaining_hours_metric` | Labels: "team", "team_alias" |
| `litellm_api_key_max_budget_metric` / `litellm_remaining_api_key_budget_metric` / `litellm_api_key_budget_remaining_hours_metric` | Labels: "hashed_api_key", "api_key_alias" |
| `litellm_remaining_user_budget_metric` / `litellm_user_max_budget_metric` / `litellm_user_budget_remaining_hours_metric` | Labels: "user" |
| `litellm_remaining_org_budget_metric` / `litellm_org_max_budget_metric` / `litellm_org_budget_remaining_hours_metric` | Labels: "org_id", "org_alias" |
| `litellm_remaining_customer_budget_metric` / `litellm_customer_max_budget_metric` / `litellm_customer_budget_remaining_hours_metric` | Labels: "end_user" |
| `litellm_remaining_api_key_requests_for_model` / `litellm_remaining_api_key_tokens_for_model` | per-key per-model rpm/tpm remaining |
| `litellm_provider_remaining_budget_metric` | Labels: "api_provider"; only with provider budget routing |
| `litellm_spend_capture_rate` | captured spend / provider bill; Labels: "api_provider" |
| `litellm_proxy_total_requests_metric` / `litellm_proxy_failed_requests_metric` | proxy-level, label `status_code`, `route`, … |
| `litellm_requests_metric` | deprecated → use `litellm_proxy_total_requests_metric` |
| `litellm_zero_cost_requests_total` | requests priced at $0 on a priced model; label `reason` |
| `litellm_deployment_success_responses` / `litellm_deployment_failure_responses` / `litellm_deployment_total_requests` | per deployment |
| `litellm_remaining_requests_metric` / `litellm_remaining_tokens_metric` | x-ratelimit-remaining-* from provider |
| `litellm_deployment_state` | 0 healthy, 1 partial outage, 2 complete outage |
| `litellm_deployment_latency_per_output_token` | |
| `litellm_deployment_tpm_limit` / `litellm_deployment_rpm_limit` | configured limits |
| `litellm_deployment_cooled_down` / `litellm_deployment_successful_fallbacks` / `litellm_deployment_failed_fallbacks` | fallback metrics |
| `litellm_request_total_latency_metric`, `litellm_request_queue_time_seconds`, `litellm_llm_api_latency_metric`, `litellm_llm_api_time_to_first_token_metric`, `litellm_overhead_latency_metric`, `litellm_overhead_with_guardrails_latency_metric` | histograms, seconds |
| `litellm_callback_logging_failures_metric` | label `callback_name` |

Note: `litellm_total_tokens` / `litellm_remaining_team_budget_metric` — the page uses `litellm_total_tokens_metric` (with `_metric` suffix); PromQL examples append `_total` for counters (e.g. `litellm_input_tokens_metric_total`).

### 1.11 Complete verified example config.yaml — primary (verbatim)
Source: https://docs.litellm.ai/docs/proxy/configs ("Load Balancing" example)
```yaml
model_list:
  - model_name: zephyr-beta
    litellm_params:
        model: huggingface/HuggingFaceH4/zephyr-7b-beta
        api_base: http://0.0.0.0:8001
        rpm: 60 # Optional[int]: When rpm/tpm set - litellm uses weighted pick for load balancing. rpm = Rate limit for this deployment: in requests per minute (rpm).
        tpm: 1000   # Optional[int]: tpm = Tokens Per Minute
  - model_name: zephyr-beta
    litellm_params:
        model: huggingface/HuggingFaceH4/zephyr-7b-beta
        api_base: http://0.0.0.0:8002
        rpm: 600
  - model_name: zephyr-beta
    litellm_params:
        model: huggingface/HuggingFaceH4/zephyr-7b-beta
        api_base: http://0.0.0.0:8003
        rpm: 60000
  - model_name: gpt-5.6-luna
    litellm_params:
        model: gpt-5.6-luna
        api_key: <my-openai-key>
        rpm: 200
  - model_name: gpt-5.6-terra
    litellm_params:
        model: gpt-5.6-terra
        api_key: <my-openai-key>
        rpm: 100

litellm_settings:
  num_retries: 3 # retry call 3 times on each model_name (e.g. zephyr-beta)
  request_timeout: 10 # raise Timeout error if call takes longer than 10s. Sets litellm.request_timeout
  fallbacks: [{"zephyr-beta": ["gpt-5.6-luna"]}] # fallback to gpt-5.6-luna if call fails num_retries
  context_window_fallbacks: [{"zephyr-beta": ["gpt-5.6-terra"]}, {"gpt-5.6-luna": ["gpt-5.6-terra"]}] # fallback to gpt-5.6-terra if context window error
  allowed_fails: 3 # cooldown model if it fails > 1 call in a minute.

router_settings: # router_settings are optional
  routing_strategy: simple-shuffle # Literal["simple-shuffle", "least-busy", "usage-based-routing","latency-based-routing"], default="simple-shuffle"
  model_group_alias: {"gpt-5.6": "gpt-5.6-luna"} # all requests with `gpt-5.6` will be routed to models with `gpt-5.6-luna`
  num_retries: 2
  timeout: 30                                  # 30 seconds
  redis_host: <your redis host>                # set this when using multiple litellm proxy deployments, load balancing state stored in redis
  redis_password: <your redis password>
  redis_port: 1992
```
(The page's angle-bracket placeholders `<my-openai-key>`, `<your redis host>` were rendered empty in the HTML; restored from the page's visible comments. Model names on the page are as shown.)

---

## 2. Azure API Management AI gateway (learn.microsoft.com)

### 2.1 `llm-token-limit` — primary
Source: https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy (page last updated 2026-05-06). APPLIES TO: Developer | Basic | Basic v2 | Standard | Standard v2 | Premium | Premium v2. Policy section: inbound. Scopes: global, workspace, product, API, operation. Gateways: classic, v2, self-hosted, workspace. Supported model APIs: OpenAI Chat Completions or Responses API; Anthropic Messages API (v2 tiers); Google Vertex AI API. Rate exceeded → 429; quota exceeded → 403.

**`azure-openai-token-limit-policy` now HTTP 301-redirects to `llm-token-limit-policy`** (verified by curl, 2026-10-13); the same for `azure-openai-emit-token-metric-policy` → `llm-emit-token-metric-policy`. The legacy element names are not documented on the current pages.

Policy statement (verbatim):
```xml
<llm-token-limit counter-key="key value"
        tokens-per-minute="number"
        token-quota="number"
        token-quota-period="Hourly | Daily | Weekly | Monthly | Yearly"
        estimate-prompt-tokens="true | false"
        retry-after-header-name="custom header name, replaces default 'Retry-After'"
        retry-after-variable-name="policy expression variable name"
        remaining-quota-tokens-header-name="header name"
        remaining-quota-tokens-variable-name="policy expression variable name"
        remaining-tokens-header-name="header name"
        remaining-tokens-variable-name="policy expression variable name"
        tokens-consumed-header-name="header name"
        tokens-consumed-variable-name="policy expression variable name" />
```

| Attribute | Required | Default | Description (abridged, verbatim where quoted) |
|---|---|---|---|
| `counter-key` | Yes | N/A | "The key to use for the token limit policy. For each key value, a single counter is used for all scopes at which the policy is configured. Policy expressions are allowed." |
| `tokens-per-minute` | one of rate/quota/both | N/A | "The maximum number of tokens consumed by prompt and completion per minute." |
| `token-quota` | one of rate/quota/both | N/A | max tokens during `token-quota-period`; policy expressions allowed |
| `token-quota-period` | one of rate/quota/both | N/A | "Hourly, Daily, Weekly, Monthly, Yearly"; fixed window, UTC-truncated start |
| `estimate-prompt-tokens` | Yes | N/A | true = estimate prompt tokens in advance; false = use actual usage from response |
| `retry-after-header-name` | No | `Retry-After` | |
| `retry-after-variable-name` | No | N/A | |
| `remaining-quota-tokens-header-name` / `remaining-quota-tokens-variable-name` | No | N/A | estimated remaining tokens of `token-quota` |
| `remaining-tokens-header-name` / `remaining-tokens-variable-name` | No | N/A | remaining tokens of `tokens-per-minute` |
| `tokens-consumed-header-name` / `tokens-consumed-variable-name` | No | N/A | prompt+completion tokens consumed (header added after backend response) |

Notes (primary): "The policy currently counts prompt and completion tokens only."; streaming always estimates prompt tokens; "This policy tracks token usage independently at each gateway where it is applied"; v2 tiers use token bucket, classic uses sliding window.

Example (verbatim):
```xml
<policies>
    <inbound>
        <base />
        <llm-token-limit
            counter-key="@(context.Subscription.Id)"
            token-quota="100000" token-quota-period="Monthly" remaining-quota-tokens-variable-name="remainingQuotaTokens" />
    </inbound>
    <outbound>
        <base />
    </outbound>
</policies>
```
Rate-limit example (verbatim): `<llm-token-limit counter-key="@(context.Request.IpAddress)" tokens-per-minute="5000" estimate-prompt-tokens="false" remaining-tokens-variable-name="remainingTokens" />`

### 2.2 `llm-emit-token-metric` — primary
Source: https://learn.microsoft.com/en-us/azure/api-management/llm-emit-token-metric-policy (updated 2026-09-15). APPLIES TO: All tiers. Section: inbound. Sends custom metrics to Application Insights. "Token count metrics are model- and provider-dependent and can include total, prompt, and completion tokens. In preview, token count metrics include cached, reasoning, thinking, and other token categories."

```xml
<llm-emit-token-metric
        namespace="metric namespace" >
        <dimension name="dimension name" value="dimension value" />
        ...additional dimensions...
</llm-emit-token-metric>
```
| Item | Required | Default | Notes |
|---|---|---|---|
| `namespace` attr | No | `API Management` | policy expressions not allowed |
| `<dimension name value>` | Yes (≥1) | — | `value` may be omitted only for default dimensions |
| Default dimension names usable without `value` | | | `API ID`, `Operation ID`, `Product ID`, `User ID`, `Subscription ID`, `Location`, `Gateway ID`, `Backend ID` |
| Limits | | | max 5 custom dimensions per policy; 100 unique values per dimension; 1,000 active time series per namespace |

Example (verbatim):
```xml
<policies>
  <inbound>
      <llm-emit-token-metric
            namespace="MyLLM">
            <dimension name="API ID" />
        </llm-emit-token-metric>
  </inbound>
  <outbound>
  </outbound>
</policies>
```

### 2.3 `llm-semantic-cache-lookup` / `llm-semantic-cache-store` — primary
Sources: https://learn.microsoft.com/en-us/azure/api-management/llm-semantic-cache-lookup-policy (updated 2026-08-19); https://learn.microsoft.com/en-us/azure/api-management/llm-semantic-cache-store-policy
```xml
<llm-semantic-cache-lookup
    score-threshold="score threshold to return cached response"
    embeddings-backend-id ="backend entity ID for embeddings API"
    embeddings-backend-auth ="system-assigned"
    ignore-system-messages="true | false"
    max-message-count="count" >
    <vary-by>"expression to partition caching"</vary-by>
</llm-semantic-cache-lookup>
```
| Attribute | Required | Default |
|---|---|---|
| `score-threshold` | Yes | N/A (0.0–1.0; lower = stricter) |
| `embeddings-backend-id` | Yes | N/A |
| `embeddings-backend-auth` | Yes, must be `system-assigned` | N/A |
| `ignore-system-messages` | No | false |
| `max-message-count` | No | N/A |
| `<vary-by>` element | No | — |

`<llm-semantic-cache-store duration="seconds" cache-response="true | false" />` — `duration` Required (TTL seconds); `cache-response` No, default false (omit → only 200 OK cached). Section: outbound. Lookup section: inbound.

Example (verbatim, store page):
```xml
<policies>
    <inbound>
        <base />
        <llm-semantic-cache-lookup
            score-threshold="0.05"
            embeddings-backend-id ="llm-backend"
            embeddings-backend-auth ="system-assigned" >
            <vary-by>@(context.Subscription.Id)</vary-by>
        </llm-semantic-cache-lookup>
        <rate-limit calls="10" renewal-period="60" />
    </inbound>
    <outbound>
        <llm-semantic-cache-store duration="60" />
        <base />
    </outbound>
</policies>
```

### 2.4 `llm-content-safety` — primary
Source: https://learn.microsoft.com/en-us/azure/api-management/llm-content-safety-policy
```xml
<llm-content-safety backend-id="name of backend entity" shield-prompt="true | false" enforce-on-completions="true | false" window-size="integer" window-overlap-size="integer">
    <categories output-type="FourSeverityLevels | EightSeverityLevels">
        <category name="Hate | SelfHarm | Sexual | Violence" threshold="integer" />
    </categories>
    <blocklists>
        <id>blocklist-identifier</id>
    </blocklists>
</llm-content-safety>
```
`backend-id` Required; `shield-prompt` default false; `enforce-on-completions` default false; `window-size` default 1,000 chars (responses); `output-type` default `FourSeverityLevels`; `category.threshold` 0–7. Sections: inbound, outbound.

### 2.5 Backends: load-balanced pool + circuit breaker — primary
Sources: https://learn.microsoft.com/en-us/azure/api-management/backends (updated 2026-05-20); ARM/Bicep reference https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/backends (latest apiVersion shown: `2025-09-01-preview`; examples on the backends page use `2023-09-01-preview`).

Facts (primary): circuit breaker not supported in Consumption tier; "Currently, you can configure only one rule for a backend circuit breaker"; rules are approximate per gateway instance; up to 30 backends in a pool; load balancing options: Round-robin, Weighted, Priority-based ("uses backends in lower priority groups only when all backends in higher priority groups are unavailable because circuit breaker rules are tripped"). Azure OpenAI 429 + `Retry-After` → use `acceptRetryAfter`.

Schema fields (ARM reference, verbatim names):
| Path | Type / constraint |
|---|---|
| `properties.type` | `'Pool'` \| `'Single'` |
| `properties.url` | string, required when type `'Single'` |
| `properties.protocol` | required when type `'Single'` (`http` / `soap`) |
| `properties.pool.services[]` (`BackendPoolItem`) | `id` string (required, ARM id of existing backend), `priority` int 0–100, `weight` int 0–100, `preferredCarbonEmission` `'VeryLow'|'Low'|'Medium'|'High'|'VeryHigh'` |
| `properties.pool.failureResponse.statusCode` | int |
| `properties.pool.sessionAffinity.sessionId.{name,source}` | string (source e.g. `Cookie`) |
| `properties.circuitBreaker.rules[]` (`CircuitBreakerRule`) | `name` string, `tripDuration` string (ISO 8601 duration), `acceptRetryAfter` bool, `failureCondition`, `failureResponse.statusCode` int |
| `failureCondition` (`CircuitBreakerFailureCondition`) | `count` int, `percentage` int, `interval` string (ISO 8601), `errorReasons` string[], `statusCodeRanges[] {min,max}` int 200–599 |

Bicep example (verbatim, backends page):
```bicep
resource symbolicname 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' = {
  name: 'myAPIM/myBackend'
  properties: {
    url: 'https://mybackend.com'
    protocol: 'http'
    circuitBreaker: {
      rules: [
        {
          failureCondition: {
            count: 3
            errorReasons: [
              'Server errors'
            ]
            interval: 'PT1H'
            statusCodeRanges: [
              {
                min: 500
                max: 599
              }
            ]
          }
          name: 'myBreakerRule'
          tripDuration: 'PT1H'
          acceptRetryAfter: true
        }
      ]
    }
   }
 }
```
Pool example (verbatim, ARM JSON):
```json
{
  "type": "Microsoft.ApiManagement/service/backends",
  "apiVersion": "2023-09-01-preview",
  "name": "myAPIM/myBackendPool",
  "properties": {
    "description": "Load balancer for multiple backends",
    "type": "Pool",
    "pool": {
      "services": [
        {
          "id": "/subscriptions/<subscriptionID>/resourceGroups/<resourceGroupName>/providers/Microsoft.ApiManagement/service/<APIManagementName>/backends/backend-1",
          "priority": "1",
          "weight": "3"
        },
        {
          "id": "/subscriptions/<subscriptionID>/resourceGroups/<resourceGroupName>/providers/Microsoft.ApiManagement/service/<APIManagementName>/backends/backend-2",
          "priority": "1",
          "weight": "1"
        }
      ],
        "sessionAffinity": {
        "sessionId": {
          "source": "Cookie",
          "name": "SessionId"
        }
      }
    }
  }
}
```

---

## 3. Terraform resource schemas

### 3.1 `azurerm_consumption_budget_resource_group` / `azurerm_consumption_budget_subscription` — primary (provider repo)
Sources: https://github.com/hashicorp/terraform-provider-azurerm/blob/main/website/docs/r/consumption_budget_resource_group.html.markdown ; .../consumption_budget_subscription.html.markdown (Registry: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/consumption_budget_resource_group). API: `Microsoft.Consumption` 2019-10-01.

| Argument | Required | Values / notes |
|---|---|---|
| `name` | Yes | ForceNew |
| `resource_group_id` (RG) / `subscription_id` (sub) | Yes | ForceNew |
| `amount` | Yes | "The total amount of cost to track with the budget." |
| `time_grain` | No | `BillingAnnual`, `BillingMonth`, `BillingQuarter`, `Annually`, `Monthly`, `Quarterly`; default `Monthly`; ForceNew |
| `time_period { start_date (Req), end_date }` | Yes | start must be first of month; end default = start + 10 years |
| `notification { }` | Yes, 1+ | `operator` (Req: `EqualTo`, `GreaterThan`, `GreaterThanOrEqualTo`), `threshold` (Req, percent 0–1000), `threshold_type` (`Actual` default / `Forecasted`), `contact_emails`, `contact_groups` (Action Group IDs), `contact_roles`, `enabled` (default true). At least one contact_* required. |
| `filter { dimension {} tag {} }` | No | `dimension.name` allowed: `ChargeType`, `Frequency`, `InvoiceId`, `Meter`, `MeterCategory`, `MeterSubCategory`, `PartNumber`, `PricingModel`, `Product`, `ProductOrderId`, `ProductOrderName`, `PublisherType`, `ReservationId`, `ReservationName`, `ResourceGroupName`, `ResourceGuid`, `ResourceId`, `ResourceLocation`, `ResourceType`, `ServiceFamily`, `ServiceName`, `SubscriptionID`, `SubscriptionName`, `UnitOfMeasure`; `operator` only `In`; `values` (Req). `tag {name, operator=In, values}` |

Verbatim example (RG page, trimmed to the budget resource):
```hcl
resource "azurerm_consumption_budget_resource_group" "example" {
  name              = "example"
  resource_group_id = azurerm_resource_group.example.id

  amount     = 1000
  time_grain = "Monthly"

  time_period {
    start_date = "2022-06-01T00:00:00Z"
    end_date   = "2022-07-01T00:00:00Z"
  }

  filter {
    dimension {
      name = "ResourceId"
      values = [
        azurerm_monitor_action_group.example.id,
      ]
    }

    tag {
      name = "foo"
      values = [
        "bar",
        "baz",
      ]
    }
  }

  notification {
    enabled        = true
    threshold      = 90.0
    operator       = "EqualTo"
    threshold_type = "Forecasted"

    contact_emails = [
      "foo@example.com",
      "bar@example.com",
    ]

    contact_groups = [
      azurerm_monitor_action_group.example.id,
    ]

    contact_roles = [
      "Owner",
    ]
  }

  notification {
    enabled   = false
    threshold = 100.0
    operator  = "GreaterThan"

    contact_emails = [
      "foo@example.com",
      "bar@example.com",
    ]
  }
}
```
UNVERIFIED: the exact `ServiceName`/`MeterCategory` dimension *value* strings for Azure OpenAI (e.g. "Azure OpenAI") are not on these pages.

### 3.2 `azurerm_monitor_metric_alert` — primary (provider repo)
Source: https://github.com/hashicorp/terraform-provider-azurerm/blob/main/website/docs/r/monitor_metric_alert.html.markdown. API `Microsoft.Insights` 2018-03-01.

| Argument | Notes |
|---|---|
| `name`, `resource_group_name`, `scopes` (set of resource IDs) | Required |
| `criteria { metric_namespace, metric_name, aggregation, operator, threshold, dimension{name, operator, values}, skip_metric_validation }` | `aggregation`: `Average`, `Count`, `Minimum`, `Maximum`, `Total`; `operator`: `Equals`, `GreaterThan`, `GreaterThanOrEqual`, `LessThan`, `LessThanOrEqual`; dimension operator `Include`, `Exclude`, `StartsWith` |
| `dynamic_criteria { ..., alert_sensitivity (Low/Medium/High), evaluation_total_count (4), evaluation_failure_count (4), ignore_data_before }` | operator: `LessThan`, `GreaterThan`, `GreaterOrLessThan` |
| `action { action_group_id, webhook_properties }` | |
| `frequency` | `PT1M` (default), `PT5M`, `PT15M`, `PT30M`, `PT1H` |
| `window_size` | `PT1M`, `PT5M` (default), `PT15M`, `PT30M`, `PT1H`, `PT6H`, `PT12H`, `P1D`; must be > frequency |
| `severity` | 0–4, default 3 |
| `enabled`, `auto_mitigate` | default true |
| `target_resource_type`, `target_resource_location` | required for subscription/RG/multi scopes |

#### Azure OpenAI metric names for `metric_namespace = "Microsoft.CognitiveServices/accounts"` — primary
Source: https://learn.microsoft.com/en-us/azure/ai-foundry/openai/monitor-openai-reference ("Monitoring data reference for Azure OpenAI", Supported metrics for Microsoft.CognitiveServices/accounts) and https://learn.microsoft.com/en-us/azure/azure-monitor/reference/supported-metrics/microsoft-cognitiveservices-accounts-metrics

| Display name | **Name in REST API (use as `metric_name`)** | Unit | Aggregation | Dimensions |
|---|---|---|---|---|
| Azure OpenAI Requests | `AzureOpenAIRequests` | Count | Total | ApiName, OperationName, Region, StreamType, ModelDeploymentName, ModelName, ModelVersion, StatusCode, IsSpillover, ServiceTierRequest, ServiceTierResponse |
| Processed Prompt Tokens | `ProcessedPromptTokens` | Count | Total | ApiName, ModelDeploymentName, FeatureName, UsageChannel, Region, ModelVersion, ServiceTierRequest, ServiceTierResponse |
| Generated Completion Tokens | `GeneratedTokens` | Count | Total | same as above |
| Processed Inference Tokens (= prompt + generated) | **`TokenTransaction`** | Count | Total | same as above |
| Active Tokens (total minus cached; PTU) | `ActiveTokens` | Count | Min/Max/Avg/Total | Region, ModelDeploymentName, ModelName, ModelVersion, ServiceTierRequest, ServiceTierResponse |
| Total Token Calls | `TotalTokenCalls` | Count | Total | ApiName, OperationName, Region |
| Tokens Per Second | `TokensPerSecond` | Count | Max/Min/Avg | ApiName, OperationName, Region, StreamType, ModelDeploymentName, ModelName, ModelVersion |
| Provisioned-managed Utilization V2 | `AzureOpenAIProvisionedManagedUtilizationV2` | Percent | Min/Max/Avg | Region, StreamType, ModelDeploymentName, ModelName, ModelVersion |
| Prompt Token Cache Match Rate | `AzureOpenAIContextTokensCacheMatchRate` | Percent | Min/Max/Avg | Region, ModelDeploymentName, ModelName, ModelVersion |
| Time to Response | `AzureOpenAITimeToResponse` | MilliSeconds | Min/Max/Avg | ApiName, OperationName, Region, StreamType, ModelDeploymentName, ModelName, ModelVersion, StatusCode, ServiceTier* |
| Time to Last Byte | `AzureOpenAITTLTInMS` | MilliSeconds | | |
| Time Between Tokens | `AzureOpenAINormalizedTBTInMS` | | | |
| Normalized Time to First Byte | `AzureOpenAINormalizedTTFTInMS` | | | |
| Availability | `AzureOpenAIAvailabilityRate` | Percent | | |

Verified correction: there is **no metric named `ProcessedInferenceTokens`** on the reference page; the "Processed Inference Tokens" metric's REST name is `TokenTransaction`. Legacy `TotalCalls`, `SuccessfulCalls`, `ClientErrors`, `ServerErrors` are marked "Do not use for Azure OpenAI service."

### 3.3 `aws_budgets_budget` — primary (provider repo)
Source: https://github.com/hashicorp/terraform-provider-aws/blob/main/website/docs/r/budgets_budget.html.markdown (Registry: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget)

| Argument | Values |
|---|---|
| `budget_type` (Req) | `COST`, `USAGE`, `SAVINGS_PLANS_UTILIZATION`, `RI_UTILIZATION` (from examples) |
| `time_unit` (Req) | `MONTHLY`, `QUARTERLY`, `ANNUALLY`, `DAILY` |
| `limit_amount`, `limit_unit` | string amount, e.g. `"1200"`, `"USD"` |
| `time_period_start` / `time_period_end` | format `2017-01-01_12:00` |
| `cost_filter { name, values }` | `name` ∈ `AZ`, `BillingEntity`, `CostCategory`, `InstanceType`, `InvoicingEntity`, `LegalEntityName`, `LinkedAccount`, `Operation`, `PurchaseType`, `Region`, `Service`, `TagKeyValue`, `UsageType`, `UsageTypeGroup`; conflicts with `filter_expression` |
| `filter_expression { and{} or{} not{} dimensions{key,values,match_options} tags{} cost_categories{} }` | requires `metrics`; `dimensions.key` incl. `SERVICE`, `REGION`, `LINKED_ACCOUNT`, `USAGE_TYPE`, `RECORD_TYPE`, … ; `match_options` `EQUALS`, `STARTS_WITH`, `ENDS_WITH`, `CONTAINS`, `GREATER_THAN_OR_EQUAL`, `CASE_SENSITIVE`, `CASE_INSENSITIVE` |
| `metrics` | `UnblendedCost`, `BlendedCost`, `AmortizedCost`, `NetUnblendedCost`, `NetAmortizedCost`, `UsageQuantity`, `NormalizedUsageAmount`, `Hours` (conflicts with `cost_types`) |
| `cost_types { }` | `include_credit`, `include_discount`, `include_other_subscription`, `include_recurring`, `include_refund`, `include_subscription`, `include_support`, `include_tax`, `include_upfront` (all default true), `use_amortized` (false), `use_blended` (false) |
| `notification { }` | `comparison_operator` (`LESS_THAN`, `EQUAL_TO`, `GREATER_THAN`), `threshold`, `threshold_type` (`PERCENTAGE`, `ABSOLUTE_VALUE`), `notification_type` (`ACTUAL`, `FORECASTED`), `subscriber_email_addresses` or `subscriber_sns_topic_arns` |
| `planned_limit { start_time, amount, unit }`, `auto_adjust_data { auto_adjust_type FORECAST/HISTORICAL, historical_options{budget_adjustment_period} }`, `account_id`, `billing_view_arn`, `name`/`name_prefix`, `tags` | |

Verbatim example:
```hcl
resource "aws_budgets_budget" "ec2" {
  name              = "budget-ec2-monthly"
  budget_type       = "COST"
  limit_amount      = "1200"
  limit_unit        = "USD"
  time_period_end   = "2087-06-15_00:00"
  time_period_start = "2017-07-01_00:00"
  time_unit         = "MONTHLY"

  cost_filter {
    name = "Service"
    values = [
      "Amazon Elastic Compute Cloud - Compute",
    ]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = ["test@example.com"]
  }

  tags = {
    Tag1 = "Value1"
    Tag2 = "Value2"
  }
}
```

**Bedrock service name for `cost_filter { name = "Service" }`:**
- primary (AWS Price List API, https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/AmazonBedrock/current/us-east-1/index.json): offer code `AmazonBedrock` has product attribute `"servicename" : "Amazon Bedrock"`. Other Bedrock offer codes exist: `AmazonBedrockService` (`servicename: "Amazon Bedrock Service"`), `AmazonBedrockAgentCore` (`"Amazon Bedrock AgentCore"`), and `AmazonBedrockFoundationModels`, whose products carry **per-model service names such as `"Claude 3 Haiku (Amazon Bedrock Edition)"`, `"Claude (Amazon Bedrock Edition)"`**. Consequence: a budget filtered only on `Service = "Amazon Bedrock"` may not capture third-party foundation-model token charges that are billed under the "(Amazon Bedrock Edition)" service names. The Price List `servicename` equals what Cost Explorer shows as SERVICE in practice, but that equivalence was not read on a Budgets/Cost Explorer page → **the exact Budgets "Service" filter string list is UNVERIFIED**.
- primary (https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-create-filters.html): AWS Budgets has a Bedrock-specific **"Product attribute"** filter with attributes `provider`, `model`, `inferenceType`, `feature`; "Budgets that use a product attribute filter support actual cost alerts only. Forecasted alerts aren't supported for these budgets." (Terraform exposure of this filter: not found in the aws_budgets_budget doc → UNVERIFIED.)
- primary (https://docs.aws.amazon.com/bedrock/latest/userguide/cost-mgmt-understanding-cur-data.html): CUR `line_item_usage_type` patterns: `{region}-{model}-{token-type}` (standard tier), `{region}-{model}-{token-type}-{tier}` (priority/flex); input tokens `*-input-tokens` or `*-mantle-input-tokens-*`; four token types (input, output, cache read, cache write) must all be summed to reconcile. "CUR does not contain per-request line items."
- primary (https://docs.aws.amazon.com/bedrock/latest/userguide/cost-mgmt-application-inference-profiles.html): application inference profiles carry cost-allocation tags into Cost Explorer and CUR ("finest grain is per usage type per day").

### 3.4 `aws_cloudwatch_metric_alarm` — primary (provider repo)
Source: https://github.com/hashicorp/terraform-provider-aws/blob/main/website/docs/r/cloudwatch_metric_alarm.html.markdown

| Argument | Notes |
|---|---|
| `alarm_name` (Req) | |
| `comparison_operator` | `GreaterThanOrEqualToThreshold`, `GreaterThanThreshold`, `LessThanThreshold`, `LessThanOrEqualToThreshold` (+ anomaly: `LessThanLowerOrGreaterThanUpperThreshold`, `LessThanLowerThreshold`, `GreaterThanUpperThreshold`) |
| `evaluation_periods`, `datapoints_to_alarm` | |
| `metric_name`, `namespace`, `period` (10/20/30 or multiple of 60), `statistic` (`SampleCount`, `Average`, `Sum`, `Minimum`, `Maximum`), `extended_statistic` (p0.0–p100), `unit`, `dimensions` (map) | not with `metric_query` |
| `threshold`, `threshold_metric_id` | |
| `alarm_actions`, `ok_actions`, `insufficient_data_actions` (ARNs), `actions_enabled`, `alarm_description` | |
| `treat_missing_data` | `missing` (default), `ignore`, `breaching`, `notBreaching` |
| `metric_query { id, expression | metric{metric_name, namespace, period, stat, unit, dimensions}, label, period, return_data, account_id }` | max 20 |
| `evaluation_window { wall_clock_window { timezone } }`, `warm_up_configuration`, `evaluation_criteria { promql_criteria { query, pending_period, recovery_period } }`, `evaluation_interval` | newer options |

Verbatim example:
```hcl
resource "aws_cloudwatch_metric_alarm" "foobar" {
  alarm_name                = "terraform-test-foobar5"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
}
```

#### Bedrock CloudWatch metrics — primary
Source: https://docs.aws.amazon.com/bedrock/latest/userguide/monitoring-runtime-metrics.html ("Monitor bedrock-runtime inference using CloudWatch metrics"). Namespace: **`AWS/Bedrock`**. Dimensions: `ModelId` (all metrics); `ModelId + ImageSize + BucketedStepSize` (OutputImageCount); `ModelId + ContextWindow` (Invocations, InvocationLatency, InputTokenCount, OutputTokenCount, EstimatedTPMQuotaUsage; ContextWindow value `1M` for long-context-billed requests). Metrics also published without ModelId; "filtering by ModelId can undercount errors".

| Metric | Unit |
|---|---|
| `Invocations` | Count |
| `InvocationLatency` | MilliSeconds |
| `InvocationClientErrors` | Count |
| `InvocationServerErrors` | Count |
| `InvocationThrottles` | Count (not counted in Invocations) |
| `InputTokenCount` | Count |
| `OutputTokenCount` | Count |
| `LegacyModelInvocations` | Count |
| `OutputImageCount` | Count |
| `TimeToFirstToken` | MilliSeconds (streaming ops) |
| `EstimatedTPMQuotaUsage` | Count ("approximation … Do not use this metric as the sole indicator for quota use") |
| `CacheReadInputTokenCount` | Count (don't count toward TPM quota) |
| `CacheWriteInputTokenCount` | Count |
| `ModelInvocationLogsCloudWatchDeliverySuccess/Failure`, `ModelInvocationLogsS3DeliverySuccess/Failure`, `ModelInvocationLargeDataS3DeliverySuccess/Failure` | logging delivery, "Across all model IDs" dimension |

Note (primary): the `bedrock-mantle.{region}.api.aws` endpoint has a separate metrics page (`monitoring-mantle-metrics.html`), not read.

### 3.5 `google_billing_budget` — primary (provider repo)
Source: https://github.com/hashicorp/terraform-provider-google/blob/main/website/docs/r/billing_budget.html.markdown (Registry: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/billing_budget)

| Argument | Notes |
|---|---|
| `billing_account` (Req) | billing account ID |
| `display_name` | ≤ 60 chars |
| `amount { specified_amount { currency_code, units, nanos } | last_period_amount = true }` (Req) | |
| `budget_filter { projects, resource_ancestors, credit_types_treatment, services, credit_types, subaccounts, labels, calendar_period, custom_period{start_date{year,month,day}, end_date{}} }` | `projects` = `projects/{project_number}`; `services` = `services/{service_id}` ("The service names are available through the Catalog API: https://cloud.google.com/billing/v1/how-tos/catalog-api"); `credit_types_treatment` ∈ `INCLUDE_ALL_CREDITS` (default), `EXCLUDE_ALL_CREDITS`, `INCLUDE_SPECIFIED_CREDITS`; `calendar_period` ∈ `MONTH`, `QUARTER`, `YEAR`, `CALENDAR_PERIOD_UNSPECIFIED` (exactly one of calendar_period/custom_period) |
| `threshold_rules { threshold_percent (Req, 1.0-based: 0.5 = 50%), spend_basis (`CURRENT_SPEND` default, `FORECASTED_SPEND`) }` | repeatable |
| `all_updates_rule { pubsub_topic (projects/{project_id}/topics/{topic_id}), schema_version ("1.0"), monitoring_notification_channels (≤5, projects/{project_id}/notificationChannels/{channel_id}), disable_default_iam_recipients, enable_project_level_recipients }` | |
| `ownership_scope` | `OWNERSHIP_SCOPE_UNSPECIFIED`, `ALL_USERS`, `BILLING_ACCOUNT` |

Verbatim example ("Billing Budget Filter"):
```hcl
resource "google_billing_budget" "budget" {
  billing_account = data.google_billing_account.account.id
  display_name = "Example Billing Budget"

  budget_filter {
    projects               = ["projects/${data.google_project.project.number}"]
    credit_types_treatment = "INCLUDE_SPECIFIED_CREDITS"
    services               = ["services/24E6-581D-38E5"] # Bigquery
    credit_types           = ["PROMOTION", "FREE_TIER"]
    resource_ancestors     = ["organizations/123456789"]
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units = "100000"
    }
  }

  threshold_rules {
    threshold_percent = 0.5
  }
  threshold_rules {
    threshold_percent = 0.9
    spend_basis = "FORECASTED_SPEND"
  }
}
```
**Vertex AI service ID: UNVERIFIED** (Cloud Billing Catalog API `GET https://cloudbilling.googleapis.com/v1/services` requires credentials; cloud.google.com/skus is JS-rendered). Obtain via `services.list` and filter `displayName == "Vertex AI"`.

### 3.6 `google_monitoring_alert_policy` — primary (provider repo)
Source: https://github.com/hashicorp/terraform-provider-google/blob/main/website/docs/r/monitoring_alert_policy.html.markdown

| Argument | Notes |
|---|---|
| `display_name` (Req), `combiner` (Req: `AND`, `OR`, `AND_WITH_MATCHING_RESOURCE`), `conditions` (Req, 1–6), `enabled`, `notification_channels`, `alert_strategy`, `user_labels`, `severity`, `documentation` | |
| `conditions { display_name, condition_threshold{}, condition_absent{}, condition_monitoring_query_language{}, condition_prometheus_query_language{} }` | |
| `condition_threshold { filter, duration (Req), comparison (Req: API supports `COMPARISON_GT`, `COMPARISON_LT` for metric-threshold), threshold_value, aggregations { alignment_period, per_series_aligner, cross_series_reducer, group_by_fields }, trigger { count | percent }, denominator_filter, denominator_aggregations, forecast_options, evaluation_missing_data (`EVALUATION_MISSING_DATA_INACTIVE`/`_ACTIVE`/`_NO_OP`) }` | |

Verbatim example:
```hcl
resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = "My Alert Policy"
  combiner     = "OR"
  conditions {
    display_name = "test condition"
    condition_threshold {
      filter     = "metric.type=\"compute.googleapis.com/instance/disk/write_bytes_count\" AND resource.type=\"gce_instance\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  user_labels = {
    foo = "bar"
  }
}
```

#### Vertex AI publisher-model metrics (for the `filter`) — primary
Source: https://cloud.google.com/monitoring/api/metrics_gcp_a_b (aiplatform section). All BETA, monitored resource **`aiplatform.googleapis.com/PublisherModel`**. Full metric type = `aiplatform.googleapis.com/` + name.

| Metric type (suffix) | Kind, type, unit | Labels |
|---|---|---|
| `publisher/online_serving/token_count` | DELTA, INT64, 1 — "Accumulated input/output token count." | `max_token_size`, `type` (input/output), `request_type` (dedicated/shared), `shared_request_type` (priority/flex/standard), `explicit_caching`, `accounting_resource`, `modality`, `source` |
| `publisher/online_serving/tokens` | DELTA, DISTRIBUTION, 1 — token count distribution | `max_token_size`, `type`, `request_type`, `shared_request_type`, `accounting_resource`, … |
| `publisher/online_serving/consumed_token_throughput` | DELTA, INT64, 1 — "Overall throughput used (accounting for burndown rate) in terms of tokens." | `request_type`, `shared_request_type`, `accounting_resource`, `modality` |
| `publisher/online_serving/model_invocation_count` | DELTA, INT64, 1 | `input_token_size`, `output_token_size`, `max_token_size`, `response_code`, `request_type`, `shared_request_type`, `method`, `error_category`, `explicit_caching`, `accounting_resource`, `source` |
| `publisher/online_serving/model_invocation_latencies` | DELTA, DISTRIBUTION, ms | + `latency_type` (model/overhead) |
| `publisher/online_serving/first_token_latencies` | DELTA, DISTRIBUTION, ms | `input_token_size`, `output_token_size`, `max_token_size`, `request_type`, `shared_request_type`, `explicit_caching` |
| `publisher/online_serving/characters`, `character_count` | DELTA | |
| `publisher/online_serving/dedicated_token_limit`, `dedicated_token_project_max_limit`, `dedicated_gsu_limit`, `dedicated_gsu_project_max_limit`, `dedicated_character_limit`, `dedicated_character_project_max_limit` | GAUGE, INT64 (1/s or 1) — Provisioned Throughput limits | `accounting_resource` |

---

## 4. Provider-side limits

### 4.1 OpenAI Admin API — primary (OpenAI's OpenAPI spec)
platform.openai.com returned HTTP 403 during collection; facts below were read from OpenAI's own published spec https://github.com/openai/openai-openapi (raw `openapi.yaml`, server `https://api.openai.com/v1`). Cross-check against https://platform.openai.com/docs/api-reference/project-rate-limits when possible.

**Project rate limits**
- `GET /organization/projects/{project_id}/rate_limits` (operationId `list-project-rate-limits`; params `limit` default 100, `after`, `before`)
- `POST /organization/projects/{project_id}/rate_limits/{rate_limit_id}` (operationId `update-project-rate-limits`)
- `ProjectRateLimitUpdateRequest` fields: `max_requests_per_1_minute`, `max_tokens_per_1_minute`, `max_images_per_1_minute`, `max_audio_megabytes_per_1_minute`, `max_requests_per_1_day`, `batch_1_day_max_input_tokens` (all integer).
- `ProjectRateLimit` object: `object: "project.rate_limit"`, `id`, `model`, + the six limit fields; required: object, id, model, max_requests_per_1_minute, max_tokens_per_1_minute. Example: `{"object":"project.rate_limit","id":"rl_ada","model":"ada","max_requests_per_1_minute":600,"max_tokens_per_1_minute":150000, ...}`

**Spend alerts (project and organization)** — present in the spec:
- `GET /organization/projects/{project_id}/spend_alerts` (`list-project-spend-alerts`), `POST …/spend_alerts` (`create-project-spend-alert`, body `CreateSpendAlertBody`: required `threshold_amount`, `currency`, `interval`, `notification_channel`), `GET|POST|DELETE …/spend_alerts/{alert_id}` (`retrieve-`, `update-`, `delete-project-spend-alert`); organization-level: `GET|POST /organization/spend_alerts` (`list-organization-spend-alerts`, …), `/organization/spend_alerts/{alert_id}`.
- `ProjectSpendAlert`: `object: "project.spend_alert"`, `threshold_amount` (integer, **cents**), `currency` (enum `USD`), `interval` (enum `month`), `notification_channel` (`SpendAlertNotificationChannel`: `type` enum `email`, `recipients` string[], `subject_prefix` string|null). Example: `{"threshold_amount": 100000, "currency": "USD", "interval": "month", "notification_channel": {"type": "email", "recipients": ["finance@example.com"], "subject_prefix": "OpenAI spend alert"}}`.
- Hard project budget / spend cap field: **not present** in `ProjectCreateRequest` (fields: `name`, `geography`, `residency`, `external_key_id`) → UNVERIFIED / not in API.

**Usage API**
- `GET /organization/usage/completions` (operationId `usage-completions`): `start_time` (Unix s, Req), `end_time`, `bucket_width` (`1m`, `1h`, `1d`; default `1d`), `project_ids`, `user_ids`, `api_key_ids`, `models`, `batch`, `group_by` (enum `project_id`, `user_id`, `api_key_id`, `model`, `batch`, `service_tier`, `api_source`), `limit` (1d: default 7 max 31; 1h: 24/168; 1m: 60/1440), `page`.
- Result `UsageCompletionsResult` fields: `input_tokens`, `input_cached_tokens`, `input_cache_write_tokens`, `input_uncached_tokens`, `output_tokens`, `input_text_tokens`, `output_text_tokens`, `input_cached_text_tokens`, `input_audio_tokens`, `input_cached_audio_tokens`, `output_audio_tokens`, `input_image_tokens`, `input_cached_image_tokens`, `output_image_tokens`, `num_model_requests`, `project_id`, `user_id`, `api_key_id`, `model`, `batch`, `service_tier`, `api_source`.
- Other usage endpoints: `/organization/usage/{audio_speeches, audio_transcriptions, code_interpreter_sessions, embeddings, file_search_calls, images, moderations, vector_stores, web_search_calls, decisions}`.

**Costs API**
- `GET /organization/costs` (operationId `usage-costs`): `start_time` (Req), `end_time`, `bucket_width` ("Currently only `1d` is supported"), `project_ids`, `api_key_ids`, `line_items`, `group_by` (enum `project_id`, `user_id`, `line_item`, `api_key_id`, `api_source`), `limit` (default 7), `page`.
- `CostsResult`: `amount { value, currency ("usd") }`, `line_item`, `project_id`, `user_id`, `api_key_id`, `api_source`.

### 4.2 Anthropic Admin API — primary
Sources: https://docs.claude.com/en/api/admin-api/usage-cost/get-messages-usage-report ; https://docs.claude.com/en/api/admin-api/usage-cost/get-cost-report ; https://docs.claude.com/docs/en/manage-claude/rate-limits-api ; https://docs.claude.com/docs/en/manage-claude/spend-limits-api ; https://docs.claude.com/en/api/usage-cost-api. Auth: Admin API key (`sk-ant-admin…`) in `x-api-key`, `anthropic-version: 2023-06-01`; base `https://api.anthropic.com`.

**`GET /v1/organizations/usage_report/messages`**
| Param | Values |
|---|---|
| `starting_at` (Req) | RFC 3339 |
| `ending_at` | RFC 3339 |
| `bucket_width` | `1d` (default), `1h`, `1m` |
| `group_by[]` | `account_id`, `api_key_id`, `context_window`, `inference_geo`, `model`, `service_account_id`, `service_tier`, `speed`, `workspace_id` |
| filters | `account_ids[]`, `api_key_ids[]`, `models[]`, `service_account_ids[]`, `workspace_ids[]`, `context_window[]` (`0-200k`, `200k-1M`), `inference_geos[]` (`global`, `not_available`, `us`), `service_tiers[]` (`batch`, `flex`, `flex_discount`, `priority`, `priority_on_demand`, `standard`), `speeds[]` (`standard`, `fast`; needs beta header `fast-mode-2026-02-01`) |
| `limit` | 1d: default 7 / max 31; 1h: 24/168; 1m: 60/1440 |
| `page` | next_page token |
Response result fields (verbatim example): `uncached_input_tokens`, `cache_creation { ephemeral_1h_input_tokens, ephemeral_5m_input_tokens }`, `cache_read_input_tokens`, `output_tokens`, `server_tool_use { web_search_requests }`, `model`, `service_tier`, `context_window`, `inference_geo`, `workspace_id`, `api_key_id`, `account_id`, `service_account_id`; envelope `data[] { starting_at, ending_at, results[] }`, `has_more`, `next_page`.

**`GET /v1/organizations/cost_report`**: `starting_at` (Req), `ending_at`, `bucket_width` (`1d` only), `group_by[]` (`description`, `workspace_id`), `limit` (default 7, 1–31), `page`. Result fields: `amount` (string, e.g. `"123.78912"`), `currency` (`USD`), `cost_type` (e.g. `tokens`), `description` (e.g. `"Claude Opus 5.5 Usage - Input Tokens"`), `token_type` (e.g. `cache_creation.ephemeral_1h_input_tokens`), `model`, `service_tier`, `context_window`, `inference_geo`, `workspace_id`.

**Rate Limits API** (read-only): `GET /v1/organizations/rate_limits` (optional `model` query → 404 if no group matches); `GET /v1/organizations/workspaces/{workspace_id}/rate_limits` (`include_inherited=true` to show inherited; default workspace → 404). Entry shape: `type: "rate_limit"`, `group { type (e.g. model_group, batch), id (rlg_…), display_name }`, `models[]`, `limits[] { type, value }` with limit types such as `requests_per_minute`, `input_tokens_per_minute`, `output_tokens_per_minute`, `enqueued_batch_requests`; workspace entries add `source {type: workspace|organization}`. FAQ (verbatim): "Can I update rate limits with this API? No. To set workspace rate limits, go to the Rate limits page in the Claude Console…".

**Spend Limits API** — **Claude Enterprise (claude.ai) organizations only; "not available to Claude Platform (Claude Console) organizations."** Scopes `read:spend_limits` / `write:spend_limits`. Endpoints: `GET /v1/organizations/spend_limits/effective`, `GET /v1/organizations/spend_limits/{spend_limit_id}`, `POST /v1/organizations/spend_limits` (body `{"scope": {"type": "user", "user_id": "…"}, "amount": "75000"}` — amount is a string in minor units/cents; period `monthly` only), `DELETE /v1/organizations/spend_limits/{spend_limit_id}`, plus `GET /v1/organizations/spend_limit_increase_requests`, `GET …/{id}`, `POST …/{id}/approve`, `POST …/{id}/deny` (`suppress_notification: true` optional). Effective row fields: `scope`, `actor`, `amount` (null = unlimited), `currency`, `period`, `source {type: user|seat_tier|rbac_group|organization}`, `spend_limit_id`, `period_to_date_spend`. 60 req/min per org.

Platform note (primary): on "Claude Platform on AWS" only workspace and external-key endpoints exist; usage, cost and rate-limit reports are not available.

### 4.3 Google Vertex AI quotas — primary
Sources: https://cloud.google.com/vertex-ai/generative-ai/docs/quotas (now titled "Generative AI on Agent Platform quotas and system limits"; the docs brand Vertex AI as "Gemini Enterprise Agent Platform"); https://cloud.google.com/vertex-ai/generative-ai/docs/dynamic-shared-quota (301 → `docs.cloud.google.com/...`, page now titled **"Standard PayGo"**).

- The "dynamic shared quota" page now describes **Standard PayGo usage tiers**: org-level prioritized throughput threshold in TPM by rolling 30-day spend. Gemini Pro models: Tier 1 ($10–$250) 500,000 TPM; Tier 2 ($250–$2,000) 1,000,000; Tier 3 ($2,000–$50,000) 2,000,000; Tier 4 (> $50,000) 10,000,000. Gemini Flash/Flash-Lite: 2,000,000 / 4,000,000 / 10,000,000 / 50,000,000. "There's no separate requests-per-minute (RPM) limit for each tier." "Your traffic isn't strictly capped at your tier's TPM threshold."
- Quota metric names verified on the quotas page: `aiplatform.googleapis.com/global_generate_content_requests_per_minute_per_project_per_base_model` (Gemini Omni / Lyria), `aiplatform.googleapis.com/long_running_online_prediction_requests_per_base_model` (Veo), `aiplatform.googleapis.com/online_prediction_requests`, `aiplatform.googleapis.com/global_embed_content_input_tokens_per_minute_per_base_model`, `aiplatform.googleapis.com/global_embed_content_requests_per_minute_per_base_model`, `aiplatform.googleapis.com/generate_content_{image,video,audio,document}_input_per_base_model_id_and_resolution`.
- Quota display string verified: "Online prediction requests per base model per minute per region per base_model" (shown for `base_model: textembedding-gecko`, 1,500 RPM). Console filter uses `Metric: METRIC_NAME` and `Dimensions (e.g. location): MODEL_NAME`.

### 4.4 Mistral Admin API — primary
Source: https://docs.mistral.ai/api/endpoint/beta/admin/billing ("Beta Admin Billing Endpoints — (beta) Admin API - manage spend limits, rate limits and roles. Requires an admin API key."). Base `https://api.mistral.ai`, `Authorization: Bearer <admin key>`.

| Endpoint | Fields |
|---|---|
| `GET /v1/admin/rate-limit` | response `requests_per_second` (int), `tokens_limits_by_model` (map of `{tokens_per_minute, tokens_per_month}`) |
| `GET /v1/admin/spend-limit` | response `limits { completion { monthly_limit_reached }, currency, last_payment_failure, last_payment_failure_protection }` |
| `POST /v1/admin/spend-limit` | body `amount` (int, Req, "New monthly usage limit amount"), `no_monthly_limit` (bool, default false) |
| `GET /v1/admin/usage` | params `month`, `year`, `workspace_id`, `api_zone` (`global`/`us`/`eu`); response `chat`, `completion`, `audio`, `ocr`, `connectors`, `fine_tuning`, `libraries_api`, `vibe_code`, `currency`, `currency_symbol`, `date`, `start_date`, `end_date`, `next_month`, `previous_month`, `prices[]` |
Other admin endpoint groups listed: api-keys, audit-logs, scim, user-groups, users, workspaces, vibe-code-analytics, vibe-work-analytics.

---

## 5. OpenTelemetry GenAI semantic conventions — primary

The GenAI conventions **moved out of `open-telemetry/semantic-conventions` into https://github.com/open-telemetry/semantic-conventions-genai**; opentelemetry.io/docs/specs/semconv/gen-ai/ pages now read "Moved: Generative AI semantic conventions". Docs read from `docs/gen-ai/*.md` and `docs/registry/attributes/gen-ai.md` of that repo (main, 2026-10-13). **Status: Development** on every page/attribute/metric (no Stable GenAI signal yet).

### 5.1 Metrics
Source: `docs/gen-ai/gen-ai-metrics.md`, `docs/gen-ai/gen-ai-token-metrics.md`, `docs/gen-ai/client-inference.md`
| Metric | Instrument | Unit | Notes |
|---|---|---|---|
| `gen_ai.client.inference.usage.input_tokens` | Counter | `{token}` | "including cached tokens"; required attrs `gen_ai.operation.name`, `gen_ai.provider.name`, `gen_ai.token.modality`; cond-req `gen_ai.request.model`; rec `gen_ai.response.model`, `server.address/port`. "When systems report both used tokens and billable tokens, instrumentation MUST report billable tokens." |
| `gen_ai.client.inference.usage.output_tokens` | Counter | `{token}` | "including reasoning tokens" |
| `gen_ai.client.inference.usage.cache_read.input_tokens` / `…cache_write.input_tokens` / `…reasoning.output_tokens` | Counter | `{token}` | subsets of input/output counters |
| `gen_ai.client.inference.operation.input_tokens` / `…operation.output_tokens` | Histogram | `{token}` | per-operation distribution, "should not be used for total usage or cost calculations" |
| `gen_ai.client.inference.duration` | Histogram | `s` | inference operation duration (client-inference.md) |
| `gen_ai.client.inference.time_to_first_chunk`, `gen_ai.client.inference.time_per_output_chunk` | Histogram | `s` | |
| `gen_ai.client.operation.duration` | Histogram | `s` | "This metric SHOULD NOT be reported for inference operations; use `gen_ai.client.inference.duration` instead." Buckets [0.01…81.92] |
| `gen_ai.server.request.duration` | Histogram | `s` | |
| `gen_ai.server.time_per_output_token` | Histogram | `s` | |
| `gen_ai.server.time_to_first_token` | Histogram | `s` | |
| `gen_ai.invoke_workflow.duration`, `gen_ai.invoke_agent.duration` (`s`), `gen_ai.invoke_agent.inference_calls` (`{inference_call}`), `gen_ai.invoke_agent.tool_calls` (`{tool_call}`), `gen_ai.execute_tool.duration` (`s`) | Histogram | | |

**`gen_ai.client.token.usage` and `gen_ai.token.type` are NOT in the current GenAI registry/metrics docs** (searched all fetched files). The old main-repo registry lists `gen_ai.token.type` (values `input`, `output`) only in its "Deprecated GenAI Attributes" table as "Moved to the OpenTelemetry GenAI semantic conventions repository", but no `gen_ai.token.type` row exists in the new repo's registry. Treat `gen_ai.client.token.usage{gen_ai.token.type}` as the superseded pre-move design; current design is the per-category counters above with `gen_ai.token.modality`.

### 5.2 Attributes (registry `docs/registry/attributes/gen-ai.md`)
| Attribute | Type | Status / notes |
|---|---|---|
| `gen_ai.provider.name` | string | **current** discriminator. Well-known values: `anthropic`, `aws.bedrock`, `azure.ai.inference`, `azure.ai.openai`, `cohere`, `deepseek`, `gcp.gemini`, `gcp.gen_ai`, `gcp.vertex_ai`, `groq`, `ibm.watsonx.ai`, … (`openai` in examples) |
| `gen_ai.system` | string | **Deprecated** — "Replaced by `gen_ai.provider.name`" (main-repo deprecated table) |
| `gen_ai.operation.name` | string | values incl. `chat`, `embeddings`, `execute_tool`, `generate_content`, `invoke_agent`, `invoke_workflow`, `text_completion`, `create_agent`, `fetch_response`, `plan`, memory ops |
| `gen_ai.request.model` / `gen_ai.response.model` | string | e.g. `gpt-4` / `gpt-4-0613` |
| `gen_ai.token.modality` | string | `text`, `image`, `audio`, `unknown` |
| `gen_ai.usage.input_tokens` / `gen_ai.usage.output_tokens` | int | span attributes (replaced `gen_ai.usage.prompt_tokens` / `gen_ai.usage.completion_tokens`, now deprecated) |
| `gen_ai.usage.cache_read.input_tokens`, `gen_ai.usage.cache_write.input_tokens`, `gen_ai.usage.reasoning.output_tokens`, `gen_ai.usage.{text,image,audio}.{input,output}_tokens`, `gen_ai.usage.{text,image,audio}.cache_read.input_tokens` | int | subsets "SHOULD be included in" the totals |
| `gen_ai.system_instructions` | any | Opt-In |

### 5.3 OTel Collector minimal config — primary
Sources: https://opentelemetry.io/docs/collector/configuration/ ; https://github.com/open-telemetry/opentelemetry-collector/blob/main/receiver/otlpreceiver/README.md (OTLP receiver: stable for traces/metrics/logs; defaults `localhost:4317` gRPC, `localhost:4318` HTTP; HTTP paths `/v1/traces`, `/v1/metrics`, `/v1/logs`) ; https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/exporter/prometheusexporter/README.md (beta: metrics; required `endpoint`; optional `namespace`, `const_labels`, `send_timestamps` (false), `metric_expiration` (5m), `resource_constant_labels {included, excluded}`, `enable_open_metrics` (false), `translation_strategy` ∈ `UnderscoreEscapingWithSuffixes`, `UnderscoreEscapingWithoutSuffixes`, `NoUTF8EscapingWithSuffixes`, `NoTranslation`; `add_metric_suffixes` and `resource_to_telemetry_conversion` deprecated).

Verbatim receiver (otlpreceiver README):
```yaml
receivers:
  otlp:
    protocols:
      grpc:
      http:
```
Verbatim collector-config page example (note the OTLP gRPC exporter is now named `otlp_grpc`):
```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318
exporters:
  otlp_grpc:
    endpoint: otelcol:4317
    sending_queue:
      batch:
extensions:
  health_check:
    endpoint: 0.0.0.0:13133
  pprof:
    endpoint: 0.0.0.0:1777
  zpages:
    endpoint: 0.0.0.0:55679
service:
  extensions: [health_check, pprof, zpages]
  pipelines:
    traces:
      receivers: [otlp]
      exporters: [otlp_grpc]
    metrics:
      receivers: [otlp]
      exporters: [otlp_grpc]
    logs:
      receivers: [otlp]
      exporters: [otlp_grpc]
```
Verbatim prometheus exporter snippet (prometheusexporter README, trimmed to documented keys):
```yaml
exporters:
  prometheus:
    endpoint: "1.2.3.4:1234"
    namespace: test-space
    const_labels:
      label1: value1
      "another label": spaced value
    send_timestamps: true
    metric_expiration: 180m
```
(Collector-config page also shows `exporters: prometheus: endpoint: prometheus:8889`.) Composed minimal pipeline (assembled from the two verified fragments, not a single verbatim block): `receivers.otlp.protocols.{grpc,http}` → `exporters.prometheus.endpoint` → `service.pipelines.metrics {receivers: [otlp], exporters: [prometheus]}`.

---

## 6. FinOps Foundation — primary

- FinOps for AI page: **https://www.finops.org/wg/finops-for-ai-overview/** ("FinOps for AI Overview"; `https://www.finops.org/wg/finops-for-ai/` 301-redirects to it). Related WG pages linked from it: https://www.finops.org/wg/cost-estimation-of-ai-workloads/ , https://www.finops.org/wg/how-to-build-a-generative-ai-cost-and-usage-tracker/ , https://www.finops.org/wg/how-to-forecast-ai-services-costs-in-cloud/ . Site banner today: "State of Tokenomics: September 2026"; the AI page references "The Tokenomics Foundation".
- FinOps Framework (https://www.finops.org/framework/): Domains = `Understand Usage & Cost`, `Quantify Business Value`, `Optimize Usage & Cost`, `Manage the FinOps Practice`. Scopes listed include **AI**, Public Cloud, SaaS, Data Platform, Private Cloud, Licenses, Data Center. Capability names (verbatim, 22): Data Ingestion; Allocation; Reporting & Analytics; Anomaly Management; Planning & Estimating; Forecasting; Budgeting; KPIs & Benchmarking; Unit Economics; Architecting & Workload Placement; Usage Optimization; Rate Optimization; Licensing & SaaS; Sustainability; Executive Strategy Alignment; FinOps Practice Operations; Governance, Policy & Risk; FinOps Education & Enablement; Invoicing & Chargeback; FinOps Assessment; Automation, Tools & Services; Intersecting Disciplines. (Note: the current Framework uses "Usage Optimization", "Architecting & Workload Placement", "KPIs & Benchmarking" — not "Workload Optimization" / "Benchmarking" / "Architecting for Cloud"; those older names appear in the FinOps for AI paper's "Capabilities Impacted" table.)
- FinOps for AI "Capabilities Impacted" table rows (verbatim names): Data Ingestion; Allocation; Reporting & Analytics; Anomaly Management; Planning & Estimating; Forecasting; Budgeting; Benchmarking; Unit Economics; Rate Optimization; Workload Optimization; Licensing & SaaS; Architecting for Cloud. "Related FinOps Capabilities" sidebar: Usage Optimization; Architecting & Workload Placement; Governance, Policy & Risk.
- **FOCUS current version: 1.4** ("Introducing FOCUS 1.4" on https://focus.finops.org/ ; spec https://focus.finops.org/docs/specification/v1-4/ "Publication version 1.4"; changelog 1.3→1.4: +47 columns, −2 (`Provider`, `Publisher` deprecated/removed), ~14 changed; new datasets Billing Period, Contract Commitment, Invoice Detail). Vendor FOCUS exports listed: AWS v1.2, Microsoft (Azure) v1.2, Google Cloud v1.2, Databricks/Snowflake/Vercel/MongoDB v1.3, Oracle/Alibaba/Tencent/Huawei v1.0.
- **AI/token fields in FOCUS 1.4: no token-specific columns.** Full 1.4 Cost-and-Usage column list read (ServiceCategory, ServiceSubcategory, SkuMeter, SkuPriceDetails, ConsumedQuantity, ConsumedUnit, PricingQuantity, PricingUnit, …) contains no "Token"/"Model" column. AI is represented via: `ServiceCategory` allowed value **"AI and Machine Learning"** (https://focus.finops.org/docs/specification/v1-4/columns/cost-and-usage/service-category/); and the UnitFormat attribute (https://focus.finops.org/docs/specification/v1-4/attributes/unit-format/), which lists `Token`/`Tokens` as a count-based base unit and examples `1000 Tokens`, `Request-Tokens` for `ConsumedUnit`/`PricingUnit`.

---

## Could not verify (left out or marked UNVERIFIED above)
1. Google Cloud Billing service ID for Vertex AI (`services/XXXX-XXXX-XXXX`) — Catalog API needs credentials; SKU site is JS-rendered.
2. Exact AWS Budgets / Cost Explorer "Service" dimension string(s) for Bedrock. Price List API gives `servicename: "Amazon Bedrock"` for offer `AmazonBedrock`, but foundation-model usage is priced under separate "… (Amazon Bedrock Edition)" service names; no AWS Budgets page read states the Service filter values.
3. Terraform exposure of the AWS Budgets Bedrock "Product attribute" filter (provider/model/inferenceType/feature) — not in the aws_budgets_budget doc read.
4. Azure budget `filter.dimension` value strings for Azure OpenAI (`ServiceName` / `MeterCategory` values).
5. `azure-openai-token-limit` / `azure-openai-emit-token-metric` element attributes — pages redirect (301) to the `llm-*` policies; legacy attribute set not documented on current pages.
6. OpenAI: anything from platform.openai.com directly (403); all OpenAI facts come from the `openai/openai-openapi` spec. A project-level hard budget/spend cap field was not found in that spec (only spend alerts).
7. LiteLLM `routing_strategy` reference table lists only 4 values; `usage-based-routing-v2` and `cost-based-routing` are verified only from the routing page (proxy YAML shows `usage-based-routing-v2`; `cost-based-routing` shown in SDK form).
8. OTel `gen_ai.client.token.usage` metric and `gen_ai.token.type` attribute — absent from the current GenAI semconv repo docs; only the per-category `gen_ai.client.inference.usage.*` counters with `gen_ai.token.modality` are current.
9. Bedrock `bedrock-mantle` endpoint metric names (separate page, not read).
10. Vertex AI quota name exactly "Online prediction requests per base model per minute per region" — verified only as the display string on the textembedding-gecko row; per-Gemini-model request quotas are now governed by Standard PayGo tiers rather than listed per-model DSQ rows.
