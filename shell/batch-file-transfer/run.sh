#!/usr/bin/env bash
set -euo pipefail

TRANSFER_DIRECTION="${TRANSFER_DIRECTION:-push}"
TRANSFER_SRC_PATH="${TRANSFER_SRC_PATH:-${1:-}}"
TRANSFER_DEST_PATH="${TRANSFER_DEST_PATH:-${2:-}}"
TRANSFER_TARGETS="${TRANSFER_TARGETS:-}"
TRANSFER_TARGETS_FILE="${TRANSFER_TARGETS_FILE:-}"
TRANSFER_SSH_USER="${TRANSFER_SSH_USER:-}"
TRANSFER_SSH_PORT="${TRANSFER_SSH_PORT:-22}"
TRANSFER_TOOL="${TRANSFER_TOOL:-auto}"
TRANSFER_PARALLEL_JOBS="${TRANSFER_PARALLEL_JOBS:-2}"
TRANSFER_RSYNC_ARGS="${TRANSFER_RSYNC_ARGS:--az}"

usage() {
  cat <<'EOF'
Usage:
  bash shell/batch-file-transfer/run.sh <src_path> <dest_path>

Environment variables:
  TRANSFER_DIRECTION      push or pull. Default: push
  TRANSFER_SRC_PATH       Source path. Can also be passed as arg1
  TRANSFER_DEST_PATH      Destination path. Can also be passed as arg2
  TRANSFER_TARGETS        Comma-separated hosts, for example: 10.0.0.11,10.0.0.12
  TRANSFER_TARGETS_FILE   File containing one host per line
  TRANSFER_SSH_USER       Optional SSH user, prepended when target has no user@
  TRANSFER_SSH_PORT       SSH port. Default: 22
  TRANSFER_TOOL           auto, rsync, or scp. Default: auto
  TRANSFER_PARALLEL_JOBS  Concurrent transfer jobs. Default: 2
EOF
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

choose_tool() {
  if [[ "${TRANSFER_TOOL}" == "auto" ]]; then
    if has_cmd rsync; then
      echo "rsync"
    else
      echo "scp"
    fi
    return
  fi
  echo "${TRANSFER_TOOL}"
}

normalize_target() {
  local raw="$1"
  if [[ -n "${TRANSFER_SSH_USER}" && "${raw}" != *@* ]]; then
    echo "${TRANSFER_SSH_USER}@${raw}"
    return
  fi
  echo "${raw}"
}

target_label() {
  local raw="$1"
  raw="${raw##*@}"
  echo "${raw//[:\/]/_}"
}

read_targets() {
  local item
  if [[ -n "${TRANSFER_TARGETS}" ]]; then
    IFS=',' read -r -a raw_targets <<<"${TRANSFER_TARGETS}"
    for item in "${raw_targets[@]}"; do
      item="$(echo "${item}" | xargs)"
      [[ -n "${item}" ]] && echo "${item}"
    done
  elif [[ -n "${TRANSFER_TARGETS_FILE}" ]]; then
    while IFS= read -r item; do
      item="$(echo "${item}" | xargs)"
      [[ -z "${item}" || "${item}" == \#* ]] && continue
      echo "${item}"
    done <"${TRANSFER_TARGETS_FILE}"
  fi
}

run_push() {
  local tool="$1"
  local target="$2"
  local normalized
  normalized="$(normalize_target "${target}")"
  ssh -p "${TRANSFER_SSH_PORT}" "${normalized}" "mkdir -p '${TRANSFER_DEST_PATH}'"
  if [[ "${tool}" == "rsync" ]]; then
    rsync ${TRANSFER_RSYNC_ARGS} -e "ssh -p ${TRANSFER_SSH_PORT}" "${TRANSFER_SRC_PATH}" "${normalized}:${TRANSFER_DEST_PATH}/"
  else
    scp -P "${TRANSFER_SSH_PORT}" -r "${TRANSFER_SRC_PATH}" "${normalized}:${TRANSFER_DEST_PATH}/"
  fi
}

run_pull() {
  local tool="$1"
  local target="$2"
  local normalized label local_dest
  normalized="$(normalize_target "${target}")"
  label="$(target_label "${target}")"
  local_dest="${TRANSFER_DEST_PATH%/}/${label}"
  mkdir -p "${local_dest}"
  if [[ "${tool}" == "rsync" ]]; then
    rsync ${TRANSFER_RSYNC_ARGS} -e "ssh -p ${TRANSFER_SSH_PORT}" "${normalized}:${TRANSFER_SRC_PATH}" "${local_dest}/"
  else
    scp -P "${TRANSFER_SSH_PORT}" -r "${normalized}:${TRANSFER_SRC_PATH}" "${local_dest}/"
  fi
}

wait_for_slot() {
  while [[ "$(jobs -pr | wc -l | xargs)" -ge "${TRANSFER_PARALLEL_JOBS}" ]]; do
    sleep 1
  done
}

if [[ -z "${TRANSFER_SRC_PATH}" || -z "${TRANSFER_DEST_PATH}" ]]; then
  usage
  exit 2
fi

if [[ "${TRANSFER_DIRECTION}" != "push" && "${TRANSFER_DIRECTION}" != "pull" ]]; then
  echo "TRANSFER_DIRECTION must be push or pull"
  exit 2
fi

tool="$(choose_tool)"
if [[ "${tool}" != "rsync" && "${tool}" != "scp" ]]; then
  echo "TRANSFER_TOOL must be auto, rsync, or scp"
  exit 2
fi

if ! has_cmd ssh; then
  echo "ssh command not available"
  exit 1
fi

if ! has_cmd "${tool}"; then
  echo "${tool} command not available"
  exit 1
fi

mapfile -t targets < <(read_targets)
if [[ "${#targets[@]}" -eq 0 ]]; then
  echo "No targets provided. Use TRANSFER_TARGETS or TRANSFER_TARGETS_FILE."
  exit 2
fi

status_dir="$(mktemp -d)"
trap 'rm -rf "${status_dir}"' EXIT

for target in "${targets[@]}"; do
  wait_for_slot
  (
    echo "[INFO] ${TRANSFER_DIRECTION} ${target}"
    if [[ "${TRANSFER_DIRECTION}" == "push" ]]; then
      run_push "${tool}" "${target}"
    else
      run_pull "${tool}" "${target}"
    fi
    echo "ok" >"${status_dir}/$(target_label "${target}")"
    echo "[OK]   ${TRANSFER_DIRECTION} ${target}"
  ) || {
    echo "fail" >"${status_dir}/$(target_label "${target}")"
    echo "[FAIL] ${TRANSFER_DIRECTION} ${target}"
  } &
done

wait

failures=0
for status_file in "${status_dir}"/*; do
  [[ -e "${status_file}" ]] || continue
  if [[ "$(cat "${status_file}")" != "ok" ]]; then
    failures=$((failures + 1))
  fi
done

echo "Completed targets=${#targets[@]} failures=${failures}"
if [[ "${failures}" -gt 0 ]]; then
  exit 1
fi
