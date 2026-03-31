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
VARIABLE_SET_RESP="$(api_get "${API_BASE}/platform/variable-sets")"

CATALOG_LINES="$(
CATALOG_PATH="${CATALOG_PATH}" \
LIST_RESP="${LIST_RESP}" \
VARIABLE_SET_RESP="${VARIABLE_SET_RESP}" \
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

try:
    variable_set_resp = json.loads(os.environ["VARIABLE_SET_RESP"])
except Exception as exc:
    print(f"ERROR\tfailed to parse variable set list response: {exc}")
    sys.exit(0)

items = list_resp.get("data", [])
existing = {}
for item in items if isinstance(items, list) else []:
    name = str(item.get("name", "")).strip()
    tid = str(item.get("id", "")).strip()
    if name and tid:
        existing[name] = tid

variable_set_items = variable_set_resp.get("data", [])
variable_sets = {}
for item in variable_set_items if isinstance(variable_set_items, list) else []:
    name = str(item.get("name", "")).strip()
    item_id = str(item.get("id", "")).strip()
    if name and item_id:
        variable_sets[name] = item_id

for template in catalog.get("templates", []):
    payload = {}
    for key in (
        "name",
        "description",
        "app_type",
        "variable_set_id",
        "playbook_path",
        "inventory_content",
        "inventory_grouping_selection_set_id",
        "repo_url",
        "repo_branch",
        "extra_vars_json",
        "arguments",
        "run_on_agent",
        "agent_code",
        "credential_code",
    ):
        value = template.get(key)
        if isinstance(value, str):
            if value.strip() != "":
                payload[key] = value
        elif isinstance(value, bool):
            payload[key] = value
        elif value is not None:
            payload[key] = value

    variable_set_name = str(template.get("variable_set_name", "")).strip()
    if variable_set_name and not payload.get("variable_set_id"):
        variable_set_id = variable_sets.get(variable_set_name, "")
        if not variable_set_id:
            print(json.dumps({
                "action": "ERROR",
                "message": f"variable set not found for template {template.get('name', '')}: {variable_set_name}",
            }, ensure_ascii=False))
            continue
        payload["variable_set_id"] = variable_set_id

    if not payload.get("name"):
        print(json.dumps({"action": "ERROR", "message": "template name is required"}, ensure_ascii=False))
        continue
    template_id = existing.get(payload["name"], "")
    action = "update" if template_id else "create"
    print(json.dumps({
        "action": action,
        "item_id": template_id,
        "name": payload["name"],
        "payload": payload,
    }, ensure_ascii=False))
PY
)"

if [[ -z "${CATALOG_LINES}" ]]; then
  log "no templates found in catalog"
  exit 0
fi

while IFS= read -r row; do
  [[ -n "${row}" ]] || continue

  action="$(
  ROW="${row}" python3 - <<'PY'
import json
import os
print(json.loads(os.environ["ROW"]).get("action", ""))
PY
  )"

  if [[ "${action}" == "ERROR" ]]; then
    ROW="${row}" python3 - <<'PY' >&2
import json
import os
print(json.loads(os.environ["ROW"]).get("message", "unknown error"))
PY
    exit 1
  fi

  template_id="$(
  ROW="${row}" python3 - <<'PY'
import json
import os
print(json.loads(os.environ["ROW"]).get("item_id", ""))
PY
  )"

  name="$(
  ROW="${row}" python3 - <<'PY'
import json
import os
print(json.loads(os.environ["ROW"]).get("name", ""))
PY
  )"

  payload="$(
  ROW="${row}" python3 - <<'PY'
import json
import os
print(json.dumps(json.loads(os.environ["ROW"]).get("payload", {}), ensure_ascii=False))
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
