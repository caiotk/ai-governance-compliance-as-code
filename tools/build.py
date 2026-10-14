#!/usr/bin/env python3
"""Validate the catalogue and generate every derived artefact.

    python3 tools/build.py          # validate + regenerate
    python3 tools/build.py --check  # validate + fail if generated files are stale (CI)

Generated outputs:
    mlops/data/catalog.json         data document for the Rego policies
    profiles/<cc>/<sector>.md       60 country × sector compliance profiles
    profiles/<cc>/<sector>.system.yaml  pre-filled AI system record template per profile
    profiles/index.json             machine-readable profile index
    docs/CROSSWALK.md               control × framework crosswalk
    docs/RISKS.md                   risk catalogue with the controls that treat each risk
    site/data/catalog.json          dashboard data
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
CATALOG = ROOT / "catalog"
COUNTRIES = ["BR", "CL", "AR", "PT", "ES", "US", "AU", "NZ", "JP", "SG"]
SECTORS = ["health", "fsi", "public", "agriculture", "mining", "tech", "energy"]
INSTRUMENT_GROUPS = ["horizontal", "data_protection", "cyber"]
VERIFICATION = {"primary", "secondary", "unverified"}
STATUSES = {"in-force", "in-force-phased", "phased", "pending", "voluntary", "none", "proposed"}
CONTROL_RE = re.compile(r"^AIG-\d{2}$")

errors: list[str] = []


def err(msg: str) -> None:
    errors.append(msg)


def load(path: Path):
    with path.open(encoding="utf-8") as fh:
        return yaml.safe_load(fh)


# ── Load ─────────────────────────────────────────────────────────────────────
frameworks_doc = load(CATALOG / "frameworks.yaml")
controls_doc = load(CATALOG / "controls.yaml")
sectors_doc = load(CATALOG / "sectors.yaml")
risks_doc = load(CATALOG / "risks.yaml")
jurisdictions = {p.stem.upper(): load(p) for p in sorted((CATALOG / "jurisdictions").glob("*.yaml"))}

frameworks = {f["id"]: f for f in frameworks_doc["frameworks"]}
controls = {c["id"]: c for c in controls_doc["controls"]}
sectors = {s["id"]: s for s in sectors_doc["sectors"]}
risks = {r["id"]: r for r in risks_doc["risks"]}
RISK_RE = re.compile(r"^RSK-\d{2}$")
SEVERITIES = {"high", "medium", "low"}


def schema_paths() -> set[str]:
    schema = json.loads((ROOT / "mlops/schema/ai-system.schema.json").read_text(encoding="utf-8"))
    out: set[str] = set()

    def walk(prefix: str, node: dict) -> None:
        for k, v in node.get("properties", {}).items():
            path = f"{prefix}.{k}" if prefix else k
            out.add(path)
            if isinstance(v, dict) and "properties" in v:
                walk(path, v)

    walk("", schema)
    return out


SCHEMA_PATHS = schema_paths()

vendor_packs = {}
for mp in sorted((ROOT / "vendors").glob("*/mapping.yaml")):
    vendor_packs[mp.parent.name] = load(mp)

# ── Validate ─────────────────────────────────────────────────────────────────
for fid, f in frameworks.items():
    for key in ("name", "status", "url", "verification"):
        if not f.get(key):
            err(f"framework {fid}: missing {key}")
    if f.get("verification") not in VERIFICATION:
        err(f"framework {fid}: bad verification {f.get('verification')}")

for cid, c in controls.items():
    if not CONTROL_RE.match(cid):
        err(f"control {cid}: bad id")
    for key in ("title", "objective", "mappings"):
        if not c.get(key):
            err(f"control {cid}: missing {key}")
    for fw in c.get("mappings", {}):
        if fw not in frameworks:
            err(f"control {cid}: maps to unknown framework {fw}")

for fid in frameworks:
    if not any(fid in c["mappings"] for c in controls.values()):
        err(f"framework {fid}: no control maps to it")

if len(risks) != len(risks_doc["risks"]):
    err("risks.yaml: duplicate risk ids")
for rid, r in risks.items():
    if not RISK_RE.match(rid):
        err(f"risk {rid}: bad id")
    for key in ("title", "category", "severity", "description", "applies_when", "controls", "references", "verification"):
        if key not in r:
            err(f"risk {rid}: missing {key}")
    if r.get("category") not in risks_doc["categories"]:
        err(f"risk {rid}: unknown category {r.get('category')}")
    if r.get("severity") not in SEVERITIES:
        err(f"risk {rid}: bad severity {r.get('severity')}")
    if r.get("verification") not in VERIFICATION:
        err(f"risk {rid}: bad verification {r.get('verification')}")
    for cid in r.get("controls", []):
        if cid not in controls:
            err(f"risk {rid}: unknown control {cid}")
    for fw in r.get("references", {}):
        if fw not in frameworks:
            err(f"risk {rid}: references unknown framework {fw}")
    aw = r.get("applies_when") or {}
    if aw.get("always") is not True:
        conds = aw.get("any")
        if not conds:
            err(f"risk {rid}: applies_when needs always: true or a non-empty any: list")
        for c in conds or []:
            if not isinstance(c, dict) or "path" not in c or "equals" not in c:
                err(f"risk {rid}: condition must have path and equals")
            elif c["path"] not in SCHEMA_PATHS:
                err(f"risk {rid}: condition path {c['path']} is not in the system record schema")

for sid, s in sectors.items():
    for cid in s.get("emphasised_controls", []):
        if cid not in controls:
            err(f"sector {sid}: unknown control {cid}")
    for t in s.get("high_risk_triggers", []):
        if not isinstance(t, dict) or "text" not in t or "jurisdictions" not in t:
            err(f"sector {sid}: trigger must have text and jurisdictions")
        elif t["jurisdictions"] != "all" and not set(t["jurisdictions"]) <= set(COUNTRIES):
            err(f"sector {sid}: trigger lists unknown jurisdiction {t['jurisdictions']}")
    if not any(t.get("jurisdictions") == "all" or c in t.get("jurisdictions", []) for c in COUNTRIES for t in s.get("high_risk_triggers", []) if isinstance(t, dict)):
        err(f"sector {sid}: no triggers")
if set(sectors) != set(SECTORS):
    err(f"sectors.yaml must define exactly {SECTORS}")

seen_ids: dict[str, str] = {}


def check_instrument(jid: str, where: str, inst: dict) -> None:
    iid = inst.get("id", "?")
    if iid in seen_ids:
        err(f"{jid}/{where}: duplicate instrument id {iid} (also in {seen_ids[iid]})")
    seen_ids[iid] = f"{jid}/{where}"
    for key in ("id", "name", "status", "url", "verification", "controls"):
        if key not in inst:
            err(f"{jid}/{where}/{iid}: missing {key}")
    if inst.get("verification") not in VERIFICATION:
        err(f"{jid}/{where}/{iid}: bad verification {inst.get('verification')}")
    if inst.get("status") not in STATUSES:
        err(f"{jid}/{where}/{iid}: bad status {inst.get('status')}")
    if not str(inst.get("url", "")).startswith("https://"):
        err(f"{jid}/{where}/{iid}: url must be https")
    for cid in inst.get("controls", []):
        if cid not in controls:
            err(f"{jid}/{where}/{iid}: unknown control {cid}")


for jid, j in jurisdictions.items():
    for fw in j.get("frameworks", []) + [x for v in j.get("sector_frameworks", {}).values() for x in v]:
        if fw not in frameworks:
            err(f"{jid}: unknown framework {fw}")
    for inh in j.get("inherits", []):
        if inh not in jurisdictions:
            err(f"{jid}: inherits unknown {inh}")
    inst = j.get("instruments", {})
    for g in INSTRUMENT_GROUPS:
        for i in inst.get(g, []):
            check_instrument(jid, g, i)
    for sec, items in inst.get("sectors", {}).items():
        if sec not in SECTORS:
            err(f"{jid}: unknown sector {sec}")
        for i in items:
            check_instrument(jid, f"sectors/{sec}", i)
    if jid != "EU":
        missing = [s for s in SECTORS if not inst.get("sectors", {}).get(s)]
        if missing:
            err(f"{jid}: no instruments for sectors {missing}")

for c in COUNTRIES:
    if c not in jurisdictions:
        err(f"missing jurisdiction file for {c}")

for vid, vp in vendor_packs.items():
    for key in ("vendor", "name", "implements"):
        if key not in vp:
            err(f"vendor {vid}: mapping.yaml missing {key}")
    for item in vp.get("implements", []) + vp.get("gaps", []):
        if item.get("control") not in controls:
            err(f"vendor {vid}: unknown control {item.get('control')}")
    for item in vp.get("implements", []):
        for ref in item.get("terraform", []) + item.get("native", []):
            path = ref.split("#", 1)[0]
            if not (ROOT / "vendors" / vid / path).exists():
                err(f"vendor {vid}: {ref} does not exist")

if errors:
    print("Catalogue validation FAILED:", file=sys.stderr)
    for e in errors:
        print(f"  - {e}", file=sys.stderr)
    sys.exit(1)


# ── Derive ───────────────────────────────────────────────────────────────────
def instruments_for(jid: str, sector: str) -> list[tuple[str, str, dict]]:
    """(source jurisdiction, group, instrument) for a country and sector, incl. inherited layers."""
    out = []
    chain = jurisdictions[jid].get("inherits", []) + [jid]
    for src in chain:
        inst = jurisdictions[src].get("instruments", {})
        for g in INSTRUMENT_GROUPS:
            out += [(src, g, i) for i in inst.get(g, [])]
        out += [(src, f"sector:{sector}", i) for i in inst.get("sectors", {}).get(sector, [])]
    return out


# Standards marked `baseline: true` are the organisation's voluntary baseline and
# apply in every jurisdiction and sector without being listed per country.
BASELINE = [fid for fid, f in frameworks.items() if f.get("baseline")]


def frameworks_for(jid: str, sector: str) -> list[str]:
    j = jurisdictions[jid]
    fws = list(j.get("frameworks", []))
    for src in j.get("inherits", []):
        fws += [f for f in jurisdictions[src].get("frameworks", []) if f not in fws]
    fws += [f for f in j.get("sector_frameworks", {}).get(sector, []) if f not in fws]
    fws += [f for f in BASELINE if f not in fws]
    return fws


def vendor_matrix() -> dict[str, dict[str, str]]:
    m: dict[str, dict[str, str]] = {cid: {} for cid in controls}
    for vid, vp in vendor_packs.items():
        for item in vp.get("implements", []):
            m[item["control"]][vid] = "implements"
        for item in vp.get("gaps", []):
            m[item["control"]].setdefault(vid, "gap")
    return m


VMATRIX = vendor_matrix()
VENDOR_ORDER = sorted(vendor_packs)

GATES = {fid: f["applies_when"] for fid, f in frameworks.items() if f.get("applies_when")}
GATE_LABEL = {
    "apra_regulated": "APRA-regulated entities only",
    "nz_registered_bank": "NZ-incorporated registered banks with liabilities ≥ NZ$10bn only",
    "mas_regulated": "MAS-regulated financial institutions only",
    "critical_infrastructure": "operators of vital importance / critical infrastructure only",
}

catalog_json = {
    "asOf": frameworks_doc.get("asOf"),
    "gates": GATES,
    "baseline": BASELINE,
    "controls": {
        cid: {"title": c["title"], "frameworks": sorted(c["mappings"].keys())} for cid, c in controls.items()
    },
    "risks": {
        rid: {
            "title": r["title"],
            "category": r["category"],
            "severity": r["severity"],
            "controls": r["controls"],
            "always": r["applies_when"].get("always", False) is True,
            "any": [{"path": c["path"].split("."), "equals": c["equals"]} for c in r["applies_when"].get("any", [])],
        }
        for rid, r in risks.items()
    },
    "jurisdictions": {
        jid: {
            "frameworks": [f for f in frameworks_for(jid, "") if f not in BASELINE] if jid != "EU" else j.get("frameworks", []),
            "sector_frameworks": j.get("sector_frameworks", {}),
        }
        for jid, j in jurisdictions.items()
    },
}

STATUS_LABEL = {
    "in-force": "In force", "in-force-phased": "In force (phased)", "phased": "Phased",
    "pending": "Pending — not law", "voluntary": "Voluntary", "none": "No specific rule", "proposed": "Proposed",
}
VER_LABEL = {"primary": "✓ primary", "secondary": "◐ secondary", "unverified": "⚠ unverified"}
GROUP_LABEL = {"horizontal": "AI law and frameworks", "data_protection": "Data protection", "cyber": "Cybersecurity"}


def md_escape(s: str) -> str:
    return str(s).replace("|", "\\|").replace("\n", " ")


def profile(jid: str, sector: str) -> tuple[str, dict, str]:
    j = jurisdictions[jid]
    s = sectors[sector]
    fws = frameworks_for(jid, sector)
    insts = instruments_for(jid, sector)
    binding = [(src, g, i) for src, g, i in insts if i["status"] not in ("pending", "none", "proposed")]
    tracked = [(src, g, i) for src, g, i in insts if i["status"] in ("pending", "proposed")]

    drivers: dict[str, list[str]] = {cid: [] for cid in controls}
    for fw in fws:
        for cid, c in controls.items():
            if fw in c["mappings"]:
                drivers[cid].append(frameworks[fw]["name"].split(" — ")[0].split(" (")[0])
    for _, _, i in binding:
        if i["id"] in frameworks or i["id"].replace("-act", "") in frameworks:
            continue  # already represented by the framework row
        for cid in i["controls"]:
            drivers[cid].append(i["name"].split(" (")[0])
    required = [cid for cid in controls if drivers[cid]]
    emphasised = set(s["emphasised_controls"])

    title = f"{j['name']} — {s['name']}"
    lines = [
        f"# {title}",
        "",
        f"<sub>Generated from `catalog/` by `tools/build.py` · status as of {frameworks_doc['asOf']} · not legal advice.</sub>",
        "",
    ]
    if j.get("notes"):
        lines += [f"> {j['notes'].strip()}", ""]
    lines += ["## Frameworks applied", "", "| Framework | Status | Verification |", "|---|---|---|"]
    for fw in fws:
        f = frameworks[fw]
        note = ""
        if fw in GATES:
            note = f" — {GATE_LABEL.get(GATES[fw]['entity_type'], GATES[fw]['entity_type'])}"
        status = STATUS_LABEL.get(f["status"], f["status"])
        if f.get("baseline"):
            status = "Organisational baseline (voluntary)"
        lines.append(f"| [{md_escape(f['name'])}]({f['url']}){note} | {status} | {VER_LABEL[f['verification']]} |")

    lines += ["", "## Laws, regulations and guidance", ""]
    current = None
    for src, g, i in insts:
        label = GROUP_LABEL.get(g, f"Sector rules: {s['name']}")
        if src != jid:
            label += f" (inherited from {jurisdictions[src]['name']})"
        if label != current:
            lines += ["", f"### {label}", "", "| Instrument | Citation | Status / effective | Drives controls | Source |", "|---|---|---|---|---|"]
            current = label
        eff = STATUS_LABEL.get(i["status"], i["status"]) + (f" · {i['effective']}" if i.get("effective") else "")
        lines.append(
            f"| {md_escape(i['name'])} | {md_escape(i.get('citation', '—'))} | {md_escape(eff)} | "
            f"{', '.join(i['controls'])} | [{VER_LABEL[i['verification']]}]({i['url']}) |"
        )
    if tracked:
        lines += ["", "**Track, but do not yet treat as law:** " + "; ".join(md_escape(i["name"]) for _, _, i in tracked) + "."]

    lines += [
        "",
        "## Typical AI scenarios and high-risk triggers",
        "",
        *[f"- {x}" for x in s["scenarios"]],
        "",
        f"**Pushes a system into a higher risk tier in {j['name']}:**",
        "",
        *[f"- {t['text']}" for t in s["high_risk_triggers"] if t["jurisdictions"] == "all" or jid in t["jurisdictions"]],
        "",
        "## Required controls",
        "",
        "★ = emphasised for this sector (stricter evidence expected).",
        "",
        "| Control | Driven by | " + " | ".join(VENDOR_ORDER) + " |",
        "|---|---|" + "|".join([":-:"] * len(VENDOR_ORDER)) + "|",
    ]
    sym = {"implements": "●", "gap": "○", None: "·"}
    for cid in required:
        c = controls[cid]
        star = " ★" if cid in emphasised else ""
        drv = "; ".join(dict.fromkeys(drivers[cid]))
        cells = " | ".join(sym[VMATRIX[cid].get(v)] for v in VENDOR_ORDER)
        lines.append(f"| **{cid}** {md_escape(c['title'])}{star} | {md_escape(drv)} | {cells} |")
    lines += [
        "",
        "● vendor pack enforces or evidences the control · ○ documented platform gap (handle in process or another layer) · · not applicable",
        "",
        "## Run the MLOps gate for this profile",
        "",
        f"A pre-filled system record is in [`{sector}.system.yaml`]({sector}.system.yaml). Complete it for your system, then:",
        "",
        "```bash",
        f"python3 tools/gate.py profiles/{jid.lower()}/{sector}.system.yaml",
        "```",
        "",
        "Status labels: ✓ primary = checked against the issuer · ◐ secondary = located via a reputable secondary source, re-check the primary text · ⚠ unverified = confirm before relying on it.",
        "",
    ]
    md = "\n".join(lines)

    gated_here = [GATES[fw]["entity_type"] for fw in fws if fw in GATES]
    template = {
        "apiVersion": "aigov/v1",
        "kind": "AISystem",
        "metadata": {"id": f"{jid.lower()}-{sector}-example", "name": f"{title} reference system", "owner": "owner@example.com"},
        "context": {
            "countries": [jid],
            "sector": sector,
            "role": "deployer",
            "public_body": sector == "public",
            "provides_public_service": sector == "public",
            "entity_types": [],
        },
        "system": {
            "purpose": s["scenarios"][0],
            "decision_impact": "assistive",
            "annex_iii_area": None,
            "user_facing": True,
            "generates_synthetic_content": False,
            "agentic": False,
            "irreversible_actions": False,
            "critical_operation": sector in ("fsi", "health", "mining", "energy"),
            "ot_connected": sector == "energy",
            "market_facing": False,
            "fully_automated_decision": False,
            "generative": True,
            "biometric_processing": False,
            "prohibited_practice": False,
            "placed_on_market_before_2026_08_02": False,
            "model": {"vendor": "other", "model_id": "", "hosting_region": ""},
        },
        "governance": {"policy_approved": False, "registered_in_inventory": False, "ai_literacy_training": False,
                       "eu_database_registered": False, "risk_tolerance_defined": False,
                       "critical_infrastructure_designation": "FILL IN: regulatory designation of the asset (SOCI critical asset, OIV, CII, NCCS entity, BES Cyber System) or leave if none",
                       "internal_audit": {"programme": False, "last_audit": "FILL IN: YYYY-MM-DD of last internal audit", "findings_tracked": False}},
        "risk": {"classification": "limited",
                 "impact_assessment": {"completed": False, "method": "FILL IN: e.g. ISO/IEC 42005:2025",
                                       "review_date": "FILL IN: YYYY-MM-DD scheduled review", "interested_parties_identified": False},
                 "dpia": {"completed": False},
                 "fria": {"completed": False}, "biometric_proportionality_assessment": False},
        "data": {"personal_data": True, "special_category": sector == "health", "provenance_documented": False,
                 "lawful_basis": "FILL IN: lawful basis for processing personal data", "cross_border_transfer": False,
                 "transfer_mechanism": "FILL IN: transfer mechanism, or leave if cross_border_transfer is false", "indirect_collection": False},
        "model": {"approved": False},
        "supplier": {"assessed": False, "no_training_on_customer_data": False, "outsourced": False,
                     "material_service_provider": False, "register_entry": False, "regulator_access_assured": False, "ai_bom": False},
        "security": {"local_auth_disabled": False, "least_privilege": False, "private_network": False,
                     "data_residency_region": "FILL IN: processing region", "cmk": False, "short_lived_credentials": False, "tool_allowlist": False,
                     "non_human_identity_pam": False, "egress_allowlist": False, "sandboxed_execution": False, "ot_zone_conduit_model": False,
                     "idp_federated_identity": False},
        "runtime": {"content_filters": False, "prompt_attack_detection": False, "pii_filtering": False,
                    "guardrail_enforced_centrally": False, "output_validation": False},
        "oversight": {"human_in_the_loop": False, "override_and_stop": False, "contest_and_review": False,
                      "per_action_approval": False},
        "transparency": {"ai_disclosure": False, "adm_notice": False, "adverse_decision_explanation": False,
                         "synthetic_content_marking": False, "privacy_policy_adm_disclosure": False,
                         "indirect_collection_notice": False},
        "logging": {"invocation_logging": False, "retention_days": 0, "siem_integrated": False},
        "monitoring": {"drift_and_bias": False, "agent_telemetry": False},
        "testing": {"evaluation_completed": False, "red_team_completed": False, "bias_assessment": False,
                    "independent_bias_audit": False, "independent_validation": False,
                    "threat_model": {"completed": False, "references": []}},
        "lifecycle": {"versioned": False, "promotion_gate": False},
        "incident": {"runbook": False, "notification_matrix": [], "lessons_learned": False},
        "resilience": {"fallback_tested": False, "exit_plan": False, "tolerance_levels_set": False, "backup_capability": False,
                       "secondary_route": False, "last_dr_drill": "FILL IN: YYYY-MM-DD of last failover drill", "rto_minutes": 0, "rpo_minutes": 0},
        "finops": {"budget_defined": False, "monthly_budget_usd": 0, "token_limits_enforced": False, "cost_allocation_tags": [],
                   "model_selection_record": "FILL IN: path to finops/decisions/<workload>.decision.json",
                   "model_selection_date": "FILL IN: YYYY-MM-DD"},
    }
    if jid == "US":
        template["context"]["us_states"] = []
        template["context"]["us_localities"] = []
        template["system"]["tx_prohibited_intent"] = False
    index = {
        "country": jid, "country_name": j["name"], "sector": sector, "sector_name": s["name"],
        "frameworks": fws, "gated": gated_here, "required_controls": required, "emphasised_controls": sorted(emphasised & set(required)),
        "instruments": [
            {"jurisdiction": src, "group": g, **{k: i.get(k) for k in ("id", "name", "citation", "status", "effective", "url", "verification", "controls")}}
            for src, g, i in insts
        ],
        "path": f"profiles/{jid.lower()}/{sector}.md",
    }
    header = [
        "# Pre-filled AI system record — complete every field, then run tools/gate.py.",
        "# Field meanings: mlops/schema/ai-system.schema.json. Notification matrix tokens: APRA:72h, CSIRT-Nacional.",
        "# system.generative defaults to true (GenAI); set false for predictive models so bank model-risk rules (SR 26-2) apply.",
    ]
    if gated_here:
        header.append("# entity_types that switch on gated frameworks here: " + ", ".join(gated_here))
    if jid == "US":
        header.append("# us_states: list every state where affected people are; us_localities: e.g. NYC.")
    tmpl = "\n".join(header) + "\n" + yaml.safe_dump(template, sort_keys=False, allow_unicode=True)
    return md, index, tmpl


def crosswalk() -> str:
    fw_ids = list(frameworks)
    lines = [
        "# Control crosswalk",
        "",
        f"<sub>Generated by `tools/build.py` from `catalog/controls.yaml` · as of {frameworks_doc['asOf']}.</sub>",
        "",
        "| Control | " + " | ".join(fw_ids) + " |",
        "|---|" + "|".join([":-:"] * len(fw_ids)) + "|",
    ]
    for cid, c in controls.items():
        lines.append(f"| **{cid}** {c['title']} | " + " | ".join("●" if fw in c["mappings"] else "" for fw in fw_ids) + " |")
    lines += ["", "## Clause references", ""]
    for cid, c in controls.items():
        lines += [f"### {cid} — {c['title']}", "", c["objective"], ""]
        for fw, refs in c["mappings"].items():
            lines.append(f"- **{frameworks[fw]['name']}**: " + "; ".join(refs))
        impl = [v for v, k in VMATRIX[cid].items() if k == "implements"]
        if impl:
            lines.append(f"- **Vendor packs:** {', '.join(sorted(impl))}")
        lines.append("")
    return "\n".join(lines)


def risk_condition(r: dict) -> str:
    aw = r["applies_when"]
    if aw.get("always") is True:
        return "every system"
    return " or ".join(f"`{c['path']}: {json.dumps(c['equals'])}`" for c in aw["any"])


def risks_md() -> str:
    lines = [
        "# AI risk catalogue",
        "",
        f"<sub>Generated by `tools/build.py` from `catalog/risks.yaml` · as of {frameworks_doc['asOf']}.</sub>",
        "",
        f"{len(risks)} risks in {len(risks_doc['categories'])} categories. A risk applies to a system when any of its conditions holds on the system record; "
        "the gate decision lists the applicable risks (`decision.risks`) and `tools/report.py` shows them with the controls that treat them.",
        "",
        "| Risk | Category | Severity | Applies when | Treated by |",
        "|---|---|:-:|---|---|",
    ]
    for rid, r in risks.items():
        lines.append(f"| **{rid}** {md_escape(r['title'])} | {r['category']} | {r['severity']} | {md_escape(risk_condition(r))} | {', '.join(r['controls'])} |")
    lines += ["", "## Categories", ""]
    for cat, desc in risks_doc["categories"].items():
        lines.append(f"- **{cat}** — {desc}")
    lines += ["", "## Risk detail", ""]
    for rid, r in risks.items():
        lines += [f"### {rid} — {r['title']}", "", r["description"], "",
                  f"- **Category:** {r['category']} · **Severity:** {r['severity']} · **Verification:** {r['verification']}",
                  f"- **Applies when:** {risk_condition(r)}",
                  "- **Controls:** " + ", ".join(f"{cid} {controls[cid]['title']}" for cid in r["controls"])]
        for fw, refs in r["references"].items():
            lines.append(f"- **{frameworks[fw]['name']}:** " + "; ".join(refs))
        lines.append("")
    return "\n".join(lines)


outputs: dict[Path, str] = {}
outputs[ROOT / "docs/RISKS.md"] = risks_md()
outputs[ROOT / "mlops/data/catalog.json"] = json.dumps({"aigov_catalog": catalog_json}, indent=2, ensure_ascii=False) + "\n"
index = []
for jid in COUNTRIES:
    for sector in SECTORS:
        md, idx, tmpl = profile(jid, sector)
        outputs[ROOT / f"profiles/{jid.lower()}/{sector}.md"] = md
        outputs[ROOT / f"profiles/{jid.lower()}/{sector}.system.yaml"] = tmpl
        index.append(idx)
outputs[ROOT / "profiles/index.json"] = json.dumps(index, indent=2, ensure_ascii=False) + "\n"
outputs[ROOT / "docs/CROSSWALK.md"] = crosswalk()
site = {
    "asOf": frameworks_doc.get("asOf"),
    "frameworks": frameworks_doc["frameworks"],
    "baseline": BASELINE,
    "controls": controls_doc["controls"],
    "risks": risks_doc["risks"],
    "risk_categories": risks_doc["categories"],
    "sectors": sectors_doc["sectors"],
    "vendors": {vid: {k: vp.get(k) for k in ("name", "native_tools", "attestations", "implements", "gaps")} for vid, vp in vendor_packs.items()},
    "profiles": index,
}
outputs[ROOT / "site/data/catalog.json"] = json.dumps(site, ensure_ascii=False) + "\n"

ap = argparse.ArgumentParser()
ap.add_argument("--check", action="store_true", help="fail if generated files are out of date")
args = ap.parse_args()

stale = []
for path, content in outputs.items():
    if args.check:
        if not path.exists() or path.read_text(encoding="utf-8") != content:
            stale.append(path.relative_to(ROOT))
    else:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")

if stale:
    print("Generated files are stale — run `python3 tools/build.py` and commit:", file=sys.stderr)
    for p in stale[:20]:
        print(f"  - {p}", file=sys.stderr)
    sys.exit(1)

print(f"Catalogue OK: {len(frameworks)} frameworks, {len(controls)} controls, {len(risks)} risks, {len(jurisdictions)} jurisdictions, "
      f"{len(vendor_packs)} vendor packs, {len(index)} profiles{' (up to date)' if args.check else ' generated'}.")
