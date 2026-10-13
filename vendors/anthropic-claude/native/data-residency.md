# Claude data residency controls (AIG-08, AIG-18)

Verified 2026-10-13 against these sources:

- https://platform.claude.com/docs/en/manage-claude/data-residency
- The Workspaces API reference (`/v1/organizations/workspaces`, create and update)

## Three layers

| Layer | Setting | Values | Where it is set |
|---|---|---|---|
| Per request | `inference_geo` on `POST /v1/messages` (also the Batch API) | `"global"` (default), `"us"` | Request body: see `request-example.json` |
| Per workspace (policy) | `data_residency.allowed_inference_geos` | `["us"]`, `["global"]`, `["global","us"]` or `"unrestricted"` (default) | Console, or Admin API `POST /v1/organizations/workspaces/{id}` |
| Per workspace (fallback) | `data_residency.default_inference_geo` | `"global"` (default), `"us"`; must be in `allowed_inference_geos` unless that is `"unrestricted"` | Same as above |
| Per workspace (storage at rest) | `data_residency.workspace_geo` | `"us"` only (currently) | Set only at creation; it cannot be changed later |

If a request asks for an `inference_geo` that is not in `allowed_inference_geos`, the API returns an error. That makes the workspace setting an **enforced** control, not just a default.

The `usage` object in the response echoes the `inference_geo` that was used. Log it as residency evidence (AIG-13).

## Enforce US-only inference for a workspace

Use the native script:

```bash
./admin-api.sh create-workspace production --us-only     # new workspace
./admin-api.sh set-us-only wrkspc_...                     # existing workspace
```

The script sends this request body:

```json
{"data_residency": {"allowed_inference_geos": ["us"], "default_inference_geo": "us"}}
```

Terraform verifies the setting with the `us_only_inference_geo` check in `../terraform/main.tf` (variable `us_only_workspaces`).

## Limits and caveats

**Model support**
- `inference_geo` works on Claude 4.6 and later models.
- Requests that set it on Opus 4.5, Sonnet 4.5, Haiku 4.5 or earlier models return **400**.

**Pricing**
- US-only inference costs 1.1x the standard rate on Claude 4.6 and later models.

**Workspace geo**
- `"us"` is the only workspace geo today.
- There is no EU, AU or NZ at-rest storage option for the first-party API. Record this as an AIG-18 cross-border transfer and cover it with the DPA or transfer mechanism.

**Third-party clouds**
- On Amazon Bedrock and Google Cloud, the endpoint or inference profile sets the region, so `inference_geo` does not apply. Use the cloud's region controls instead (see the Bedrock and Vertex packs).
- On Microsoft Foundry, use the US Data Zone Standard deployment type.
- On Bedrock and Google Cloud, the cloud provider is the data processor.

**OpenAI SDK compatibility endpoint**
- `inference_geo` is not available there.

**Legacy opt-out**
- Organizations that previously opted out of global routing were migrated automatically to `allowed_inference_geos: ["us"]` and `default_inference_geo: "us"`.
