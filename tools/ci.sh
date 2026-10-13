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

step "JSON / YAML syntax across vendor packs"
python3 - <<'PY'
import json, pathlib, yaml
n = 0
for p in pathlib.Path("vendors").rglob("*"):
    if ".terraform" in p.parts or not p.is_file():
        continue
    if p.suffix == ".json":
        json.loads(p.read_text()); n += 1
    elif p.suffix in (".yaml", ".yml"):
        yaml.safe_load(p.read_text()); n += 1
print(f"ok ({n} files)")
PY

step "Shell syntax"
find vendors tools -name '*.sh' -print0 | xargs -0 -n1 bash -n
echo "ok"

step "Python syntax"
find vendors tools -name '*.py' -print0 | xargs -0 python3 -m py_compile
echo "ok"

step "CloudFormation (cfn-lint)"
cfn-lint vendors/aws-bedrock/native/cloudformation/*.yaml
echo "ok"

step "Bicep build"
for f in $(find vendors -name '*.bicep'); do bicep build "$f" --stdout >/dev/null; echo "  $f"; done

if [[ "${1:-}" != "--skip-terraform" ]]; then
  step "Terraform fmt + validate"
  terraform fmt -check -recursive vendors
  for d in $(find vendors -name '*.tf' -not -path '*/.terraform/*' -exec dirname {} \; | sort -u); do
    (cd "$d" && terraform init -backend=false -input=false >/dev/null && terraform validate -no-color >/dev/null)
    echo "  $d"
  done
fi

printf '\n\033[1mAll checks passed.\033[0m\n'
