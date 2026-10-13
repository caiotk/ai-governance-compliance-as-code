#!/usr/bin/env python3
"""MLOps governance gate.

Evaluates one or more AI system records (YAML) against every applicable
framework using the Rego policies in mlops/policies.

    python3 tools/gate.py mlops/examples/compliant/*.yaml
    python3 tools/gate.py --expect-fail mlops/examples/noncompliant/*.yaml
    python3 tools/gate.py --markdown report.md system.yaml

Exit code 1 if any system is denied (or, with --expect-fail, if any passes).
Requires the `opa` binary on PATH (or OPA_BIN).
"""
from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
OPA = os.environ.get("OPA_BIN") or shutil.which("opa")
if not OPA:
    sys.exit("opa not found on PATH (set OPA_BIN or install from https://www.openpolicyagent.org/)")
SCHEMA = ROOT / "mlops/schema/ai-system.schema.json"


def validate_schema(doc: dict, path: Path) -> list[str]:
    try:
        import jsonschema  # optional dependency
    except ImportError:
        return []
    schema = json.loads(SCHEMA.read_text())
    v = jsonschema.Draft202012Validator(schema)
    return [f"{path}: schema: {'/'.join(map(str, e.path)) or '(root)'}: {e.message}" for e in v.iter_errors(doc)]


def evaluate(doc: dict) -> dict:
    with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False) as fh:
        json.dump(doc, fh, default=str)
        inp = fh.name
    try:
        out = subprocess.run(
            [OPA, "eval", "--format", "json", "-d", str(ROOT / "mlops/policies"), "-d", str(ROOT / "mlops/data/catalog.json"),
             "-i", inp, "data.aigov.decision"],
            check=True, capture_output=True, text=True,
        )
    finally:
        os.unlink(inp)
    return json.loads(out.stdout)["result"][0]["expressions"][0]["value"]


def render(path: Path, d: dict) -> str:
    lines = [f"### {'✅ ALLOW' if d['allow'] else '❌ DENY'} `{d['system']}` — {path}", "",
             f"Evaluated {d['evaluation_date']} against: {', '.join(d['frameworks'])}", ""]
    for sev, items in (("deny", d["deny"]), ("warn", d["warn"])):
        for f in items:
            lines.append(f"- {'❌' if sev == 'deny' else '⚠️'} **{f['control']}** [{', '.join(f['frameworks'])}] {f['message']}")
    if not d["deny"] and not d["warn"]:
        lines.append("- No findings.")
    return "\n".join(lines) + "\n"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("files", nargs="+", type=Path)
    ap.add_argument("--expect-fail", action="store_true", help="succeed only if every system is denied")
    ap.add_argument("--markdown", type=Path, help="write a Markdown report")
    ap.add_argument("--date", help="evaluate as of this date (YYYY-MM-DD), overriding the record")
    args = ap.parse_args()

    failures, report = 0, ["## AI governance gate", ""]
    for path in args.files:
        doc = yaml.safe_load(path.read_text(encoding="utf-8"))
        problems = validate_schema(doc, path)
        if problems:
            print("\n".join(problems), file=sys.stderr)
            failures += 1
            continue
        if args.date:
            doc.setdefault("context", {})["evaluation_date"] = args.date
        d = evaluate(doc)
        text = render(path, d)
        print(text)
        report.append(text)
        if d["allow"] == args.expect_fail:
            failures += 1

    if args.markdown:
        args.markdown.write_text("\n".join(report), encoding="utf-8")
        if os.environ.get("GITHUB_STEP_SUMMARY"):
            with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as fh:
                fh.write("\n".join(report))
    if failures:
        print(f"Gate {'did not deny every system as expected' if args.expect_fail else 'BLOCKED'}: {failures} system(s).", file=sys.stderr)
        return 1
    print(f"Gate passed for {len(args.files)} system(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
