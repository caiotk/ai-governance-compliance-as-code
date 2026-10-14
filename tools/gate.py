#!/usr/bin/env python3
"""MLOps governance gate.

Evaluates one or more AI system records (YAML) against every applicable
framework using the Rego policies in mlops/policies.

    python3 tools/gate.py mlops/examples/compliant/*.yaml
    python3 tools/gate.py --expect-fail mlops/examples/noncompliant/*.yaml
    python3 tools/gate.py --markdown report.md --sarif gate.sarif --json gate.json systems/*.yaml

Exit code 1 if any system is denied (or, with --expect-fail, if any passes).
Requires the `opa` binary on PATH (or OPA_BIN). Other tools import
`load_record`, `validate_schema` and `evaluate` from this module.
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
SCHEMA = ROOT / "mlops/schema/ai-system.schema.json"
SARIF_RULE_URL = "https://github.com/caiotk/ai-governance-compliance-as-code/blob/main/docs/CROSSWALK.md"


def opa_bin() -> str:
    opa = os.environ.get("OPA_BIN") or shutil.which("opa")
    if not opa:
        sys.exit("opa not found on PATH (set OPA_BIN or install from https://www.openpolicyagent.org/)")
    return opa


def load_record(path: Path) -> dict:
    return yaml.safe_load(path.read_text(encoding="utf-8"))


def validate_schema(doc: dict, path: Path) -> list[str]:
    try:
        import jsonschema  # optional dependency
    except ImportError:
        return []
    schema = json.loads(SCHEMA.read_text())
    v = jsonschema.Draft202012Validator(schema)
    return [f"{path}: schema: {'/'.join(map(str, e.path)) or '(root)'}: {e.message}" for e in v.iter_errors(doc)]


def evaluate(doc: dict, date: str | None = None) -> dict:
    """Run the Rego decision for one record. Returns data.aigov.decision."""
    if date:
        doc = dict(doc)
        doc["context"] = {**doc.get("context", {}), "evaluation_date": date}
    with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False) as fh:
        json.dump(doc, fh, default=str)
        inp = fh.name
    try:
        out = subprocess.run(
            [opa_bin(), "eval", "--format", "json", "-d", str(ROOT / "mlops/policies"), "-d", str(ROOT / "mlops/data/catalog.json"),
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


def sarif(results: list[tuple[Path, dict]]) -> dict:
    """SARIF 2.1.0 log: one result per finding, anchored on the record file."""
    rules: dict[str, dict] = {}
    out = []
    for path, d in results:
        for f in d["deny"] + d["warn"]:
            rid = f["id"]
            rules.setdefault(rid, {
                "id": rid,
                "name": f["control"],
                "shortDescription": {"text": f"{f['control']} ({', '.join(f['frameworks'])})"},
                "helpUri": SARIF_RULE_URL + "#" + f["control"].lower(),
                "defaultConfiguration": {"level": "error" if f["severity"] == "deny" else "warning"},
            })
            out.append({
                "ruleId": rid,
                "level": "error" if f["severity"] == "deny" else "warning",
                "message": {"text": f"[{f['control']}] {f['message']} (frameworks: {', '.join(f['frameworks'])})"},
                "locations": [{"physicalLocation": {"artifactLocation": {"uri": str(path).replace(os.sep, "/"), "uriBaseId": "%SRCROOT%"},
                                                     "region": {"startLine": 1}}}],
                "partialFingerprints": {"systemAndRule": f"{d['system']}:{rid}"},
            })
    return {
        "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
        "version": "2.1.0",
        "runs": [{
            "tool": {"driver": {"name": "AI governance gate", "informationUri": "https://github.com/caiotk/ai-governance-compliance-as-code",
                                "version": (ROOT / "VERSION").read_text().strip() if (ROOT / "VERSION").exists() else "0",
                                "rules": list(rules.values())}},
            "results": out,
        }],
    }


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("files", nargs="+", type=Path)
    ap.add_argument("--expect-fail", action="store_true", help="succeed only if every system is denied")
    ap.add_argument("--markdown", type=Path, help="write a Markdown report")
    ap.add_argument("--sarif", type=Path, help="write findings as SARIF 2.1.0 (GitHub code scanning)")
    ap.add_argument("--json", type=Path, help="write every decision as JSON")
    ap.add_argument("--date", help="evaluate as of this date (YYYY-MM-DD), overriding the record")
    args = ap.parse_args()

    failures, report, results = 0, ["## AI governance gate", ""], []
    for path in args.files:
        doc = load_record(path)
        problems = validate_schema(doc, path)
        if problems:
            print("\n".join(problems), file=sys.stderr)
            failures += 1
            continue
        d = evaluate(doc, args.date)
        results.append((path, d))
        text = render(path, d)
        print(text)
        report.append(text)
        if d["allow"] == args.expect_fail:
            failures += 1

    if args.markdown:
        args.markdown.parent.mkdir(parents=True, exist_ok=True)
        args.markdown.write_text("\n".join(report), encoding="utf-8")
        if os.environ.get("GITHUB_STEP_SUMMARY"):
            with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as fh:
                fh.write("\n".join(report))
    if args.sarif:
        args.sarif.parent.mkdir(parents=True, exist_ok=True)
        args.sarif.write_text(json.dumps(sarif(results), indent=2), encoding="utf-8")
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps([{"file": str(p), **d} for p, d in results], indent=2), encoding="utf-8")
    if failures:
        print(f"Gate {'did not deny every system as expected' if args.expect_fail else 'BLOCKED'}: {failures} system(s).", file=sys.stderr)
        return 1
    print(f"Gate passed for {len(args.files)} system(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
