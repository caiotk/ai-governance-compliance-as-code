#!/usr/bin/env python3
"""Reviews falling due: evidence expiry, impact-assessment review dates, annual
internal audits, annual DR drills and open high-severity incidents.

    python3 tools/reviews.py --days 30                 # print what is due
    python3 tools/reviews.py --days 30 --out-dir build/reviews   # one Markdown file per system (for issues)

Exit code 0 always; the count of systems with items due is written to
GITHUB_OUTPUT as `systems=` when running in Actions.
"""
from __future__ import annotations

import argparse
import datetime as dt
import glob
import os
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
AUDIT_CYCLE_DAYS = 365      # ISO 19011 sets no cadence; this repository's baseline is annual
DR_DRILL_CYCLE_DAYS = 365   # CPS 230 para 43 and SP 800-34: at least annually


def due_items(doc: dict, today: dt.date, horizon: dt.date) -> list[tuple[dt.date, str, str]]:
    """(date, kind, detail) for every item due on or before the horizon (including overdue)."""
    items: list[tuple[dt.date, str, str]] = []

    def add(d: str | None, kind: str, detail: str) -> None:
        if not d:
            return
        day = dt.date.fromisoformat(str(d))
        if day <= horizon:
            items.append((day, kind, detail))

    ia = (doc.get("risk") or {}).get("impact_assessment") or {}
    add(ia.get("review_date"), "Impact assessment review", f"method: {ia.get('method', '—')}")
    au = (doc.get("governance") or {}).get("internal_audit") or {}
    if au.get("last_audit"):
        add((dt.date.fromisoformat(str(au["last_audit"])) + dt.timedelta(days=AUDIT_CYCLE_DAYS)).isoformat(), "Internal audit", f"last audit {au['last_audit']} (AIG-21, ISO 19011 programme cycle {AUDIT_CYCLE_DAYS} days)")
    res = doc.get("resilience") or {}
    if res.get("last_dr_drill"):
        add((dt.date.fromisoformat(str(res["last_dr_drill"])) + dt.timedelta(days=DR_DRILL_CYCLE_DAYS)).isoformat(), "DR drill", f"last drill {res['last_dr_drill']} (AIG-17)")
    fin = doc.get("finops") or {}
    if fin.get("model_selection_date"):
        add((dt.date.fromisoformat(str(fin["model_selection_date"])) + dt.timedelta(days=90)).isoformat(), "Model selection refresh", f"last run {fin['model_selection_date']} (AIG-22; catalogue prices change monthly)")
    ev = doc.get("evidence") or {}
    default_days = int(ev.get("default_valid_days", 365))
    for it in ev.get("items", []):
        exp = dt.date.fromisoformat(str(it["date"])) + dt.timedelta(days=int(it.get("valid_days", default_days)))
        add(exp.isoformat(), f"Evidence {it['control']}", f"{it.get('type', '')} {it.get('ref', '')} (reviewed {it['date']})")
    return sorted(items)


def open_high_incidents(system_id: str) -> list[dict]:
    out = []
    for p in sorted((ROOT / "incidents").glob("*.yaml")) if (ROOT / "incidents").exists() else []:
        inc = yaml.safe_load(p.read_text(encoding="utf-8")) or {}
        if inc.get("system") == system_id and inc.get("status", "open") == "open" and inc.get("severity") in ("high", "critical"):
            out.append(inc)
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--days", type=int, default=30)
    ap.add_argument("--systems", default="systems/*.yaml")
    ap.add_argument("--today", help="override today's date (YYYY-MM-DD)")
    ap.add_argument("--out-dir", type=Path, help="write one Markdown file per system with items due")
    ap.add_argument("--summary", action="store_true")
    args = ap.parse_args()

    today = dt.date.fromisoformat(args.today) if args.today else dt.date.today()
    horizon = today + dt.timedelta(days=args.days)
    report = [f"## Governance reviews due by {horizon.isoformat()}", ""]
    n = 0
    if args.out_dir:
        args.out_dir.mkdir(parents=True, exist_ok=True)
        for old in args.out_dir.glob("*.md"):
            old.unlink()
    for f in sorted(glob.glob(str(ROOT / args.systems))):
        doc = yaml.safe_load(Path(f).read_text(encoding="utf-8")) or {}
        if doc.get("kind") != "AISystem":
            continue
        sid = doc["metadata"]["id"]
        items = due_items(doc, today, horizon)
        incs = open_high_incidents(sid)
        if not items and not incs:
            continue
        n += 1
        lines = [f"### {sid} — {doc['metadata'].get('name', '')}", "",
                 f"Owner: {doc['metadata'].get('owner', '—')} · record: `{Path(f).relative_to(ROOT)}`", ""]
        if items:
            lines += ["| Due | Days | What | Detail |", "|---|--:|---|---|"]
            for day, kind, detail in items:
                delta = (day - today).days
                lines.append(f"| {day.isoformat()} | {delta if delta >= 0 else f'**{delta} (overdue)**'} | {kind} | {detail} |")
        if incs:
            lines += ["", "**Open high-severity incidents:**"] + [f"- `{i.get('id')}` {i.get('title', '')} (since {i.get('opened', '?')})" for i in incs]
        lines += ["", "Close this issue by updating the record (new review date, audit, drill or evidence date) in a pull request; the gate will re-evaluate it.",
                  "", "<sub>Opened by the review-reminders workflow from systems/*.yaml and incidents/.</sub>"]
        text = "\n".join(lines) + "\n"
        report.append(text)
        if args.out_dir:
            (args.out_dir / f"{sid}.md").write_text(text, encoding="utf-8")
    if n == 0:
        report.append("Nothing falls due in this window.")
    text = "\n".join(report) + "\n"
    print(text)
    if args.summary and os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as fh:
            fh.write(text)
    if os.environ.get("GITHUB_OUTPUT"):
        with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as fh:
            fh.write(f"systems={n}\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
