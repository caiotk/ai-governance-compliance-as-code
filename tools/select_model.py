#!/usr/bin/env python3
"""Model selector and token-cost broker configuration generator.

Reads a Workload profile (finops/schema/workload.schema.json) and the model
catalogue (finops/catalog/models.yaml), applies the hard constraints the
governance gate cares about (residency, data handling, attestations, approved
models, lifecycle, capabilities, context window), prices the workload on every
remaining model, scores cost / quality / RAI / latency / lifecycle, and decides
between a single model and a multi-model cascade (daily driver → workhorse →
specialist) with cross-vendor fallbacks for continuity.

Outputs (in --out-dir):
  <id>.decision.json      full ranking, costs, scores, routing and warnings
  <id>.litellm.yaml       LiteLLM proxy config implementing the routing with
                          per-deployment and per-provider budgets
  <id>.routing.yaml       vendor-neutral routing state used by tools/dr.py
  <id>.summary.md         human-readable summary (PR comment)
  <id>.finops.yaml        evidence block to paste into the AI system record

Quality is only "measured" when the workload carries eval scores; otherwise the
tier prior from the catalogue is used and every output says so.
"""
from __future__ import annotations

import argparse
import datetime as dt
import json
import math
import pathlib
import sys

import yaml

ROOT = pathlib.Path(__file__).resolve().parents[1]
TIER_RANK = {"daily-driver": 0, "specialist-code": 1, "workhorse": 1, "specialist-reasoning": 2, "safety": -1}
DAYS_PER_MONTH = 30.4
LITELLM_PREFIX = {
    "openai": "openai", "anthropic": "anthropic", "azure-foundry": "azure", "aws-bedrock": "bedrock",
    "gcp-vertex": "vertex_ai", "gemini-api": "gemini", "mistral": "mistral", "deepseek": "deepseek",
}
PROVIDER_BUDGET_KEY = {
    "openai": "openai", "anthropic": "anthropic", "azure-foundry": "azure", "aws-bedrock": "bedrock",
    "gcp-vertex": "vertex_ai", "gemini-api": "gemini", "mistral": "mistral", "deepseek": "deepseek",
}
REGIONAL_PREMIUM_KEYS = ("regional_processing", "non_global_endpoint", "us_only_inference", "geo_or_in_region", "regional_endpoint")
ZDR_SCORE = {"available": 1.0, "on_approval": 0.6, "on_request": 0.6, "not_documented": 0.0, "unverified": 0.0}
LIFECYCLE_SCORE = {"ga": 1.0, "preview": 0.5, "legacy": 0.2}
DEFAULT_WEIGHTS = {"cost": 0.35, "quality": 0.35, "rai": 0.15, "latency": 0.10, "lifecycle": 0.05}


def load_yaml(p: pathlib.Path):
    return yaml.safe_load(p.read_text(encoding="utf-8"))


# ── Pricing ──────────────────────────────────────────────────────────────────
def effective_prices(model: dict, as_of: dt.date) -> tuple[dict, str | None]:
    """Return the price table in force on `as_of` and a note if a change is scheduled."""
    prices = dict(model["price_usd_per_1m"])
    note = None
    for date_str, future in sorted((model.get("price_from") or {}).items()):
        d = dt.date.fromisoformat(date_str)
        if as_of >= d:
            prices.update(future)
        else:
            note = f"price changes on {date_str}: " + ", ".join(f"{k} {v}" for k, v in future.items())
    return prices, note


def cost_per_request(model: dict, wl: dict, as_of: dt.date, mode: str = "standard") -> dict:
    """USD cost of one average request. mode: standard | batch | regional."""
    v = wl["volume"]
    prices, note = effective_prices(model, as_of)
    inp, out = float(v["avg_input_tokens"]), float(v["avg_output_tokens"])
    cache = float(v.get("cache_hit_ratio", 0) or 0)
    p_in = float(prices.get("input") or 0)
    p_cached = prices.get("cached_input")
    p_cached = p_in if p_cached is None else float(p_cached)
    p_out = float(prices.get("output") or 0)

    in_mult = out_mult = 1.0
    lc = model.get("long_context")
    if lc and inp > float(lc["threshold_input_tokens"]):
        in_mult, out_mult = float(lc["input_multiplier"]), float(lc["output_multiplier"])

    input_cost = ((1 - cache) * p_in + cache * p_cached) * in_mult * inp / 1e6
    output_cost = p_out * out_mult * out / 1e6
    std = input_cost + output_cost

    premium = 1.0
    if mode == "regional":
        for k in REGIONAL_PREMIUM_KEYS:
            if k in (model.get("premiums") or {}):
                premium = float(model["premiums"][k])
                break
    batch_disc = float((model.get("discounts") or {}).get("batch", 1.0) or 1.0)
    b = float(v.get("batchable_fraction", 0) or 0)
    if mode == "regional" and (model.get("discounts") or {}).get("batch_on_regional") is False:
        batch_disc = 1.0  # e.g. Mistral: Batch API not available on regional endpoints
    blended = ((1 - b) * std + b * std * batch_disc) * premium
    return {
        "standard_usd": round(std * premium, 8),
        "blended_usd": round(blended, 8),
        "input_usd": round(input_cost * premium, 8),
        "output_usd": round(output_cost * premium, 8),
        "long_context_applied": in_mult != 1.0,
        "regional_premium": premium,
        "batch_fraction": b,
        "price_note": note,
    }


# ── Constraints ──────────────────────────────────────────────────────────────
def residency_mode(model: dict, allowed: list[str], proc: set[str] | None = None) -> str | None:
    """Return 'standard', 'regional' or None (model cannot serve the geos)."""
    if not allowed or "global" in allowed:
        # No residency requirement (an explicit "global" means "anywhere is fine").
        return "standard"
    if proc is None:
        proc = set(model.get("residency", {}).get("processing", []))
    if proc & set(allowed):
        # Regional endpoints usually carry an uplift; 'regional' means a non-global geo is used.
        return "regional"
    if "regional" in proc and any(a not in ("global",) for a in allowed):
        return "regional"
    return None


FIRST_PARTY = ("openai", "anthropic", "mistral", "deepseek", "gemini-api")
GEO_PREFIXES = {"global": "global", "us": "us", "eu": "eu", "apac": "apac", "au": "au", "jp": "jp", "in": "in", "ca": "ca", "uk": "gb"}


def is_first_party(model: dict, platform: dict) -> bool:
    return platform["platform"] in FIRST_PARTY or platform["platform"] == model.get("vendor")


def platform_processing(model: dict, platform: dict) -> set[str]:
    """Geos a model can be processed in through this platform (per model, never the overlay alone)."""
    if is_first_party(model, platform):
        return set(model.get("residency", {}).get("processing", []))
    if platform.get("processing") is not None:
        return set(platform["processing"])
    geos = set()
    for pid in platform.get("inference_profiles", []) or []:
        prefix = pid.split(".", 1)[0]
        if prefix in GEO_PREFIXES:
            geos.add(GEO_PREFIXES[prefix])
    return geos


def effective(model: dict, platform: dict, overlay: dict) -> dict:
    """Residency, retention, moderation and attestations of a model served through a platform."""
    rai = dict(model.get("rai", {}))
    if not is_first_party(model, platform):
        rai["zdr"] = overlay.get("zdr", "unverified")
        rai["moderation_api"] = bool(overlay.get("moderation_api"))
    else:
        rai["moderation_api"] = bool(rai.get("moderation_api")) or bool(overlay.get("moderation_api"))
    rai["attestations"] = sorted(set(rai.get("attestations", [])) | set(overlay.get("attestations", [])))
    return {"processing": platform_processing(model, platform), "rai": rai}


def check_constraints(model: dict, wl: dict, approved: set[str], platform: dict | None = None, overlay: dict | None = None) -> list[str]:
    c = wl.get("constraints", {})
    eff = effective(model, platform, overlay or {}) if platform else {"processing": set(model.get("residency", {}).get("processing", [])), "rai": model.get("rai", {})}
    t = wl.get("task", {})
    v = wl.get("volume", {})
    reasons: list[str] = []
    caps = set(model.get("capabilities", []))
    if model["tier"] == "safety" and t.get("type") != "moderation":
        reasons.append("safety classifier, not a generation model")
    if model["tier"] == "specialist-code" and t.get("type") != "code":
        reasons.append("code-specialised model; task is not code")
    for m in t.get("modalities", ["text"]):
        if m not in caps:
            reasons.append(f"no {m} input")
    if t.get("tools_required") and "tools" not in caps:
        reasons.append("no tool calling")
    if t.get("structured_output_required") and "structured_output" not in caps:
        reasons.append("no structured output")
    if t.get("reasoning_required") and "reasoning" not in caps:
        reasons.append("no reasoning mode")
    if t.get("type") == "code" and not ({"fim", "tools"} & caps):
        reasons.append("no code capability")
    need_ctx = float(v.get("max_input_tokens") or v["avg_input_tokens"]) + float(v["avg_output_tokens"])
    if model.get("context_window") and need_ctx > float(model["context_window"]):
        reasons.append(f"context window {model['context_window']} < {int(need_ctx)} needed")
    if model.get("max_output") and float(v["avg_output_tokens"]) > float(model["max_output"]):
        reasons.append(f"max output {model['max_output']} < {int(v['avg_output_tokens'])} needed")
    status = model.get("lifecycle", {}).get("status", "ga")
    if status == "preview" and not c.get("allow_preview"):
        reasons.append("preview model (allow_preview=false)")
    if status == "legacy" and not c.get("allow_legacy"):
        reasons.append("legacy model (allow_legacy=false)")
    if c.get("vendors_allowed") and model["vendor"] not in c["vendors_allowed"]:
        reasons.append("vendor not in vendors_allowed")
    if model["vendor"] in (c.get("vendors_denied") or []):
        reasons.append("vendor denied")
    if c.get("platforms_allowed") and platform and platform["platform"] not in c["platforms_allowed"]:
        reasons.append(f"platform {platform['platform']} not allowed")
    if approved and model["id"] not in approved:
        reasons.append("not on the approved-model list (AIG-06)")
    if residency_mode(model, c.get("residency") or [], eff["processing"]) is None:
        reasons.append(f"cannot process in {c.get('residency')}" + (f" via {platform['platform']}" if platform else ""))
    rai = eff["rai"]
    if c.get("zdr_required") and rai.get("zdr") not in ("available", "on_approval", "on_request"):
        reasons.append("zero data retention not documented")
    if c.get("data_classification") in ("special_category", "regulated") and not rai.get("attestations"):
        reasons.append("no verified attestations for regulated data")
    for need in c.get("require_attestations") or []:
        if not any(need.lower() in a.lower() for a in rai.get("attestations", [])):
            reasons.append(f"missing attestation '{need}'")
    if c.get("moderation_required") and not rai.get("moderation_api"):
        reasons.append("no vendor moderation API (bring your own guardrail)")
    return reasons


# ── Scoring ──────────────────────────────────────────────────────────────────
def quality_of(model: dict, wl: dict, tiers: dict) -> tuple[float, str]:
    evals = (wl.get("quality") or {}).get("evals") or {}
    if model["id"] in evals:
        return float(evals[model["id"]]), "measured"
    return float(tiers[model["tier"]]["quality_prior"]), "prior"


def rai_score(model: dict) -> float:
    rai = model.get("rai", {})
    att = min(len(rai.get("attestations", [])) / 5.0, 1.0)
    zdr = ZDR_SCORE.get(rai.get("zdr", "unverified"), 0.0)
    mod = 1.0 if rai.get("moderation_api") else 0.0
    return round(0.5 * att + 0.3 * zdr + 0.2 * mod, 4)


def latency_score(model: dict, wl: dict, tiers: dict) -> float:
    want = (wl.get("latency") or {}).get("class", "any")
    have = tiers[model["tier"]]["latency_class"]
    if want == "any" or want == have:
        return 1.0
    order = {"fast": 0, "medium": 1, "slow": 2}
    return 1.0 if order[have] <= order[want] else 0.4


def score_candidates(cands: list[dict], wl: dict) -> None:
    w = dict(DEFAULT_WEIGHTS)
    w.update({k: float(v) for k, v in (wl.get("weights") or {}).items()})
    total_w = sum(w.values()) or 1.0
    costs = [c["cost"]["blended_usd"] for c in cands]
    lo, hi = math.log10(max(min(costs), 1e-9)), math.log10(max(max(costs), 1e-9))
    for c in cands:
        lc = math.log10(max(c["cost"]["blended_usd"], 1e-9))
        c["scores"]["cost"] = 1.0 if hi == lo else round(1 - (lc - lo) / (hi - lo), 4)
        c["score"] = round(sum(w[k] * c["scores"][k] for k in w) / total_w, 4)
    cands.sort(key=lambda c: (-c["score"], c["cost"]["blended_usd"]))


# ── Routing ──────────────────────────────────────────────────────────────────
def meets_floor(c: dict, wl: dict) -> bool:
    q = wl.get("quality") or {}
    if "min_eval_score" in q:
        # A floor can only be met by a measurement; an unmeasured model never clears it.
        if c["quality_basis"] != "measured" or c["scores"]["quality"] < float(q["min_eval_score"]):
            return False
    if q.get("tier_floor") and TIER_RANK[c["tier"]] < TIER_RANK[q["tier_floor"]]:
        return False
    return True


def pick(cands: list[dict], wl: dict, min_tier: str | None = None, exclude_vendors: set[str] = frozenset(), exclude_ids: set[str] = frozenset()) -> dict | None:
    for c in cands:
        if c["id"] in exclude_ids or c["vendor"] in exclude_vendors:
            continue
        if min_tier and TIER_RANK[c["tier"]] < TIER_RANK[min_tier]:
            continue
        if meets_floor(c, wl):
            return c
    return None


def fallbacks_for(primary: dict, cands: list[dict], wl: dict, want_vendors: int) -> list[dict]:
    """Same model on another platform first (no quality change), then other vendors."""
    out: list[dict] = []
    same_model = [c for c in cands if c["model"] == primary["model"] and c["platform"] != primary["platform"] and meets_floor(c, wl)]
    for c in same_model[:1]:
        out.append({"id": c["id"], "model": c["model"], "platform": c["platform"], "model_id": c["model_id"], "tier": c["tier"], "reason": "same model, different platform"})
    seen_vendors = {primary["vendor"]}
    for c in cands:
        if len(seen_vendors) >= want_vendors:
            break
        if c["vendor"] in seen_vendors or not meets_floor(c, wl):
            continue
        if TIER_RANK[c["tier"]] < TIER_RANK[primary["tier"]]:
            continue
        out.append({"id": c["id"], "model": c["model"], "platform": c["platform"], "model_id": c["model_id"], "tier": c["tier"], "reason": f"different vendor ({c['vendor']}), tier {c['tier']}"})
        seen_vendors.add(c["vendor"])
    return out


def decide_routing(cands: list[dict], wl: dict, rpd: float) -> dict:
    routing = wl.get("routing") or {}
    pref = routing.get("preference", "auto")
    mix = (wl.get("task") or {}).get("complexity_mix") or {}
    want_vendors = int((wl.get("constraints") or {}).get("min_vendors_for_resilience", 2) or 2)
    warnings: list[str] = []

    # Difficulty classes map to minimum tiers: simple → any tier meeting the floor,
    # standard → workhorse or better, hard → specialist. A single model must serve
    # the hardest class present, which is what a cascade avoids paying for.
    simple = float(mix.get("simple", 0)); standard = float(mix.get("standard", 0)); hard = float(mix.get("hard", 0))
    hardest_tier = "specialist-reasoning" if hard > 0 else ("workhorse" if standard > 0 else None)
    single = pick(cands, wl, min_tier=hardest_tier)
    if single is None and hardest_tier:
        single = pick(cands, wl)
        if single is not None:
            warnings.append(f"no admissible {hardest_tier} model for the hardest request class; single-model baseline is a {single['tier']} model")
    if single is None:
        return {"mode": "none", "warnings": ["no candidate meets the quality floor (models without measured evals cannot clear min_eval_score)"]}
    single_monthly = single["cost"]["blended_usd"] * rpd * DAYS_PER_MONTH

    cascade = None
    if mix and pref != "single":
        m_simple = pick(cands, wl)
        m_std = pick(cands, wl, min_tier="workhorse") or m_simple
        m_hard = pick(cands, wl, min_tier="specialist-reasoning") or m_std
        if m_simple and m_std and m_hard and len({m_simple["id"], m_std["id"], m_hard["id"]}) > 1:
            # Hard requests are attempted on the cheaper tier first and escalated, so they pay twice.
            per_req = (simple * m_simple["cost"]["blended_usd"]
                       + standard * (m_std["cost"]["blended_usd"] + (m_simple["cost"]["blended_usd"] if m_std["id"] != m_simple["id"] else 0) * 0.5)
                       + hard * (m_hard["cost"]["blended_usd"] + m_simple["cost"]["blended_usd"]))
            cascade = {
                "tiers": [
                    {"role": "primary", "share": simple, **{k: m_simple[k] for k in ("id", "model", "platform", "model_id", "tier")}},
                    {"role": "escalation", "share": standard, **{k: m_std[k] for k in ("id", "model", "platform", "model_id", "tier")}},
                    {"role": "specialist", "share": hard, **{k: m_hard[k] for k in ("id", "model", "platform", "model_id", "tier")}},
                ],
                "per_request_usd": round(per_req, 8),
                "monthly_usd": round(per_req * rpd * DAYS_PER_MONTH, 2),
                "savings_vs_single": round(1 - per_req / single["cost"]["blended_usd"], 4) if single["cost"]["blended_usd"] else 0,
                "escalation_signals": routing.get("escalation_signals") or ["context_window", "tool_error", "low_confidence", "explicit_tag"],
            }

    min_sav = float(routing.get("min_savings_for_multi", 0.15))
    use_multi = pref == "multi" or (pref == "auto" and cascade is not None and cascade["savings_vs_single"] >= min_sav)
    if pref == "multi" and cascade is None:
        warnings.append("multi-model requested but no complexity_mix or no second tier available; falling back to single")
        use_multi = False
    if cascade is not None and not use_multi and pref == "auto":
        warnings.append(f"cascade would save {cascade['savings_vs_single']:.0%} (< {min_sav:.0%} threshold); single model kept")

    chosen_primary = cascade["tiers"][0] if use_multi else {"role": "primary", "share": 1.0, **{k: single[k] for k in ("id", "model", "platform", "model_id", "tier")}}
    primary_c = next(c for c in cands if c["id"] == chosen_primary["id"])
    fbs = fallbacks_for(primary_c, cands, wl, want_vendors)
    vendors = {primary_c["vendor"]} | {next(c["vendor"] for c in cands if c["id"] == f["id"]) for f in fbs}
    if use_multi:
        vendors |= {next(c["vendor"] for c in cands if c["id"] == t["id"]) for t in cascade["tiers"]}
    if len(vendors) < want_vendors:
        warnings.append(f"only {len(vendors)} vendor(s) satisfy the constraints; min_vendors_for_resilience={want_vendors} not met — BCP depends on a single vendor")

    return {
        "mode": "multi-model-cascade" if use_multi else "single-model",
        "primary": chosen_primary,
        "cascade": cascade if use_multi else None,
        "single_model": {**{k: single[k] for k in ("id", "model", "platform", "model_id", "tier")}, "monthly_usd": round(single_monthly, 2)},
        "fallbacks": fbs,
        "monthly_usd": cascade["monthly_usd"] if use_multi else round(single_monthly, 2),
        "vendors_in_route": sorted(vendors),
        "warnings": warnings,
    }


# ── Output generators ────────────────────────────────────────────────────────
def litellm_model_entry(group: str, cand_or_fb: dict, cands: list[dict], budget_usd: float | None, tags: list[str]) -> dict:
    c = next(x for x in cands if x["id"] == cand_or_fb["id"])
    prefix = LITELLM_PREFIX.get(c["platform"], c["platform"])
    if c["platform"] == "azure-foundry" and c["vendor"] != "openai":
        prefix = "azure_ai"  # Foundry-hosted non-OpenAI models (not re-verified; see header)
    params = {"model": f"{prefix}/{cand_or_fb['model_id']}"}
    # Credentials by platform (env refs only; LiteLLM resolves os.environ/NAME at load time).
    plat = c["platform"]
    if plat == "aws-bedrock":
        params["aws_region_name"] = "os.environ/AWS_REGION_NAME"
    elif plat == "azure-foundry":
        params.update({"api_base": "os.environ/AZURE_API_BASE", "api_version": "os.environ/AZURE_API_VERSION", "api_key": "os.environ/AZURE_API_KEY"})
    elif plat == "gcp-vertex":
        params.update({"vertex_project": "os.environ/VERTEX_PROJECT", "vertex_location": "os.environ/VERTEX_LOCATION"})
    else:
        params["api_key"] = f"os.environ/{plat.upper().replace('-', '_')}_API_KEY"
    params.update({
        "tags": list(tags),
        "input_cost_per_token": round(c["prices"]["input"] / 1e6, 12),
        "output_cost_per_token": round(c["prices"]["output"] / 1e6, 12),
    })
    if budget_usd is not None:
        params["max_budget"] = round(budget_usd, 2)
        params["budget_duration"] = "30d"
    return {"model_name": group, "litellm_params": params, "model_info": {"id": f"{group}--{c['id'].replace('/', '-').replace('@', '-on-')}", "tier": c["tier"], "vendor": c["vendor"], "catalogue_id": c["id"]}}


def build_litellm(wl: dict, decision: dict, cands: list[dict]) -> dict:
    wid = wl["metadata"]["id"]
    budget = (wl.get("budget") or {}).get("monthly_usd")
    tags = [f"workload:{wid}"] + list(wl["metadata"].get("tags") or [])
    r = decision["routing"]
    model_list: list[dict] = []
    fallbacks: list[dict] = []
    ctx_fallbacks: list[dict] = []
    provider_budget: dict = {}

    def add(group, item, share):
        b = budget * share * 1.2 if budget else None  # headroom above the expected share
        model_list.append(litellm_model_entry(group, item, cands, b, tags))
        key = PROVIDER_BUDGET_KEY.get(item["platform"], item["platform"])
        if budget:
            provider_budget[key] = {"budget_limit": round(max(provider_budget.get(key, {}).get("budget_limit", 0), budget * 1.2), 2), "time_period": "30d"}

    def ctx_of(item):
        return float(next(x for x in cands if x["id"] == item["id"]).get("context_window") or 0)

    fb_groups: list[str] = []
    if r["mode"] == "multi-model-cascade":
        tiers = r["cascade"]["tiers"]
        groups = [f"{wid}-primary", f"{wid}-escalation", f"{wid}-specialist"]
        for g, t in zip(groups, tiers):
            add(g, t, t["share"] or 0.2)
        bigger = [g for g, t in zip(groups[1:], tiers[1:]) if ctx_of(t) > ctx_of(tiers[0])]
        if bigger:
            ctx_fallbacks.append({groups[0]: bigger})
        fallbacks.append({groups[1]: [groups[2]]})
    else:
        add(f"{wid}-primary", r["primary"], 1.0)
    for i, fb in enumerate(r["fallbacks"]):
        g = f"{wid}-fallback-{i + 1}"
        add(g, fb, 0.3)
        fb_groups.append(g)
    # Continuity routes come first (same quality, other platform/vendor); the costlier
    # escalation tier is the last resort for an ordinary error.
    primary_chain = fb_groups + ([f"{wid}-escalation"] if r["mode"] == "multi-model-cascade" else [])
    if primary_chain:
        fallbacks.insert(0, {f"{wid}-primary": primary_chain})

    # merge fallback entries for the primary group into one list
    merged: dict[str, list[str]] = {}
    for fb in fallbacks:
        for k, v in fb.items():
            merged.setdefault(k, [])
            for x in v:
                if x not in merged[k]:
                    merged[k].append(x)
    cfg = {
        "model_list": model_list,
        "router_settings": {
            "routing_strategy": "simple-shuffle",
            "enable_pre_call_checks": True,
            "num_retries": 2,
            "allowed_fails": 3,
            "cooldown_time": 30,
            "fallbacks": [{k: v} for k, v in merged.items()],
            "context_window_fallbacks": ctx_fallbacks,
            "default_fallbacks": [f"{wid}-fallback-1"] if r["fallbacks"] else [],
            "model_group_alias": {wid: f"{wid}-primary"},
            "provider_budget_config": provider_budget,
        },
        "litellm_settings": {
            "callbacks": ["prometheus", "otel"],
            "max_budget": round(budget, 2) if budget else 0,
            "budget_duration": "30d",
            "prometheus_initialize_budget_metrics": True,
        },
        "general_settings": {
            "master_key": "os.environ/LITELLM_MASTER_KEY",
            "database_url": "os.environ/DATABASE_URL",
            "store_model_in_db": True,
            "background_health_checks": True,
            "health_check_interval": 300,
            "alerting": ["slack"],
            "alert_types": ["budget_alerts", "llm_exceptions", "cooldown_deployment", "region_outage_alerts"],
            "reject_clientside_metadata_tags": True,
            "enforce_fallback_model_access": True,
        },
    }
    return cfg


def build_routing_state(wl: dict, decision: dict) -> dict:
    r = decision["routing"]
    primary = r["primary"]
    return {
        "apiVersion": "aigov/v1",
        "kind": "Routing",
        "workload": wl["metadata"]["id"],
        "generated": decision["generated"],
        "mode": r["mode"],
        "active": "primary",
        "routes": {
            "primary": {k: primary[k] for k in ("id", "model", "platform", "model_id", "tier")},
            **{f"fallback-{i + 1}": {k: fb[k] for k in ("id", "model", "platform", "model_id", "tier")} | {"reason": fb["reason"]} for i, fb in enumerate(r["fallbacks"])},
        },
        "cascade": r.get("cascade"),
        "budget_monthly_usd": (wl.get("budget") or {}).get("monthly_usd"),
        "expected_monthly_usd": r["monthly_usd"],
        "rto_minutes": None,
        "last_failover": None,
        "last_drill": None,
    }


def build_summary(wl: dict, decision: dict) -> str:
    r = decision["routing"]
    lines = [f"## Model selection — `{wl['metadata']['id']}`", "",
             f"Catalogue as of {decision['catalogue_as_of']} · evaluated {decision['generated']} · quality basis: **{decision['quality_basis']}**", ""]
    if r["mode"] == "none":
        lines += ["❌ No model satisfies the constraints.", ""] + [f"- {x}" for x in r.get("warnings", [])]
        return "\n".join(lines) + "\n"
    lines += [f"**Routing:** {r['mode']} · expected **${r['monthly_usd']:,.2f}/month** across {', '.join(r['vendors_in_route'])}", ""]
    if r["cascade"]:
        lines += ["| Role | Share | Model | Platform | Tier |", "|---|---|---|---|---|"]
        for t in r["cascade"]["tiers"]:
            lines.append(f"| {t['role']} | {t['share']:.0%} | `{t['id']}` | {t['platform']} | {t['tier']} |")
        lines += ["", f"Cascade saves {r['cascade']['savings_vs_single']:.0%} vs the best single model (`{r['single_model']['id']}`, ${r['single_model']['monthly_usd']:,.2f}/month). Escalate on: {', '.join(r['cascade']['escalation_signals'])}.", ""]
    else:
        p = r["primary"]
        lines += [f"Primary: `{p['id']}` on {p['platform']} ({p['tier']})", ""]
    if r["fallbacks"]:
        lines += ["**Fallbacks (BCP):** " + "; ".join(f"`{f['id']}` — {f['reason']}" for f in r["fallbacks"]), ""]
    budget = (wl.get("budget") or {}).get("monthly_usd")
    if budget:
        pct = r["monthly_usd"] / budget if budget else 0
        flag = "✅" if pct <= 1 else "❌"
        lines += [f"{flag} Budget: ${r['monthly_usd']:,.2f} of ${budget:,.2f} ({pct:.0%})", ""]
    lines += ["### Ranking", "", "| # | Model | Tier | $/request | $/month | Quality | RAI | Score | Notes |", "|---|---|---|---|---|---|---|---|---|"]
    for i, c in enumerate(decision["candidates"][:12], 1):
        notes = "; ".join(filter(None, [c["cost"].get("price_note"), "long-context pricing" if c["cost"]["long_context_applied"] else None, f"{c['cost']['regional_premium']}x regional" if c["cost"]["regional_premium"] != 1 else None, None if meets_floor(c, wl) else "below quality floor"]))
        lines.append(f"| {i} | `{c['id']}` | {c['tier']} | {c['cost']['blended_usd']:.6f} | {c['monthly_usd']:,.2f} | {c['scores']['quality']:.2f} ({c['quality_basis']}) | {c['scores']['rai']:.2f} | {c['score']:.3f} | {notes} |")
    if decision["excluded"]:
        lines += ["", "<details><summary>Excluded model/platform combinations</summary>", ""]
        for e in decision["excluded"]:
            lines.append(f"- `{e['id']}`: {'; '.join(e['reasons'])}")
        lines += ["", "</details>"]
    if decision["warnings"]:
        lines += ["", "**Warnings**", ""] + [f"- ⚠️ {w}" for w in decision["warnings"]]
    return "\n".join(lines) + "\n"


def build_finops_evidence(wl: dict, decision: dict) -> dict:
    r = decision["routing"]
    budget = (wl.get("budget") or {}).get("monthly_usd")
    return {"finops": {
        "budget_defined": bool(budget),
        "monthly_budget_usd": budget,
        "expected_monthly_usd": r.get("monthly_usd"),
        "token_limits_enforced": False,
        "cost_allocation_tags": [f"workload:{wl['metadata']['id']}"],
        "model_selection_record": f"finops/decisions/{wl['metadata']['id']}.decision.json",
        "model_selection_date": decision["generated"],
        "routing_mode": r.get("mode"),
    }, "resilience": {"secondary_route": bool(r.get("fallbacks"))}}


# ── Main ─────────────────────────────────────────────────────────────────────
def select(wl: dict, catalog: dict, as_of: dt.date) -> dict:
    tiers = catalog["tiers"]
    rpd = float(wl["volume"]["requests_per_day"])
    mix = (wl.get("task") or {}).get("complexity_mix") or {}
    if mix and abs(sum(float(x) for x in mix.values()) - 1.0) > 0.01:
        raise ValueError(f"task.complexity_mix must sum to 1 (got {sum(float(x) for x in mix.values()):.2f})")
    c = wl.get("constraints") or {}
    approved = set(c.get("approved_models") or [])
    res_allowed = c.get("residency") or []
    plats_allowed = set(c.get("platforms_allowed") or [])
    cands: list[dict] = []
    excluded: list[dict] = []
    warnings: list[str] = []

    overlays = catalog.get("platforms") or {}
    for m in catalog["models"]:
        for plat in m["platforms"]:
            overlay = overlays.get(plat["platform"], {})
            reasons = check_constraints(m, wl, approved, plat, overlay)
            if reasons:
                excluded.append({"id": f"{m['id']}@{plat['platform']}", "reasons": reasons})
                continue
            eff = effective(m, plat, overlay)
            mode = residency_mode(m, res_allowed, eff["processing"])
            first_party = plat["platform"] in (m["vendor"], "gemini-api") or plat["platform"] == m.get("vendor_pack")
            # First-party endpoints carry the vendor's own regional premium; cloud platforms
            # carry their SKU multiplier instead (e.g. Azure Data Zone 1.1x), never both.
            cost = cost_per_request(m, wl, as_of, "regional" if (mode == "regional" and first_party) else "standard")
            mult = 1.0
            skus = plat.get("sku_multipliers") or {}
            if not first_party and mode == "regional" and skus:
                mult = float(skus.get("DataZoneStandard", 1.0))
            elif plat.get("price_multiplier"):
                mult = float(plat["price_multiplier"])
            if mult != 1.0:
                cost = {**cost, "standard_usd": round(cost["standard_usd"] * mult, 8), "blended_usd": round(cost["blended_usd"] * mult, 8), "regional_premium": round(cost["regional_premium"] * mult, 3)}
            q, basis = quality_of(m, wl, tiers)
            prices, _ = effective_prices(m, as_of)
            m_eff = {**m, "rai": eff["rai"]}
            cands.append({
                "id": f"{m['id']}@{plat['platform']}", "model": m["id"], "name": m["name"], "vendor": m["vendor"], "tier": m["tier"],
                "platform": plat["platform"], "model_id": plat["model_id"],
                "processing": sorted(eff["processing"]), "attestations": eff["rai"]["attestations"], "context_window": m.get("context_window"),
                "prices": {k: (float(v) if v is not None else None) for k, v in prices.items()},
                "cost": cost, "monthly_usd": round(cost["blended_usd"] * rpd * DAYS_PER_MONTH, 2),
                "quality_basis": basis,
                "scores": {"quality": q, "rai": rai_score(m_eff), "latency": latency_score(m, wl, tiers), "lifecycle": LIFECYCLE_SCORE.get(m.get("lifecycle", {}).get("status", "ga"), 0.5)},
                "lifecycle": m.get("lifecycle", {}), "verification": m.get("verification"),
            })
            if cost.get("price_note") and cost["price_note"] not in " ".join(warnings):
                warnings.append(f"{m['id']}: {cost['price_note']}")

    if not cands:
        return {"workload": wl["metadata"]["id"], "generated": as_of.isoformat(), "catalogue_as_of": catalog["asOf"], "quality_basis": "n/a",
                "candidates": [], "excluded": excluded, "routing": {"mode": "none", "warnings": ["no model satisfies the hard constraints"]}, "warnings": warnings}

    score_candidates(cands, wl)
    routing = decide_routing(cands, wl, rpd)
    warnings += routing.pop("warnings", [])
    basis = "measured" if all(x["quality_basis"] == "measured" for x in cands) else ("mixed" if any(x["quality_basis"] == "measured" for x in cands) else "tier prior (no evals supplied — run the evaluation suite before promotion, AIG-14)")
    if basis.startswith("tier prior"):
        warnings.append("quality scores are tier priors, not measurements; the recommendation is provisional until quality.evals is filled from your evaluation suite")
    budget = (wl.get("budget") or {}).get("monthly_usd")
    if budget and routing.get("monthly_usd", 0) > budget:
        warnings.append(f"expected cost ${routing['monthly_usd']:,.2f} exceeds the monthly budget ${budget:,.2f}")
    cap = (wl.get("budget") or {}).get("max_cost_per_request_usd")
    if cap and routing.get("mode") != "none":
        prim = next(x for x in cands if x["id"] == routing["primary"]["id"])
        if prim["cost"]["blended_usd"] > cap:
            warnings.append(f"primary cost/request {prim['cost']['blended_usd']:.6f} exceeds max_cost_per_request_usd {cap}")
    stale = (as_of - dt.date.fromisoformat(catalog["asOf"])).days
    if stale > 30:
        warnings.append(f"catalogue prices are {stale} days old — refresh finops/catalog/models.yaml before relying on costs")
    return {"workload": wl["metadata"]["id"], "generated": as_of.isoformat(), "catalogue_as_of": catalog["asOf"], "quality_basis": basis,
            "candidates": cands, "excluded": excluded, "routing": routing, "warnings": warnings}


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("workload", type=pathlib.Path)
    ap.add_argument("--catalog", type=pathlib.Path, default=ROOT / "finops/catalog/models.yaml")
    ap.add_argument("--schema", type=pathlib.Path, default=ROOT / "finops/schema/workload.schema.json")
    ap.add_argument("--out-dir", type=pathlib.Path, default=ROOT / "finops/decisions")
    ap.add_argument("--date", help="Evaluation date YYYY-MM-DD (default: today)")
    ap.add_argument("--fail-on-budget", action="store_true", help="exit 1 when the expected cost exceeds the budget")
    args = ap.parse_args(argv)

    wl = load_yaml(args.workload)
    try:
        import jsonschema
        jsonschema.Draft202012Validator(json.loads(args.schema.read_text())).validate(wl)
    except ImportError:
        pass
    except Exception as e:  # noqa: BLE001
        print(f"workload profile invalid: {getattr(e, 'message', e)}", file=sys.stderr)
        return 2
    catalog = load_yaml(args.catalog)
    as_of = dt.date.fromisoformat(args.date) if args.date else dt.date.today()
    try:
        decision = select(wl, catalog, as_of)
    except ValueError as e:
        print(f"workload profile invalid: {e}", file=sys.stderr)
        return 2

    wid = wl["metadata"]["id"]
    args.out_dir.mkdir(parents=True, exist_ok=True)
    (args.out_dir / f"{wid}.decision.json").write_text(json.dumps(decision, indent=2) + "\n")
    (args.out_dir / f"{wid}.summary.md").write_text(build_summary(wl, decision))
    if decision["routing"]["mode"] != "none":
        cfg = build_litellm(wl, decision, decision["candidates"] + [])
        header = ("# Generated by tools/select_model.py — LiteLLM proxy config implementing the routing decision.\n"
                  "# Verified keys (docs/sources/finops-tooling.md §1): model_list/litellm_params (model, api_key, api_base, api_version,\n"
                  "# tags, max_budget, budget_duration, input/output_cost_per_token), router_settings (fallbacks, context_window_fallbacks,\n"
                  "# default_fallbacks, provider_budget_config, enable_tag_filtering, model_group_alias, cooldown_time, allowed_fails,\n"
                  "# num_retries, enable_pre_call_checks), litellm_settings (callbacks, max_budget, budget_duration), general_settings.\n"
                  "# Not re-verified there: provider prefixes mistral/, deepseek/ and azure_ai/, aws_region_name, vertex_project/\n"
                  "# vertex_location, provider_budget_config keys bedrock/mistral/deepseek, and the custom model_info.tier/vendor/\n"
                  "# catalogue_id fields — taken from LiteLLM's provider pages; check against your LiteLLM version. Budgets need\n"
                  "# the proxy database. Tags are for spend attribution only (tag filtering is off).\n")
        (args.out_dir / f"{wid}.litellm.yaml").write_text(header + yaml.safe_dump(cfg, sort_keys=False, allow_unicode=True))
        (args.out_dir / f"{wid}.routing.yaml").write_text(yaml.safe_dump(build_routing_state(wl, decision), sort_keys=False))
        (args.out_dir / f"{wid}.finops.yaml").write_text(yaml.safe_dump(build_finops_evidence(wl, decision), sort_keys=False))
    print(build_summary(wl, decision))
    if decision["routing"]["mode"] == "none":
        return 1
    if args.fail_on_budget and any(w.startswith("expected cost") for w in decision["warnings"]):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
