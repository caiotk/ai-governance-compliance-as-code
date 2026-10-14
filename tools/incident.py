#!/usr/bin/env python3
"""Incident records in incidents/ (created by hooks/receiver.py or by hand).

    python3 tools/incident.py list [--open] [--system ID]
    python3 tools/incident.py open --system ID --title "..." [--severity high] [--source manual] [--event-type manual]
    python3 tools/incident.py note INC-... "what was done"
    python3 tools/incident.py close INC-... --resolution "..."
    python3 tools/incident.py link INC-... --system ID          # assign an unassigned webhook incident
"""
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import re
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
INCIDENTS = ROOT / "incidents"
SYSTEM_RE = re.compile(r"^[a-z0-9][a-z0-9-]{1,62}$")


def now() -> str:
    return dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def load_all() -> list[tuple[Path, dict]]:
    return [(p, yaml.safe_load(p.read_text(encoding="utf-8")) or {}) for p in sorted(INCIDENTS.glob("INC-*.yaml"))] if INCIDENTS.exists() else []


def find(iid: str) -> tuple[Path, dict]:
    p = INCIDENTS / f"{iid}.yaml"
    if not p.exists():
        sys.exit(f"no incident {iid}")
    return p, yaml.safe_load(p.read_text(encoding="utf-8"))


def save(p: Path, rec: dict) -> None:
    p.write_text(yaml.safe_dump(rec, sort_keys=False, allow_unicode=True), encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("list"); s.add_argument("--open", action="store_true"); s.add_argument("--system")
    s = sub.add_parser("open"); s.add_argument("--system", required=True); s.add_argument("--title", required=True)
    s.add_argument("--severity", default="medium", choices=["low", "medium", "high", "critical"]); s.add_argument("--source", default="manual"); s.add_argument("--event-type", default="manual")
    s = sub.add_parser("note"); s.add_argument("id"); s.add_argument("text")
    s = sub.add_parser("close"); s.add_argument("id"); s.add_argument("--resolution", required=True)
    s = sub.add_parser("link"); s.add_argument("id"); s.add_argument("--system", required=True)
    a = ap.parse_args()

    if a.cmd == "list":
        rows = [(p, r) for p, r in load_all() if (not a.open or r.get("status", "open") == "open") and (not a.system or r.get("system") == a.system)]
        print(f"{'id':22} {'status':7} {'sev':8} {'system':32} {'type':24} title")
        for p, r in rows:
            print(f"{r.get('id', p.stem):22} {r.get('status', 'open'):7} {r.get('severity', ''):8} {r.get('system', ''):32} {r.get('event_type', ''):24} {r.get('title', '')[:60]}")
        print(f"{len(rows)} incident(s)")
        return 0
    if a.cmd == "open":
        if not SYSTEM_RE.match(a.system):
            sys.exit("bad system id")
        iid = f"INC-{dt.datetime.now(dt.timezone.utc).strftime('%Y%m%d')}-{hashlib.sha256((a.system + a.title + now()).encode()).hexdigest()[:8]}"
        rec = {"apiVersion": "aigov/v1", "kind": "AIIncident", "id": iid, "system": a.system, "source": a.source, "event_type": a.event_type,
               "severity": a.severity, "title": a.title, "occurred": now(), "opened": now(), "status": "open", "controls": ["AIG-16"], "details": {}, "notes": []}
        INCIDENTS.mkdir(exist_ok=True)
        save(INCIDENTS / f"{iid}.yaml", rec)
        print(iid)
        return 0
    p, rec = find(a.id)
    if a.cmd == "note":
        rec.setdefault("notes", []).append({"at": now(), "text": a.text})
    elif a.cmd == "close":
        rec["status"] = "closed"; rec["closed"] = now(); rec["resolution"] = a.resolution
    elif a.cmd == "link":
        if not SYSTEM_RE.match(a.system):
            sys.exit("bad system id")
        rec["system"] = a.system
    save(p, rec)
    print(f"{rec['id']}: {a.cmd} ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
