#!/usr/bin/env bash
# AIG-05 AIG-10 AIG-07
# Applies the Model Armor floor setting in model-armor-floor-setting.json with a
# REST PATCH, then grants the Vertex AI service agent roles/modelarmor.user.
#
# Resource name:  {parent}/locations/global/floorSetting
#   parent = projects/PROJECT_ID | folders/FOLDER_ID | organizations/ORG_ID
# Request:        PATCH https://modelarmor.googleapis.com/v1/{parent}/locations/global/floorSetting
#
# The global host modelarmor.googleapis.com is the one shown in Google's
# "Configure floor settings" and "Model Armor and Vertex AI" pages.
# UNVERIFIED: it is not recorded in the pack's research file, and the v1
# discovery document lists only regional (*.rep.googleapis.com) endpoints.
# Override with MODEL_ARMOR_ENDPOINT if your organization uses a regional endpoint.
#
# The Vertex AI integration page says to set Vertex floor settings at project
# level, so PARENT defaults to projects/$PROJECT_ID.
#
# Usage:
#   PROJECT_ID=my-project ./apply-model-armor.sh
#   PROJECT_ID=my-project PARENT=folders/123456789012 ./apply-model-armor.sh
# Optional: UPDATE_MASK (comma-separated field paths). Unset sends the PATCH
# without a mask, as in Google's examples.
#
# Permissions: roles/modelarmor.floorSettingsAdmin on PARENT,
#              resourcemanager.projects.setIamPolicy on PROJECT_ID (for the grant).

set -euo pipefail

: "${PROJECT_ID:?Set PROJECT_ID (quota project and Vertex AI project)}"
PARENT="${PARENT:-projects/${PROJECT_ID}}"
MODEL_ARMOR_ENDPOINT="${MODEL_ARMOR_ENDPOINT:-https://modelarmor.googleapis.com}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BODY="${SCRIPT_DIR}/model-armor-floor-setting.json"

if [[ ! "${PARENT}" =~ ^(organizations|folders|projects)/[A-Za-z0-9-]+$ ]]; then
  echo "PARENT must look like organizations/ID, folders/ID or projects/ID" >&2
  exit 1
fi

python3 -m json.tool "${BODY}" >/dev/null

echo "==> Enabling modelarmor.googleapis.com in ${PROJECT_ID}"
gcloud services enable modelarmor.googleapis.com --project "${PROJECT_ID}"

URL="${MODEL_ARMOR_ENDPOINT}/v1/${PARENT}/locations/global/floorSetting"
if [[ -n "${UPDATE_MASK:-}" ]]; then
  URL="${URL}?updateMask=${UPDATE_MASK}"
fi

echo "==> PATCH ${URL}"
curl --fail-with-body -sS -X PATCH \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "x-goog-user-project: ${PROJECT_ID}" \
  -H "Content-Type: application/json" \
  --data-binary "@${BODY}" \
  "${URL}"
echo

echo "==> Granting roles/modelarmor.user to the Vertex AI service agent"
PROJECT_NUMBER="$(gcloud projects describe "${PROJECT_ID}" --format='value(projectNumber)')"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-aiplatform.iam.gserviceaccount.com" \
  --role="roles/modelarmor.user" \
  --condition=None >/dev/null

echo "==> Evidence (AIG-10): current floor setting"
curl --fail-with-body -sS \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "x-goog-user-project: ${PROJECT_ID}" \
  "${MODEL_ARMOR_ENDPOINT}/v1/${PARENT}/locations/global/floorSetting"
echo
