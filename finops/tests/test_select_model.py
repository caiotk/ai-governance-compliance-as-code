"""Unit tests for tools/select_model.py (run: python3 -m unittest discover -s finops/tests)."""
import copy
import datetime as dt
import pathlib
import sys
import unittest

import yaml

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools"))
import select_model as sm  # noqa: E402

CATALOG = yaml.safe_load((ROOT / "finops/catalog/models.yaml").read_text())
AS_OF = dt.date(2026, 10, 13)
BASE = yaml.safe_load((ROOT / "finops/examples/eu-support-chatbot.yaml").read_text())


def wl(**patch):
    w = copy.deepcopy(BASE)
    for k, v in patch.items():
        if isinstance(v, dict) and isinstance(w.get(k), dict):
            w[k].update(v)
        else:
            w[k] = v
    return w


def model(mid):
    return next(m for m in CATALOG["models"] if m["id"] == mid)


class PricingTests(unittest.TestCase):
    def test_simple_cost_matches_price_table(self):
        w = wl(volume={"requests_per_day": 1, "avg_input_tokens": 100_000, "avg_output_tokens": 100_000, "cache_hit_ratio": 0, "batchable_fraction": 0})
        c = sm.cost_per_request(model("openai/gpt-6-luna"), w, AS_OF)
        self.assertAlmostEqual(c["standard_usd"], (0.10 + 0.50) * 0.1, places=6)

    def test_cache_hits_use_cached_price(self):
        w = wl(volume={"requests_per_day": 1, "avg_input_tokens": 1_000_000, "avg_output_tokens": 1, "cache_hit_ratio": 0.5, "batchable_fraction": 0})
        c = sm.cost_per_request(model("anthropic/claude-sonnet-5-5"), w, AS_OF)  # no long-context step on Sonnet 5.5
        self.assertAlmostEqual(c["input_usd"], 0.5 * 2.00 + 0.5 * 0.10, places=6)

    def test_long_context_multiplier_applies_above_threshold(self):
        w = wl(volume={"requests_per_day": 1, "avg_input_tokens": 300_000, "avg_output_tokens": 1000, "cache_hit_ratio": 0, "batchable_fraction": 0})
        c = sm.cost_per_request(model("openai/gpt-6.1-sol"), w, AS_OF)
        self.assertTrue(c["long_context_applied"])
        self.assertAlmostEqual(c["input_usd"], 2.00 * 2.0 * 300_000 / 1e6, places=6)

    def test_batch_fraction_halves_batchable_share(self):
        w = wl(volume={"requests_per_day": 1, "avg_input_tokens": 1_000_000, "avg_output_tokens": 1, "cache_hit_ratio": 0, "batchable_fraction": 1.0})
        c = sm.cost_per_request(model("google/gemini-3.5-flash-lite"), w, AS_OF)
        self.assertAlmostEqual(c["blended_usd"], c["standard_usd"] * 0.5, places=8)

    def test_scheduled_price_change_is_applied_and_announced(self):
        m = model("google/gemini-3.8-flash")
        now, note = sm.effective_prices(m, AS_OF)
        later, note2 = sm.effective_prices(m, dt.date(2027, 1, 2))
        self.assertEqual(now["input"], 0.75)
        self.assertIn("2027-01-01", note)
        self.assertEqual(later["input"], 1.50)
        self.assertIsNone(note2)

    def test_regional_premium_only_when_global_not_allowed(self):
        w = wl(volume={"requests_per_day": 1, "avg_input_tokens": 100_000, "avg_output_tokens": 1, "cache_hit_ratio": 0, "batchable_fraction": 0})
        std = sm.cost_per_request(model("openai/gpt-6-luna"), w, AS_OF, "standard")
        reg = sm.cost_per_request(model("openai/gpt-6-luna"), w, AS_OF, "regional")
        self.assertAlmostEqual(reg["standard_usd"], std["standard_usd"] * 1.1, places=8)


class ConstraintTests(unittest.TestCase):
    def test_eu_residency_excludes_first_party_anthropic_but_allows_bedrock(self):
        # Without a ZDR requirement, Claude on Bedrock (eu. profile) is admissible for EU; first-party Claude is not.
        d = sm.select(wl(constraints={"zdr_required": False, "moderation_required": False}), CATALOG, AS_OF)
        ids = {c["id"] for c in d["candidates"]}
        self.assertNotIn("anthropic/claude-sonnet-5-5@anthropic", ids)
        self.assertIn("anthropic/claude-sonnet-5-5@aws-bedrock", ids)
        self.assertNotIn("meta/llama4-maverick-17b@aws-bedrock", ids)

    def test_zdr_is_per_platform(self):
        d = sm.select(wl(), CATALOG, AS_OF)
        reasons = {e["id"]: e["reasons"] for e in d["excluded"]}
        self.assertTrue(any("zero data retention" in r for r in reasons["anthropic/claude-sonnet-5-5@aws-bedrock"]))

    def test_us_only_bedrock_model_excluded_for_eu(self):
        d = sm.select(wl(constraints={"zdr_required": False, "moderation_required": False, "allow_legacy": True}), CATALOG, AS_OF)
        reasons = {e["id"]: e["reasons"] for e in d["excluded"]}
        self.assertTrue(any("cannot process" in r for r in reasons["meta/llama4-maverick-17b@aws-bedrock"]))

    def test_global_residency_means_no_constraint(self):
        d = sm.select(wl(constraints={"residency": ["global"], "zdr_required": False, "require_attestations": [], "moderation_required": False}), CATALOG, AS_OF)
        self.assertTrue(all(c["cost"]["regional_premium"] == 1.0 for c in d["candidates"]))

    def test_unmeasured_model_cannot_clear_eval_floor(self):
        d = sm.select(wl(constraints={"vendors_allowed": ["mistral"], "residency": ["eu"], "zdr_required": True, "require_attestations": [], "moderation_required": True}, routing={"preference": "single"}), CATALOG, AS_OF)
        self.assertEqual(d["routing"]["primary"]["model"], "mistral/mistral-large-2512")

    def test_complexity_mix_must_sum_to_one(self):
        with self.assertRaises(ValueError):
            sm.select(wl(task={"type": "chat", "complexity_mix": {"simple": 0.5, "hard": 0.2}}), CATALOG, AS_OF)

    def test_mistral_regional_has_no_batch_discount(self):
        w = wl(volume={"requests_per_day": 1, "avg_input_tokens": 1000, "avg_output_tokens": 100, "cache_hit_ratio": 0, "batchable_fraction": 1.0})
        m = model("mistral/mistral-large-2512")
        reg = sm.cost_per_request(m, w, AS_OF, "regional")
        std = sm.cost_per_request(m, w, AS_OF, "standard")
        self.assertAlmostEqual(reg["blended_usd"], reg["standard_usd"], places=10)
        self.assertAlmostEqual(std["blended_usd"], std["standard_usd"] * 0.5, places=10)

    def test_preview_and_legacy_models_excluded_by_default(self):
        d = sm.select(wl(constraints={"residency": [], "zdr_required": False, "require_attestations": [], "moderation_required": False}), CATALOG, AS_OF)
        reasons = {e["id"]: e["reasons"] for e in d["excluded"]}
        self.assertTrue(any("preview" in r for r in reasons["google/gemini-3.1-pro-preview@gcp-vertex"]))
        self.assertTrue(any("legacy" in r for r in reasons["meta/llama4-maverick-17b@aws-bedrock"]))

    def test_approved_model_list_is_a_hard_filter(self):
        d = sm.select(wl(constraints={"approved_models": ["openai/gpt-6-luna"], "residency": [], "zdr_required": False, "require_attestations": [], "moderation_required": False}), CATALOG, AS_OF)
        self.assertTrue(all(c["model"] == "openai/gpt-6-luna" for c in d["candidates"]))

    def test_attestation_requirement(self):
        d = sm.select(wl(constraints={"require_attestations": ["42001"], "residency": [], "zdr_required": False, "moderation_required": False}), CATALOG, AS_OF)
        for c in d["candidates"]:
            self.assertTrue(any("42001" in a for a in c["attestations"]), c["id"])

    def test_deepseek_excluded_for_zdr_and_eu(self):
        d = sm.select(wl(), CATALOG, AS_OF)
        self.assertTrue(all(not c["id"].startswith("deepseek/") for c in d["candidates"]))

    def test_code_specialist_only_for_code_tasks(self):
        d = sm.select(wl(), CATALOG, AS_OF)
        self.assertTrue(all(c["tier"] != "specialist-code" for c in d["candidates"]))
        d2 = sm.select(wl(task={"type": "code", "tools_required": False, "structured_output_required": False}), CATALOG, AS_OF)
        self.assertTrue(any(c["tier"] == "specialist-code" for c in d2["candidates"]))

    def test_context_window_filter(self):
        d = sm.select(wl(volume={"requests_per_day": 1, "avg_input_tokens": 200_000, "avg_output_tokens": 1000, "max_input_tokens": 900_000}, constraints={"residency": [], "zdr_required": False, "require_attestations": [], "moderation_required": False}), CATALOG, AS_OF)
        reasons = {e["id"]: e["reasons"] for e in d["excluded"]}
        self.assertTrue(any("context window" in r for r in reasons["mistral/mistral-small-2603@mistral"]))


class RoutingTests(unittest.TestCase):
    def test_cascade_chosen_when_hard_tail_exists(self):
        d = sm.select(wl(), CATALOG, AS_OF)
        r = d["routing"]
        self.assertEqual(r["mode"], "multi-model-cascade")
        self.assertEqual(r["cascade"]["tiers"][0]["tier"], "daily-driver")
        self.assertEqual(r["cascade"]["tiers"][2]["tier"], "specialist-reasoning")
        self.assertGreater(r["cascade"]["savings_vs_single"], 0.15)

    def test_single_model_when_requested(self):
        d = sm.select(wl(routing={"preference": "single"}), CATALOG, AS_OF)
        self.assertEqual(d["routing"]["mode"], "single-model")

    def test_quality_floor_respected_in_primary(self):
        d = sm.select(wl(), CATALOG, AS_OF)
        prim = next(c for c in d["candidates"] if c["id"] == d["routing"]["primary"]["id"])
        self.assertGreaterEqual(prim["scores"]["quality"], 0.80)

    def test_fallbacks_span_two_vendors(self):
        d = sm.select(wl(), CATALOG, AS_OF)
        self.assertGreaterEqual(len(d["routing"]["vendors_in_route"]), 2)
        self.assertTrue(d["routing"]["fallbacks"])

    def test_same_model_other_platform_is_first_fallback_when_admissible(self):
        d = sm.select(wl(constraints={"zdr_required": False, "moderation_required": False}), CATALOG, AS_OF)
        self.assertEqual(d["routing"]["fallbacks"][0]["reason"], "same model, different platform")

    def test_single_vendor_constraint_warns(self):
        d = sm.select(wl(constraints={"vendors_allowed": ["openai"], "platforms_allowed": ["openai"], "residency": [], "zdr_required": False, "require_attestations": [], "moderation_required": False}), CATALOG, AS_OF)
        self.assertTrue(any("single vendor" in w for w in d["warnings"]))

    def test_budget_breach_warns(self):
        d = sm.select(wl(budget={"monthly_usd": 10}), CATALOG, AS_OF)
        self.assertTrue(any(w.startswith("expected cost") for w in d["warnings"]))

    def test_no_candidates_returns_mode_none(self):
        d = sm.select(wl(constraints={"vendors_allowed": ["nobody"]}), CATALOG, AS_OF)
        self.assertEqual(d["routing"]["mode"], "none")

    def test_tier_prior_is_flagged(self):
        w = wl(); w["quality"] = {"tier_floor": "workhorse"}
        d = sm.select(w, CATALOG, AS_OF)
        self.assertTrue(d["quality_basis"].startswith("tier prior"))
        self.assertTrue(any("tier priors" in x for x in d["warnings"]))

    def test_stale_catalogue_warns(self):
        d = sm.select(wl(), CATALOG, AS_OF + dt.timedelta(days=45))
        self.assertTrue(any("days old" in w for w in d["warnings"]))


class OutputTests(unittest.TestCase):
    def test_litellm_config_has_budgets_and_fallbacks(self):
        d = sm.select(wl(), CATALOG, AS_OF)
        cfg = sm.build_litellm(wl(), d, d["candidates"])
        self.assertEqual(cfg["litellm_settings"]["max_budget"], 15000)
        self.assertTrue(all("max_budget" in m["litellm_params"] for m in cfg["model_list"]))
        chain = cfg["router_settings"]["fallbacks"][0]["eu-support-chatbot-primary"]
        self.assertTrue(chain[0].endswith("-fallback-1"), "continuity route must precede the escalation tier")
        self.assertIn("openai", cfg["router_settings"]["provider_budget_config"])

    def test_routing_state_and_evidence(self):
        d = sm.select(wl(), CATALOG, AS_OF)
        st = sm.build_routing_state(wl(), d)
        ev = sm.build_finops_evidence(wl(), d)
        self.assertEqual(st["active"], "primary")
        self.assertIn("fallback-1", st["routes"])
        self.assertTrue(ev["finops"]["budget_defined"])
        self.assertTrue(ev["resilience"]["secondary_route"])


if __name__ == "__main__":
    unittest.main()
