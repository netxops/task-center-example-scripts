#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

API_BASE="${API_BASE:-http://127.0.0.1:8080/api/v1}"
AUTH_TOKEN="${AUTH_TOKEN:-abc123}"
CATALOG_PATH="${CATALOG_PATH:-${SCRIPT_DIR}/task-template-catalog.json}"
DRY_RUN="${DRY_RUN:-false}"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing required command: $1" >&2
    exit 2
  }
}

log() {
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $*"
}

api_get() {
  curl -sS -H "X-Auth-Token: ${AUTH_TOKEN}" "$1"
}

api_post() {
  local url="$1"
  local payload="$2"
  curl -sS -X POST "$url" \
    -H "Content-Type: application/json" \
    -H "X-Auth-Token: ${AUTH_TOKEN}" \
    -d "$payload"
}

api_put() {
  local url="$1"
  local payload="$2"
  curl -sS -X PUT "$url" \
    -H "Content-Type: application/json" \
    -H "X-Auth-Token: ${AUTH_TOKEN}" \
    -d "$payload"
}

require_cmd curl
require_cmd python3

if [[ ! -f "${CATALOG_PATH}" ]]; then
  echo "catalog not found: ${CATALOG_PATH}" >&2
  exit 2
fi

log "loading template catalog: ${CATALOG_PATH}"

LIST_RESP="$(api_get "${API_BASE}/platform/task-templates")"

CATALOG_LINES="$(
CATALOG_PATH="${CATALOG_PATH}" \
LIST_RESP="${LIST_RESP}" \
python3 - <<'PY'
import json
import os
import sys

catalog_path = os.environ["CATALOG_PATH"]
with open(catalog_path, "r", encoding="utf-8") as fh:
    catalog = json.load(fh)

try:
    list_resp = json.loads(os.environ["LIST_RESP"])
except Exception as exc:
    print(f"ERROR\tfailed to parse task template list response: {exc}")
    sys.exit(0)

items = list_resp.get("data", [])
existing = {}
for item in items if isinstance(items, list) else []:
    name = str(item.get("name", "")).strip()
    tid = str(item.get("id", "")).strip()
    if name and tid:
        existing[name] = tid

allowed = [
    "name",
    "description",
    "app_type",
    "playbook_path",
    "repo_url",
    "repo_branch",
    "extra_vars_json",
]

for template in catalog.get("templates", []):
    payload = {k: template.get(k, "") for k in allowed if str(template.get(k, "")).strip() != ""}
    if not payload.get("name"):
        print("ERROR\ttemplate name is required")
        continue
    template_id = existing.get(payload["name"], "")
    action = "update" if template_id else "create"
    print(action + "\t" + template_id + "\t" + json.dumps(payload, ensure_ascii=False))
PY
)"

if [[ -z "${CATALOG_LINES}" ]]; then
  log "no templates found in catalog"
  exit 0
fi

while IFS=$'\t' read -r action template_id payload; do
  [[ -n "${action}" ]] || continue

  if [[ "${action}" == "ERROR" ]]; then
    echo "${template_id}" >&2
    exit 1
  fi

  name="$(
  PAYLOAD="${payload}" python3 - <<'PY'
import json
import os
data = json.loads(os.environ["PAYLOAD"])
print(data.get("name", ""))
PY
  )"

  if [[ "${DRY_RUN}" == "true" ]]; then
    log "dry-run ${action}: ${name}"
    continue
  fi

  if [[ "${action}" == "create" ]]; then
    log "creating template: ${name}"
    resp="$(api_post "${API_BASE}/platform/task-templates" "${payload}")"
  else
    log "updating template: ${name} (${template_id})"
    resp="$(api_put "${API_BASE}/platform/task-templates/${template_id}" "${payload}")"
  fi

  ok="$(
  RESP="${resp}" python3 - <<'PY'
import json
import os
try:
    data = json.loads(os.environ["RESP"])
except Exception:
    print("false")
else:
    print("true" if data.get("code") == 0 else "false")
PY
  )"

  if [[ "${ok}" != "true" ]]; then
    echo "${resp}" >&2
    echo "failed to ${action} template: ${name}" >&2
    exit 1
  fi

  log "done: ${name}"
done <<< "${CATALOG_LINES}"

log "task template import completed"
