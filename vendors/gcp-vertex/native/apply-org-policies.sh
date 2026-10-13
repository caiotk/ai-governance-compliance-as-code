#!/usr/bin/env bash
# AIG-06 AIG-08 AIG-09 AIG-10 AIG-18
# Applies the Vertex AI organization policies in org-policies/*.yaml with
# `gcloud org-policies set-policy`, substituting PARENT.
#
# Usage:
#   PARENT=organizations/123456789012 ./apply-org-policies.sh
#   PARENT=folders/123456789012       ./apply-org-policies.sh
#   PARENT=projects/my-project        ./apply-org-policies.sh
# Optional: DRY_RUN=1 prints the rendered policies without applying them.
#
# Permissions: roles/orgpolicy.policyAdmin on the target resource.
# Edit org-policies/*.yaml first (approved models, allowed locations).
# The *.yaml.example file is not applied.

set -euo pipefail

: "${PARENT:?Set PARENT to organizations/ID, folders/ID or projects/ID}"
if [[ ! "${PARENT}" =~ ^(organizations|folders|projects)/[A-Za-z0-9-]+$ ]]; then
  echo "PARENT must look like organizations/ID, folders/ID or projects/ID" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT

for src in "${SCRIPT_DIR}"/org-policies/*.yaml; do
  name="$(basename "${src}")"
  rendered="${WORKDIR}/${name}"
  sed "s#PARENT/policies/#${PARENT}/policies/#" "${src}" > "${rendered}"
  echo "==> ${name} -> ${PARENT}"
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    cat "${rendered}"
  else
    gcloud org-policies set-policy "${rendered}"
  fi
done

if [[ "${DRY_RUN:-0}" != "1" ]]; then
  echo "==> Evidence: effective policies on ${PARENT}"
  scope_flag="--${PARENT%%/*}"
  scope_flag="${scope_flag%s}"   # organizations -> --organization, folders -> --folder, projects -> --project
  for c in vertexai.allowedModels gcp.resourceLocations gcp.restrictNonCmekServices vertexai.disableGenAIGoogleSearchGrounding; do
    gcloud org-policies describe "${c}" --effective "${scope_flag}=${PARENT#*/}"
  done
fi
