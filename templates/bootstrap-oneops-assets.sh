#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $*"
}

log "importing variable sets"
bash "${SCRIPT_DIR}/import-variable-sets.sh"

log "importing task templates"
bash "${SCRIPT_DIR}/import-to-oneops.sh"

if [[ -n "${DEFAULT_PROJECT_ID:-}" ]]; then
  log "importing scheduled tasks"
  bash "${SCRIPT_DIR}/import-scheduled-tasks.sh"
else
  log "skipping scheduled tasks because DEFAULT_PROJECT_ID is empty"
  log "set DEFAULT_PROJECT_ID and rerun import-scheduled-tasks.sh when ready"
fi

log "bootstrap completed"
