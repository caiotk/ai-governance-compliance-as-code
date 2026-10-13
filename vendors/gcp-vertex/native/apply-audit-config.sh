#!/usr/bin/env bash
# AIG-13
# Enables Data Access audit logs (DATA_READ, DATA_WRITE) for the services in
# audit-config.yaml by merging its auditConfigs into the project's current IAM
# policy (read-modify-write with the etag, so concurrent changes are rejected
# rather than overwritten).
#
# Usage:   PROJECT_ID=my-project ./apply-audit-config.sh
# Requires: gcloud, python3 with PyYAML.
# Permissions: resourcemanager.projects.getIamPolicy and setIamPolicy.

set -euo pipefail

: "${PROJECT_ID:?Set PROJECT_ID}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT

gcloud projects get-iam-policy "${PROJECT_ID}" --format=json > "${WORKDIR}/current.json"

python3 - "${WORKDIR}/current.json" "${SCRIPT_DIR}/audit-config.yaml" "${WORKDIR}/merged.json" <<'PY'
import json, sys, yaml

current_path, fragment_path, out_path = sys.argv[1:4]
policy = json.load(open(current_path))
wanted = yaml.safe_load(open(fragment_path))["auditConfigs"]

by_service = {c["service"]: c for c in policy.get("auditConfigs", [])}
for cfg in wanted:
    existing = by_service.get(cfg["service"])
    if existing is None:
        by_service[cfg["service"]] = cfg
        continue
    # Keep existing log types (and their exemptions); add any missing ones.
    have = {c["logType"] for c in existing.get("auditLogConfigs", [])}
    for c in cfg["auditLogConfigs"]:
        if c["logType"] not in have:
            existing.setdefault("auditLogConfigs", []).append(c)

policy["auditConfigs"] = list(by_service.values())
json.dump(policy, open(out_path, "w"), indent=2)
PY

gcloud projects set-iam-policy "${PROJECT_ID}" "${WORKDIR}/merged.json" >/dev/null

echo "==> Evidence (AIG-13): auditConfigs on ${PROJECT_ID}"
gcloud projects get-iam-policy "${PROJECT_ID}" --format='yaml(auditConfigs)'
