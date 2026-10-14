#!/usr/bin/env python3
"""AI system inventory from systems/*.yaml.

    python3 tools/inventory.py                       # print the register
    python3 tools/inventory.py --out-dir docs        # INVENTORY.md, inventory.csv, inventory.json
    python3 tools/inventory.py --systems "ai/*.yaml" --no-gate

For every record: owner, countries, sector, role, risk classification, model
vendor, whether it is agentic / user-facing / consequential, the gate result
(allow/deny, finding counts), evidence status, applicable risks, open
incidents, and the next review date. Importable: `build_inventory()`.
"""
from __future__ import annotations

import argparse
import csv
import datetime as dt
import glob
import io
import json
import os
import sys
from pathlib import Path

import yaml

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gate  # noqa: E402

ROOT = gate.ROOT
INCIDENTS = ROOT / "incidents"


def open_incidents() -> dict[str, list[dict]]:
    out: dict[str, list[dict]] = {}
    if not INCIDENTS.exists():
        return out
    for p in sorted(INCIDENTS.glob("*.yaml")):
        inc = yaml.safe_load(p.read_text(encoding="utf-8")) or {}
        if inc.get("status", "open") == "open":
            out.setdefault(inc.get("system", "unknown"), []).append({"id": inc.get("id", p.stem), "severity": inc.get("severity", "medium"), "title": inc.get("title", "")})
    return out


def next_review(doc: dict) -> tuple[str, str] | None:
    """Earliest upcoming review from the record: impact-assessment review, audit anniversary, DR drill anniversary."""
    cands = []
    rd = (doc.get("risk", {}).get("impact_assessment") or {}).get("review_date")
    if rd:
        cands.append((str(rd), "impact assessment review"))
    la = (doc.get("governance", {}).get("internal_audit") or {}).get("last_audit")
    if la:
        cands.append(((dt.date.fromisoformat(str(la)) + dt.timedelta(days=365)).isoformat(), "internal audit"))
    dr = (doc.get("resilience") or {}).get("last_dr_drill")
    if dr:
        cands.append(((dt.date.fromisoformat(str(dr)) + dt.timedelta(days=365)).isoformat(), "DR drill"))
    return min(cands) if cands else None


def build_inventory(pattern: str = "systems/*.yaml", run_gate: bool = True, date: str | None = None) -> list[dict]:
    rows = []
    incidents = open_incidents()
    for f in sorted(glob.glob(str(ROOT / pattern) if not os.path.isabs(pattern) else pattern)):
        path = Path(f)
        doc = gate.load_record(path)
        if not isinstance(doc, dict) or doc.get("kind") != "AISystem":
            continue
        sysd, ctx, meta = doc.get("system", {}), doc.get("context", {}), doc.get("metadata", {})
        row = {
            "id": meta.get("id", path.stem),
            "name": meta.get("name", ""),
            "owner": meta.get("owner", ""),
            "business_unit": meta.get("business_unit", ""),
            "file": str(path.relative_to(ROOT)) if path.is_relative_to(ROOT) else str(path),
            "countries": ",".join(ctx.get("countries", [])),
            "sector": ctx.get("sector", ""),
            "role": ctx.get("role", ""),
            "entity_types": ",".join(ctx.get("entity_types", [])),
            "classification": (doc.get("risk") or {}).get("classification", ""),
            "decision_impact": sysd.get("decision_impact", ""),
            "vendor": (sysd.get("model") or {}).get("vendor", ""),
            "model_id": (sysd.get("model") or {}).get("model_id", ""),
            "region": (sysd.get("model") or {}).get("hosting_region", "") or (doc.get("security") or {}).get("data_residency_region", ""),
            "agentic": bool(sysd.get("agentic")),
            "user_facing": bool(sysd.get("user_facing")),
            "personal_data": bool((doc.get("data") or {}).get("personal_data")),
            "critical_operation": bool(sysd.get("critical_operation")),
            "schema_errors": len(gate.validate_schema(doc, path)),
            "gate": "", "deny": 0, "warn": 0, "frameworks": "", "risks": "", "evidence_fresh": 0, "evidence_stale": 0, "evidence_missing": 0,
            "open_incidents": len(incidents.get(meta.get("id", ""), [])),
            "highest_open_incident": max((i["severity"] for i in incidents.get(meta.get("id", ""), [])), default=""),
        }
        nr = next_review(doc)
        row["next_review"] = nr[0] if nr else ""
        row["next_review_what"] = nr[1] if nr else ""
        if run_gate and row["schema_errors"] == 0:
            d = gate.evaluate(doc, date)
            ev = d.get("evidence", {})
            row.update({
                "gate": "allow" if d["allow"] else "deny",
                "deny": len(d["deny"]), "warn": len(d["warn"]),
                "frameworks": ",".join(d["frameworks"]),
                "risks": ",".join(d.get("risks", [])),
                "evidence_fresh": sum(1 for v in ev.values() if v == "fresh"),
                "evidence_stale": sum(1 for v in ev.values() if v == "stale"),
                "evidence_missing": sum(1 for v in ev.values() if v == "missing"),
            })
        elif row["schema_errors"]:
            row["gate"] = "invalid"
        rows.append(row)
    return rows


def to_markdown(rows: list[dict], as_of: str) -> str:
    n_allow = sum(1 for r in rows if r["gate"] == "allow")
    n_deny = sum(1 for r in rows if r["gate"] == "deny")
    n_inc = sum(r["open_incidents"] for r in rows)
    lines = [
        "# AI system inventory",
        "",
        f"<sub>Generated by `tools/inventory.py` from `systems/*.yaml` on {as_of}. Register of record: this directory, in git.</sub>",
        "",
        f"**{len(rows)} systems** · {n_allow} allow · {n_deny} deny · {sum(1 for r in rows if r['agentic'])} agentic · "
        f"{sum(1 for r in rows if r['personal_data'])} processing personal data · {n_inc} open incidents",
        "",
        "| System | Owner | Where | Class | Impact | Model | Gate | Evidence | Risks | Incidents | Next review |",
        "|---|---|---|---|---|---|---|---|---|---|---|",
    ]
    for r in rows:
        flags = " ".join(x for x, on in (("agent", r["agentic"]), ("user-facing", r["user_facing"]), ("critical", r["critical_operation"])) if on)
        gate_cell = {"allow": "✅ allow", "deny": f"❌ deny ({r['deny']})", "invalid": "⚠️ invalid record", "": "—"}[r["gate"]]
        if r["gate"] == "allow" and r["warn"]:
            gate_cell += f" ({r['warn']} warn)"
        ev = f"{r['evidence_fresh']} fresh / {r['evidence_stale']} stale / {r['evidence_missing']} missing" if (r["evidence_fresh"] + r["evidence_stale"] + r["evidence_missing"]) else "no evidence block"
        inc = f"{r['open_incidents']} ({r['highest_open_incident']})" if r["open_incidents"] else "0"
        nxt = f"{r['next_review']} ({r['next_review_what']})" if r["next_review"] else "—"
        lines.append(f"| [{r['id']}]({'../' + r['file'] if not r['file'].startswith('/') else r['file']})<br><sub>{r['name']} {flags}</sub> | {r['owner']} | {r['countries']} / {r['sector']} / {r['role']} | {r['classification']} | {r['decision_impact']} | {r['vendor']} {r['model_id']} | {gate_cell} | {ev} | {len(r['risks'].split(',')) if r['risks'] else 0} | {inc} | {nxt} |")
    lines += ["", "Columns: **Gate** is the MLOps gate decision for the record as committed; **Evidence** counts required controls by evidence status; "
              "**Risks** is the number of catalogue risks that apply (`docs/RISKS.md`); **Incidents** are open records in `incidents/`.",
              "",
              "<sub>This register is free and open source. Ownership views, search across hundreds of systems, approval workflows and platform imports (Foundry, Bedrock, Copilot Studio) are part of the NexGuide.AI GovMap edition — see docs/EDITIONS.md.</sub>"]
    return "\n".join(lines) + "\n"


def to_csv(rows: list[dict]) -> str:
    buf = io.StringIO()
    if rows:
        w = csv.DictWriter(buf, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)
    return buf.getvalue()


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--systems", default="systems/*.yaml", help="glob of records (default systems/*.yaml)")
    ap.add_argument("--out-dir", type=Path, help="write INVENTORY.md, inventory.csv and inventory.json here")
    ap.add_argument("--no-gate", action="store_true", help="skip the gate (no opa needed)")
    ap.add_argument("--date", help="evaluate the gate as of this date")
    ap.add_argument("--summary", action="store_true", help="append the Markdown to GITHUB_STEP_SUMMARY")
    args = ap.parse_args()

    rows = build_inventory(args.systems, run_gate=not args.no_gate, date=args.date)
    as_of = args.date or dt.date.today().isoformat()
    md = to_markdown(rows, as_of)
    print(md)
    if args.out_dir:
        args.out_dir.mkdir(parents=True, exist_ok=True)
        (args.out_dir / "INVENTORY.md").write_text(md, encoding="utf-8")
        (args.out_dir / "inventory.csv").write_text(to_csv(rows), encoding="utf-8")
        (args.out_dir / "inventory.json").write_text(json.dumps({"as_of": as_of, "systems": rows}, indent=2), encoding="utf-8")
    if args.summary and os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as fh:
            fh.write(md)
    return 0


if __name__ == "__main__":
    sys.exit(main())
