#!/usr/bin/env python3
"""Audit pack per AI system, in Markdown.

    python3 tools/report.py systems/*.yaml                      # print
    python3 tools/report.py --out-dir build/reports systems/*.yaml
    python3 tools/report.py --date 2027-12-02 systems/x.yaml    # as-of a future date

Each pack has: the gate decision and applicable frameworks; every required
control with its status, the frameworks and clauses that demand it, the
vendor packs that implement it and the evidence on file; the risks that apply
and the controls treating them; open and recent incidents; and the review
calendar. Markdown only in this edition — the NexGuide.AI GovMap edition
renders the same pack as a signed PDF with the evidence attached.
"""
from __future__ import annotations

import argparse
import datetime as dt
import sys
from pathlib import Path

import yaml

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gate  # noqa: E402
from reviews import due_items  # noqa: E402

ROOT = gate.ROOT
VERSION = (ROOT / "VERSION").read_text().strip() if (ROOT / "VERSION").exists() else "dev"


def load_catalogue() -> dict:
    cat = {
        "frameworks": {f["id"]: f for f in yaml.safe_load((ROOT / "catalog/frameworks.yaml").read_text(encoding="utf-8"))["frameworks"]},
        "controls": {c["id"]: c for c in yaml.safe_load((ROOT / "catalog/controls.yaml").read_text(encoding="utf-8"))["controls"]},
        "risks": {r["id"]: r for r in yaml.safe_load((ROOT / "catalog/risks.yaml").read_text(encoding="utf-8"))["risks"]},
        "vendors": {},
    }
    for mp in sorted((ROOT / "vendors").glob("*/mapping.yaml")):
        cat["vendors"][mp.parent.name] = yaml.safe_load(mp.read_text(encoding="utf-8")) or {}
    return cat


def implementers(cat: dict, cid: str) -> list[str]:
    out = []
    for vid, vp in cat["vendors"].items():
        impl = vp.get("implements") or {}
        if isinstance(impl, dict) and cid in impl:
            out.append(vid)
        elif isinstance(impl, list) and any((i.get("control") if isinstance(i, dict) else i) == cid for i in impl):
            out.append(vid)
    return out


def incidents_for(system_id: str) -> list[dict]:
    out = []
    for p in sorted((ROOT / "incidents").glob("INC-*.yaml")) if (ROOT / "incidents").exists() else []:
        inc = yaml.safe_load(p.read_text(encoding="utf-8")) or {}
        if inc.get("system") == system_id:
            out.append(inc)
    return out


def pack(path: Path, doc: dict, d: dict, cat: dict, as_of: str) -> str:
    meta, ctx = doc["metadata"], doc.get("context", {})
    fws = d["frameworks"]
    by_control: dict[str, list[dict]] = {}
    for f in d["deny"] + d["warn"]:
        by_control.setdefault(f["control"], []).append(f)
    ev_items: dict[str, list[dict]] = {}
    for it in (doc.get("evidence") or {}).get("items", []):
        ev_items.setdefault(it["control"], []).append(it)
    ev_status = d.get("evidence", {})
    vendor = (doc.get("system", {}).get("model") or {}).get("vendor")

    L = [f"# Audit pack — {meta.get('name', meta['id'])}", "",
         f"| | |", "|---|---|",
         f"| System id | `{meta['id']}` |",
         f"| Record | `{path}` |",
         f"| Owner | {meta.get('owner', '—')} · {meta.get('business_unit', '')} |",
         f"| Scope | countries {', '.join(ctx.get('countries', []))} · sector {ctx.get('sector', '—')} · role {ctx.get('role', '—')} · entity types {', '.join(ctx.get('entity_types', [])) or '—'} |",
         f"| Model | {vendor or '—'} {(doc.get('system', {}).get('model') or {}).get('model_id', '')} in {(doc.get('system', {}).get('model') or {}).get('hosting_region', '—')} |",
         f"| Classification | {(doc.get('risk') or {}).get('classification', '—')} · decision impact {doc.get('system', {}).get('decision_impact', '—')} · "
         f"{'agentic' if doc.get('system', {}).get('agentic') else 'not agentic'} · {'user-facing' if doc.get('system', {}).get('user_facing') else 'internal'} |",
         f"| Evaluated | {d['evaluation_date']} with catalogue as of {as_of} (AI Governance Compliance as Code v{VERSION}) |",
         f"| **Decision** | **{'ALLOW' if d['allow'] else 'DENY'}** — {len(d['deny'])} blocking, {len(d['warn'])} warnings |",
         "",
         "## 1. Applicable frameworks", "",
         "| Framework | Type | Status | Verification |", "|---|---|---|---|"]
    for fw in fws:
        f = cat["frameworks"].get(fw, {})
        L.append(f"| [{f.get('name', fw)}]({f.get('url', '')}) | {f.get('type', '')} | {f.get('status', '')} | {f.get('verification', '')} |")
    L += ["", "## 2. Findings", ""]
    if not d["deny"] and not d["warn"]:
        L.append("No findings.")
    for sev, items in (("deny", d["deny"]), ("warn", d["warn"])):
        for f in items:
            L.append(f"- {'❌' if sev == 'deny' else '⚠️'} **{f['control']}** [{', '.join(f['frameworks'])}] {f['message']}")
    L += ["", "## 3. Required controls, status and evidence", "",
          "| Control | Status | Evidence | Required by | Implemented natively by |", "|---|---|---|---|---|"]
    for cid in d["required_controls"]:
        c = cat["controls"][cid]
        fnd = by_control.get(cid, [])
        status = "❌ deny" if any(f["severity"] == "deny" for f in fnd) else ("⚠️ warn" if fnd else "✅ met")
        st = ev_status.get(cid)
        evs = ev_items.get(cid, [])
        ev_cell = ("—" if st is None and not evs else
                   f"{ {'fresh': '✅', 'stale': '⏰', 'missing': '∅'}.get(st, '')} " + "; ".join(f"{e.get('type', '')} {e.get('ref', '')} ({e.get('date', '')})" for e in evs) if evs else "∅ none on file")
        req = [fw for fw in c["mappings"] if fw in fws]
        impl = implementers(cat, cid)
        L.append(f"| **{cid}** {c['title']} | {status} | {ev_cell} | {', '.join(req)} | {', '.join(impl) or '—'}{' ← in use' if vendor in impl else ''} |")
    L += ["", "### Clause references for the required controls", ""]
    for cid in d["required_controls"]:
        c = cat["controls"][cid]
        refs = [f"{cat['frameworks'][fw]['name']}: {'; '.join(cl)}" for fw, cl in c["mappings"].items() if fw in fws]
        L.append(f"- **{cid}** — " + " · ".join(refs))
    L += ["", "## 4. Risks that apply and how they are treated", "",
          "| Risk | Category | Severity | Treated by | Treatment status |", "|---|---|:-:|---|---|"]
    for rid in d.get("risks", []):
        r = cat["risks"][rid]
        treat = [f"{cid} {'❌' if any(f['severity'] == 'deny' for f in by_control.get(cid, [])) else '⚠️' if by_control.get(cid) else '✅'}" for cid in r["controls"]]
        worst = "open" if any(f["severity"] == "deny" for cid in r["controls"] for f in by_control.get(cid, [])) else "treated"
        L.append(f"| **{rid}** {r['title']} | {r['category']} | {r['severity']} | {', '.join(treat)} | {worst} |")
    incs = incidents_for(meta["id"])
    L += ["", "## 5. Incidents", ""]
    if not incs:
        L.append("No incident records for this system.")
    else:
        L += ["| Id | Status | Severity | Type | Occurred | Title |", "|---|---|---|---|---|---|"]
        for i in incs:
            L.append(f"| {i.get('id')} | {i.get('status', 'open')} | {i.get('severity', '')} | {i.get('event_type', '')} | {i.get('occurred', '')} | {i.get('title', '')} |")
    today = dt.date.fromisoformat(d["evaluation_date"])
    due = due_items(doc, today, today + dt.timedelta(days=3650))
    L += ["", "## 6. Review calendar", ""]
    if due:
        L += ["| Due | What | Detail |", "|---|---|---|"]
        for day, kind, detail in due[:40]:
            L.append(f"| {day.isoformat()}{' **(overdue)**' if day < today else ''} | {kind} | {detail} |")
    else:
        L.append("No dated reviews in the record.")
    L += ["", "---", "",
          f"<sub>Generated by `tools/report.py` on {dt.date.today().isoformat()} from the record, the catalogue (`catalog/`, verified as of {as_of}) and `incidents/`. "
          "Every catalogue fact carries a verification label; check primary sources before reliance. Not legal advice. "
          "This Markdown pack is free and open source; a signed PDF audit pack with evidence attachments, approver sign-off and a tamper-evident evidence vault is available in the NexGuide.AI GovMap edition (docs/EDITIONS.md).</sub>"]
    return "\n".join(L) + "\n"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("files", nargs="+", type=Path)
    ap.add_argument("--out-dir", type=Path)
    ap.add_argument("--date", help="evaluate as of this date (YYYY-MM-DD)")
    ap.add_argument("--format", choices=["md"], default="md", help="md only in this edition (PDF: NexGuide.AI GovMap)")
    args = ap.parse_args()
    cat = load_catalogue()
    as_of = str(yaml.safe_load((ROOT / "catalog/frameworks.yaml").read_text(encoding="utf-8"))["asOf"])
    rc = 0
    for path in args.files:
        doc = gate.load_record(path)
        problems = gate.validate_schema(doc, path)
        if problems:
            print("\n".join(problems), file=sys.stderr)
            rc = 1
            continue
        d = gate.evaluate(doc, args.date)
        text = pack(path, doc, d, cat, as_of)
        if args.out_dir:
            args.out_dir.mkdir(parents=True, exist_ok=True)
            out = args.out_dir / f"{doc['metadata']['id']}.md"
            out.write_text(text, encoding="utf-8")
            print(f"{out} ({'ALLOW' if d['allow'] else 'DENY'})")
        else:
            print(text)
    return rc


if __name__ == "__main__":
    sys.exit(main())
