"""Read-only data layer shared by api/server.py and mcp/server.py.

Everything comes from files in this repository: the catalogue (catalog/),
generated profiles (profiles/index.json), vendor packs (vendors/*/mapping.yaml),
system records (systems/*.yaml), incidents (incidents/) and the gate
(tools/gate.py, which needs `opa`). Nothing here writes.
"""
from __future__ import annotations

import glob
import json
import sys
from functools import lru_cache
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))
import gate  # noqa: E402
import inventory  # noqa: E402


def _yaml(p: Path):
    return yaml.safe_load(p.read_text(encoding="utf-8"))


@lru_cache(maxsize=1)
def catalogue() -> dict:
    fw = _yaml(ROOT / "catalog/frameworks.yaml")
    ct = _yaml(ROOT / "catalog/controls.yaml")
    rk = _yaml(ROOT / "catalog/risks.yaml")
    sc = _yaml(ROOT / "catalog/sectors.yaml")
    vendors = {mp.parent.name: _yaml(mp) for mp in sorted((ROOT / "vendors").glob("*/mapping.yaml"))}
    jur = {p.stem.upper(): _yaml(p) for p in sorted((ROOT / "catalog/jurisdictions").glob("*.yaml"))}
    return {
        "asOf": fw.get("asOf"),
        "version": (ROOT / "VERSION").read_text().strip() if (ROOT / "VERSION").exists() else "dev",
        "frameworks": {f["id"]: f for f in fw["frameworks"]},
        "controls": {c["id"]: c for c in ct["controls"]},
        "risks": {r["id"]: r for r in rk["risks"]},
        "risk_categories": rk["categories"],
        "sectors": {s["id"]: s for s in sc["sectors"]},
        "jurisdictions": jur,
        "vendors": vendors,
        "profiles": json.loads((ROOT / "profiles/index.json").read_text(encoding="utf-8")),
    }


def summary() -> dict:
    c = catalogue()
    return {
        "name": "AI Governance Compliance as Code",
        "version": c["version"],
        "catalogue_as_of": c["asOf"],
        "licence": "Apache-2.0",
        "edition": "open-source",
        "counts": {k: len(c[k]) for k in ("frameworks", "controls", "risks", "sectors", "jurisdictions", "vendors", "profiles")},
        "commercial_edition": "NexGuide.AI GovMap — evidence database, approvals, PDF audit packs, hosted API (docs/EDITIONS.md)",
    }


def frameworks(baseline_only: bool = False, jurisdiction: str | None = None) -> list[dict]:
    c = catalogue()
    out = list(c["frameworks"].values())
    if baseline_only:
        out = [f for f in out if f.get("baseline")]
    if jurisdiction:
        ids = set(frameworks_for(jurisdiction))
        out = [f for f in out if f["id"] in ids]
    return out


def frameworks_for(jurisdiction: str, sector: str | None = None) -> list[str]:
    c = catalogue()
    j = c["jurisdictions"].get(jurisdiction.upper(), {})
    ids = list(j.get("frameworks", []))
    if sector:
        ids += j.get("sector_frameworks", {}).get(sector, [])
    ids += [f["id"] for f in c["frameworks"].values() if f.get("baseline")]
    seen, out = set(), []
    for i in ids:
        if i not in seen:
            seen.add(i)
            out.append(i)
    return out


def control(cid: str) -> dict | None:
    c = catalogue()
    ctl = c["controls"].get(cid.upper())
    if not ctl:
        return None
    impl = [vid for vid, vp in c["vendors"].items() if _implements(vp, cid.upper())]
    risks = [rid for rid, r in c["risks"].items() if cid.upper() in r["controls"]]
    return {**ctl, "implemented_by": impl, "treats_risks": risks}


def _implements(vp: dict, cid: str) -> bool:
    impl = vp.get("implements") or {}
    if isinstance(impl, dict):
        return cid in impl
    return any((i.get("control") if isinstance(i, dict) else i) == cid for i in impl)


def risk(rid: str) -> dict | None:
    return catalogue()["risks"].get(rid.upper())


def profile(country: str, sector: str) -> dict | None:
    for p in catalogue()["profiles"]:
        if p.get("jurisdiction", "").upper() == country.upper() and p.get("sector") == sector:
            md = ROOT / f"profiles/{country.lower()}/{sector}.md"
            tmpl = ROOT / f"profiles/{country.lower()}/{sector}.system.yaml"
            return {**p, "markdown": md.read_text(encoding="utf-8") if md.exists() else None,
                    "system_template": tmpl.read_text(encoding="utf-8") if tmpl.exists() else None}
    return None


def vendor(vid: str) -> dict | None:
    return catalogue()["vendors"].get(vid)


def systems(pattern: str = "systems/*.yaml", run_gate: bool = False) -> list[dict]:
    return inventory.build_inventory(pattern, run_gate=run_gate)


def system(sid: str, pattern: str = "systems/*.yaml", evaluate: bool = True) -> dict | None:
    for f in sorted(glob.glob(str(ROOT / pattern))):
        doc = gate.load_record(Path(f))
        if isinstance(doc, dict) and doc.get("metadata", {}).get("id") == sid:
            out = {"file": str(Path(f).relative_to(ROOT)), "record": doc}
            if evaluate:
                out["decision"] = gate.evaluate(doc)
            return out
    return None


def evaluate(record: dict, date: str | None = None) -> dict:
    problems = gate.validate_schema(record, Path("<request>"))
    if problems:
        return {"schema_errors": problems}
    return gate.evaluate(record, date)


def incidents(system_id: str | None = None, open_only: bool = False) -> list[dict]:
    out = []
    for p in sorted((ROOT / "incidents").glob("INC-*.yaml")) if (ROOT / "incidents").exists() else []:
        inc = _yaml(p) or {}
        if system_id and inc.get("system") != system_id:
            continue
        if open_only and inc.get("status", "open") != "open":
            continue
        out.append(inc)
    return out


def crosswalk(cid: str | None = None, framework: str | None = None) -> list[dict]:
    c = catalogue()
    rows = []
    for id_, ctl in c["controls"].items():
        if cid and id_ != cid.upper():
            continue
        for fw, refs in ctl["mappings"].items():
            if framework and fw != framework:
                continue
            rows.append({"control": id_, "title": ctl["title"], "framework": fw, "framework_name": c["frameworks"][fw]["name"], "clauses": refs})
    return rows
