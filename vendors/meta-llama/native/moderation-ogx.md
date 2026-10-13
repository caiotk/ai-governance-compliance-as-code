# Moderation for Llama served with OGX (formerly Llama Stack): AIG-10

Verified 2026-10-13 against these sources:

- https://github.com/ogx-ai/ogx/blob/main/docs/releases/RELEASE_NOTES_1.0.md
- https://github.com/ogx-ai/ogx/blob/main/docs/docs/providers/responses/inline_builtin.mdx

## What changed in OGX 1.0 (May 2026)

- **Llama Stack is now OGX.** The repository is `github.com/ogx-ai/ogx`.
- **The Safety API is removed.** The release notes say: "Safety API removed; use `/v1/moderations`. Replace `run-shield` and `shields` calls with the moderation endpoint."
- **These endpoints are gone:** `/v1/safety/run-shield` and the `/v1/shields` list and get endpoints.
- **Shield registration is gone.** The release notes say to "configure moderation models via provider config instead."

Find leftover usage before you upgrade:

```bash
grep -r "/v1/safety\|run-shield\|/v1/shields" your-project/
```

## Current pattern (OGX >= 1.0)

1. **Serve a moderation model behind an OpenAI-compatible `/v1/moderations` endpoint.** For example, use Llama Guard 4 (`meta-llama/Llama-Guard-4-12B`) with the category policy in `llama-guard-policy.yaml`. You can also point at any hosted moderation service.
2. **Point the `inline::builtin` responses provider at that endpoint** with `moderation_endpoint`.

The documented fields of the `inline::builtin` provider config are:

| Field | Type | Description (from the OGX docs) |
|---|---|---|
| `moderation_endpoint` | `str \| None` | "URL of an OpenAI-compatible /v1/moderations endpoint for guardrails. The endpoint must accept POST {"input": "text"} and return {"results": [{"flagged": bool, "categories": {...}}]}." |
| `moderation_headers` | `dict[str, str] \| None` | "HTTP headers to send with moderation endpoint requests ... server-side only and never exposed to clients." |

Example distribution config:

- The two field names under `config` are verified.
- The surrounding `providers.responses` list structure is **UNVERIFIED**. It mirrors the provider docs path (`providers/responses/inline_builtin`) and the v0.7.x `providers:` layout, so check it against your distribution's `config.yaml`.

```yaml
providers:
  responses:
  - provider_id: builtin
    provider_type: inline::builtin
    config:
      moderation_endpoint: https://guard.internal.example/v1/moderations
      moderation_headers:
        Authorization: "Bearer ${env.MODERATION_API_TOKEN}"
```

Call the moderation endpoint directly, for example from a gateway:

```bash
curl -sS https://guard.internal.example/v1/moderations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $MODERATION_API_TOKEN" \
  -d '{"input": "text to classify"}'
# -> {"results": [{"flagged": false, "categories": {...}}]}
```

Block when `results[].flagged` is `true`. If the call fails, fail closed.

## LEGACY ONLY: Llama Stack v0.7.x shield configuration

> **This does not work on OGX >= 1.0.** It is kept so you can recognise and migrate older deployments.

This excerpt is verbatim from `src/llama_stack/distributions/starter/config.yaml` at tag v0.7.0 of github.com/ogx-ai/ogx. Other providers and keys are omitted, and `registered_resources` also contains `models: []`.

```yaml
providers:
  safety:
  - provider_id: llama-guard
    provider_type: inline::llama-guard
    config:
      excluded_categories: []
  - provider_id: code-scanner
    provider_type: inline::code-scanner
registered_resources:
  shields:
  - shield_id: llama-guard
    provider_id: ${env.SAFETY_MODEL:+llama-guard}
    provider_shield_id: ${env.SAFETY_MODEL:=}
safety:
  default_shield_id: llama-guard
```

In v0.7.0, `inline::llama-guard` had a single config field, `excluded_categories` (`list[str]`, default `[]`). Keep it empty: excluding hazard categories weakens AIG-10.
