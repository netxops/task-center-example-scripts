#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

API_BASE="${API_BASE:-http://127.0.0.1:8080/api/v1}"
AUTH_TOKEN="${AUTH_TOKEN:-abc123}"
CATALOG_PATH="${CATALOG_PATH:-${SCRIPT_DIR}/scheduled-task-catalog.json}"
DRY_RUN="${DRY_RUN:-false}"
DEFAULT_PROJECT_ID="${DEFAULT_PROJECT_ID:-}"
DEFAULT_FUNCTION_AREA="${DEFAULT_FUNCTION_AREA:-}"
DEFAULT_ENABLED="${DEFAULT_ENABLED:-}"
DEFAULT_RUN_ON_AGENT="${DEFAULT_RUN_ON_AGENT:-}"
DEFAULT_AGENT_CODE="${DEFAULT_AGENT_CODE:-}"
DEFAULT_CREDENTIAL_CODE="${DEFAULT_CREDENTIAL_CODE:-}"

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

if [[ -z "${DEFAULT_PROJECT_ID}" ]]; then
  echo "DEFAULT_PROJECT_ID is required for scheduled task import" >&2
  exit 2
fi

log "loading scheduled task catalog: ${CATALOG_PATH}"

LIST_RESP="$(api_get "${API_BASE}/platform/scheduled-tasks?page=1&page_size=500")"
TEMPLATE_RESP="$(api_get "${API_BASE}/platform/task-templates")"
VARIABLE_SET_RESP="$(api_get "${API_BASE}/platform/variable-sets")"

CATALOG_LINES="$(
CATALOG_PATH="${CATALOG_PATH}" \
LIST_RESP="${LIST_RESP}" \
TEMPLATE_RESP="${TEMPLATE_RESP}" \
VARIABLE_SET_RESP="${VARIABLE_SET_RESP}" \
DEFAULT_PROJECT_ID="${DEFAULT_PROJECT_ID}" \
DEFAULT_FUNCTION_AREA="${DEFAULT_FUNCTION_AREA}" \
DEFAULT_ENABLED="${DEFAULT_ENABLED}" \
DEFAULT_RUN_ON_AGENT="${DEFAULT_RUN_ON_AGENT}" \
DEFAULT_AGENT_CODE="${DEFAULT_AGENT_CODE}" \
DEFAULT_CREDENTIAL_CODE="${DEFAULT_CREDENTIAL_CODE}" \
python3 - <<'PY'
import json
import os
import sys

def parse_bool(value, fallback=None):
    if isinstance(value, bool):
        return value
    if value is None:
        return fallback
    text = str(value).strip().lower()
    if text in ("1", "true", "yes", "on"):
        return True
    if text in ("0", "false", "no", "off"):
        return False
    return fallback

catalog_path = os.environ["CATALOG_PATH"]
with open(catalog_path, "r", encoding="utf-8") as fh:
    catalog = json.load(fh)

try:
    list_resp = json.loads(os.environ["LIST_RESP"])
    template_resp = json.loads(os.environ["TEMPLATE_RESP"])
    variable_set_resp = json.loads(os.environ["VARIABLE_SET_RESP"])
except Exception as exc:
    print(f"ERROR\tfailed to parse oneops response: {exc}")
    sys.exit(0)

list_data = list_resp.get("data", {})
items = list_data.get("list", []) if isinstance(list_data, dict) else []
existing = {}
for item in items if isinstance(items, list) else []:
    name = str(item.get("name", "")).strip()
    item_id = str(item.get("id", "")).strip()
    if name and item_id:
        existing[name] = item_id

template_items = template_resp.get("data", [])
template_ids = {}
for item in template_items if isinstance(template_items, list) else []:
    name = str(item.get("name", "")).strip()
    item_id = str(item.get("id", "")).strip()
    if name and item_id:
        template_ids[name] = item_id

variable_set_items = variable_set_resp.get("data", [])
variable_set_ids = {}
for item in variable_set_items if isinstance(variable_set_items, list) else []:
    name = str(item.get("name", "")).strip()
    item_id = str(item.get("id", "")).strip()
    if name and item_id:
        variable_set_ids[name] = item_id

defaults = catalog.get("defaults", {})
default_project_id = os.environ.get("DEFAULT_PROJECT_ID", "").strip() or str(defaults.get("project_id", "")).strip()
default_function_area = os.environ.get("DEFAULT_FUNCTION_AREA", "").strip() or str(defaults.get("function_area", "")).strip() or "DefaultArea"
default_enabled = parse_bool(os.environ.get("DEFAULT_ENABLED", ""), parse_bool(defaults.get("enabled"), False))
default_run_on_agent = parse_bool(os.environ.get("DEFAULT_RUN_ON_AGENT", ""), parse_bool(defaults.get("run_on_agent"), None))
default_agent_code = os.environ.get("DEFAULT_AGENT_CODE", "").strip() or str(defaults.get("agent_code", "")).strip()
default_credential_code = os.environ.get("DEFAULT_CREDENTIAL_CODE", "").strip() or str(defaults.get("credential_code", "")).strip()

for scheduled_task in catalog.get("scheduled_tasks", []):
    payload = {}
    for key in (
        "name",
        "template_id",
        "project_id",
        "function_area",
        "cron_expr",
        "enabled",
        "variable_set_id",
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
        value = scheduled_task.get(key)
        if isinstance(value, str):
          if value.strip() != "":
            payload[key] = value
        elif isinstance(value, bool):
          payload[key] = value
        elif value is not None:
          payload[key] = value

    template_name = str(scheduled_task.get("template_name", "")).strip()
    if template_name and not payload.get("template_id"):
        template_id = template_ids.get(template_name, "")
        if not template_id:
            print(f"ERROR\ttemplate not found for scheduled task {scheduled_task.get('name', '')}: {template_name}")
            continue
        payload["template_id"] = template_id

    variable_set_name = str(scheduled_task.get("variable_set_name", "")).strip()
    if variable_set_name and not payload.get("variable_set_id"):
        variable_set_id = variable_set_ids.get(variable_set_name, "")
        if not variable_set_id:
            print(f"ERROR\tvariable set not found for scheduled task {scheduled_task.get('name', '')}: {variable_set_name}")
            continue
        payload["variable_set_id"] = variable_set_id

    if not payload.get("project_id"):
        payload["project_id"] = default_project_id
    if not payload.get("function_area"):
        payload["function_area"] = default_function_area
    if "enabled" not in payload:
        payload["enabled"] = default_enabled
    if "run_on_agent" not in payload and default_run_on_agent is not None:
        payload["run_on_agent"] = default_run_on_agent
    if not payload.get("agent_code") and default_agent_code:
        payload["agent_code"] = default_agent_code
    if not payload.get("credential_code") and default_credential_code:
        payload["credential_code"] = default_credential_code

    missing = [key for key in ("name", "template_id", "project_id", "function_area", "cron_expr") if not str(payload.get(key, "")).strip()]
    if missing:
        print(f"ERROR\tscheduled task missing required fields {missing}: {scheduled_task.get('name', '')}")
        continue

    item_id = existing.get(payload["name"], "")
    action = "update" if item_id else "create"
    print(action + "\t" + item_id + "\t" + json.dumps(payload, ensure_ascii=False))
PY
)"

if [[ -z "${CATALOG_LINES}" ]]; then
  log "no scheduled tasks found in catalog"
  exit 0
fi

while IFS=$'\t' read -r action item_id payload; do
  [[ -n "${action}" ]] || continue

  if [[ "${action}" == "ERROR" ]]; then
    echo "${item_id}" >&2
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
    log "creating scheduled task: ${name}"
    resp="$(api_post "${API_BASE}/platform/scheduled-tasks" "${payload}")"
  else
    log "updating scheduled task: ${name} (${item_id})"
    resp="$(api_put "${API_BASE}/platform/scheduled-tasks/${item_id}" "${payload}")"
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
    echo "failed to ${action} scheduled task: ${name}" >&2
    exit 1
  fi

  log "done: ${name}"
done <<< "${CATALOG_LINES}"

log "scheduled task import completed"
