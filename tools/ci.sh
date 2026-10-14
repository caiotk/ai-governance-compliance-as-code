#!/usr/bin/env bash
# Run every check CI runs. Usage: tools/ci.sh [--skip-terraform]
set -euo pipefail
cd "$(dirname "$0")/.."

step() { printf '\n\033[1m▶ %s\033[0m\n' "$*"; }

step "Catalogue validation and generated files up to date"
python3 tools/build.py --check

step "Rego: format, strict check, unit tests"
opa fmt --fail --list mlops/policies mlops/tests
opa check --strict mlops/policies mlops/tests
opa test mlops/policies mlops/tests mlops/data/catalog.json

step "MLOps gate: compliant examples must pass, non-compliant must be denied"
python3 tools/gate.py mlops/examples/compliant/*.yaml >/dev/null
python3 tools/gate.py --expect-fail mlops/examples/noncompliant/*.yaml >/dev/null
echo "ok"

step "Inventory records in systems/ pass the gate; SARIF, inventory, reviews and reports build"
tmp=$(mktemp -d)
python3 tools/gate.py --markdown "$tmp/gate.md" --sarif "$tmp/gate.sarif" --json "$tmp/gate.json" systems/*.yaml >/dev/null
python3 -c "import json,sys; s=json.load(open(sys.argv[1])); assert s['version']=='2.1.0' and s['runs'][0]['tool']['driver']['name']" "$tmp/gate.sarif"
python3 tools/inventory.py --out-dir "$tmp/inv" >/dev/null
python3 tools/reviews.py --days 30 --out-dir "$tmp/rev" >/dev/null
python3 tools/report.py --out-dir "$tmp/rep" systems/*.yaml >/dev/null
test -s "$tmp/inv/INVENTORY.md" && test -s "$tmp/inv/inventory.csv" && ls "$tmp/rep"/*.md >/dev/null
rm -rf "$tmp"
echo "ok"

step "Incident records are well-formed"
python3 - <<'PY2'
import pathlib, yaml
n = 0
for p in sorted(pathlib.Path("incidents").glob("INC-*.yaml")):
    r = yaml.safe_load(p.read_text())
    assert r["kind"] == "AIIncident" and r["id"] == p.stem, p
    assert r["severity"] in ("low", "medium", "high", "critical") and r["status"] in ("open", "closed"), p
    n += 1
print(f"ok ({n} records)")
PY2

step "API and MCP server answer"
python3 - <<'PY3'
import json, subprocess, sys
sys.path.insert(0, "api")
import data
s = data.summary()
assert s["counts"]["controls"] == 22 and s["counts"]["frameworks"] >= 30 and s["counts"]["risks"] >= 36
assert data.control("AIG-11")["implemented_by"] is not None
assert "apra" in data.frameworks_for("AU", "fsi")
reqs = [{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2025-06-18"}},
        {"jsonrpc": "2.0", "id": 2, "method": "tools/list"},
        {"jsonrpc": "2.0", "id": 3, "method": "tools/call", "params": {"name": "get_risk", "arguments": {"id": "RSK-24"}}}]
out = subprocess.run([sys.executable, "mcp/server.py"], input="\n".join(json.dumps(r) for r in reqs) + "\n", capture_output=True, text=True, check=True).stdout
msgs = [json.loads(l) for l in out.splitlines() if l.strip()]
assert len(msgs) == 3 and len(msgs[1]["result"]["tools"]) >= 15 and not msgs[2]["result"]["isError"]
print("ok")
PY3

step "FinOps: selector unit tests, example workloads and DR tooling"
python3 -m unittest discover -s finops/tests -q
tmp=$(mktemp -d)
for w in finops/examples/*.yaml; do python3 tools/select_model.py "$w" --out-dir "$tmp" --date "$(python3 -c "import yaml;print(yaml.safe_load(open('finops/catalog/models.yaml'))['asOf'])")" >/dev/null; done
python3 tools/dr.py status >/dev/null
python3 - <<'PY'
import json, pathlib, yaml, jsonschema
schema = json.loads(pathlib.Path("finops/schema/workload.schema.json").read_text())
v = jsonschema.Draft202012Validator(schema)
for p in sorted(pathlib.Path("finops/examples").glob("*.yaml")):
    errs = list(v.iter_errors(yaml.safe_load(p.read_text())))
    if errs:
        raise SystemExit(f"{p}: {errs[0].message}")
cat = yaml.safe_load(pathlib.Path("finops/catalog/models.yaml").read_text())
ids = [m["id"] for m in cat["models"]]
assert len(ids) == len(set(ids)), "duplicate model ids"
for m in cat["models"]:
    assert m["tier"] in cat["tiers"], m["id"]
    assert m["verification"] in ("primary", "secondary", "unverified"), m["id"]
    for p in m["platforms"]:
        assert p["platform"] in cat["platforms"], f"{m['id']}: unknown platform {p['platform']}"
print(f"ok ({len(ids)} models, {len(cat['platforms'])} platforms)")
PY
rm -rf "$tmp"

step "Profile system templates are schema-valid"
python3 - <<'PY'
import json, pathlib, yaml, jsonschema
schema = json.loads(pathlib.Path("mlops/schema/ai-system.schema.json").read_text())
v = jsonschema.Draft202012Validator(schema)
n = 0
for p in sorted(pathlib.Path("profiles").glob("*/*.system.yaml")):
    errs = list(v.iter_errors(yaml.safe_load(p.read_text())))
    if errs:
        raise SystemExit(f"{p}: {errs[0].message}")
    n += 1
print(f"ok ({n} templates)")
PY

step "JSON / YAML / XML syntax across vendor packs, finops and bcp"
python3 - <<'PY'
import json, pathlib, yaml
import xml.dom.minidom
n = 0
for p in [q for d in ("vendors", "finops", "bcp") for q in pathlib.Path(d).rglob("*")]:
    if ".terraform" in p.parts or not p.is_file():
        continue
    if p.suffix == ".json":
        json.loads(p.read_text()); n += 1
    elif p.suffix in (".yaml", ".yml"):
        yaml.safe_load(p.read_text()); n += 1
    elif p.suffix == ".xml":
        xml.dom.minidom.parse(str(p)); n += 1
print(f"ok ({n} files)")
PY

step "Shell syntax"
find vendors tools finops bcp hooks -name '*.sh' -print0 | xargs -0 -n1 bash -n
echo "ok"

step "Python syntax"
find vendors tools finops bcp api mcp hooks -name '*.py' -print0 | xargs -0 python3 -m py_compile
echo "ok"

step "Workflow and config YAML parses; VERSION matches CHANGELOG"
python3 - <<'PY4'
import pathlib, re, yaml
for p in sorted(pathlib.Path(".github").rglob("*.yml")) + [pathlib.Path(".github/dependabot.yml")]:
    yaml.safe_load(p.read_text())
v = pathlib.Path("VERSION").read_text().strip()
assert re.match(r"^\d+\.\d+\.\d+$", v), v
assert f"## [{v}]" in pathlib.Path("CHANGELOG.md").read_text(), f"CHANGELOG.md has no section for {v}"
print(f"ok (v{v})")
PY4

step "CloudFormation (cfn-lint)"
cfn-lint vendors/aws-bedrock/native/cloudformation/*.yaml
echo "ok"

step "Bicep build"
for f in $(find vendors finops bcp -name '*.bicep'); do bicep build "$f" --stdout >/dev/null; echo "  $f"; done

if [[ "${1:-}" != "--skip-terraform" ]]; then
  step "Terraform fmt + validate"
  terraform fmt -check -recursive vendors finops bcp
  for d in $(find vendors finops bcp -name '*.tf' -not -path '*/.terraform/*' -exec dirname {} \; | sort -u); do
    (cd "$d" && terraform init -backend=false -input=false >/dev/null && terraform validate -no-color >/dev/null)
    echo "  $d"
  done
fi

printf '\n\033[1mAll checks passed.\033[0m\n'
