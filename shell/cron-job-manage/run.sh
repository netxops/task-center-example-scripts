#!/usr/bin/env bash
set -euo pipefail

CRON_ACTION="${CRON_ACTION:-ensure}"
CRON_NAME="${CRON_NAME:-}"
CRON_SCHEDULE="${CRON_SCHEDULE:-*/5 * * * *}"
CRON_COMMAND="${CRON_COMMAND:-}"
CRON_TARGET="${CRON_TARGET:-crontab}"
CRON_RUN_AS="${CRON_RUN_AS:-root}"
CRON_FILE_DIR="${CRON_FILE_DIR:-/etc/cron.d}"

usage() {
  cat <<'EOF'
Usage:
  CRON_NAME=daily-healthcheck \
  CRON_SCHEDULE="*/10 * * * *" \
  CRON_COMMAND="/usr/local/bin/healthcheck.sh >> /var/log/healthcheck.log 2>&1" \
  bash shell/cron-job-manage/run.sh

Environment variables:
  CRON_ACTION     ensure, remove, or list. Default: ensure
  CRON_NAME       Managed job name
  CRON_SCHEDULE   Standard 5-field crontab schedule
  CRON_COMMAND    Command to execute
  CRON_TARGET     crontab or cron.d. Default: crontab
  CRON_RUN_AS     Used only for cron.d mode. Default: root
  CRON_FILE_DIR   Used only for cron.d mode. Default: /etc/cron.d
EOF
}

marker_begin() {
  echo "# oneops-managed:${CRON_NAME} begin"
}

marker_end() {
  echo "# oneops-managed:${CRON_NAME} end"
}

require_name() {
  if [[ -z "${CRON_NAME}" ]]; then
    echo "CRON_NAME is required"
    exit 2
  fi
}

manage_user_crontab() {
  local current filtered temp
  current="$(crontab -l 2>/dev/null || true)"
  filtered="$(printf '%s\n' "${current}" | awk -v begin="$(marker_begin)" -v end="$(marker_end)" '
    $0 == begin { skip=1; next }
    $0 == end { skip=0; next }
    !skip { print }
  ')"

  if [[ "${CRON_ACTION}" == "list" ]]; then
    printf '%s\n' "${current}"
    return
  fi

  temp="$(mktemp)"
  trap 'rm -f "${temp}"' RETURN
  printf '%s\n' "${filtered}" >"${temp}"

  if [[ "${CRON_ACTION}" == "ensure" ]]; then
    if [[ -z "${CRON_COMMAND}" ]]; then
      echo "CRON_COMMAND is required when CRON_ACTION=ensure"
      exit 2
    fi
    {
      echo "$(marker_begin)"
      echo "${CRON_SCHEDULE} ${CRON_COMMAND}"
      echo "$(marker_end)"
    } >>"${temp}"
  fi

  crontab "${temp}"
}

manage_cron_d() {
  local cron_file
  cron_file="${CRON_FILE_DIR%/}/oneops-${CRON_NAME}"

  if [[ "${CRON_ACTION}" == "list" ]]; then
    if [[ -f "${cron_file}" ]]; then
      cat "${cron_file}"
    else
      echo "cron file not found: ${cron_file}"
    fi
    return
  fi

  if [[ "${CRON_ACTION}" == "remove" ]]; then
    rm -f "${cron_file}"
    return
  fi

  if [[ -z "${CRON_COMMAND}" ]]; then
    echo "CRON_COMMAND is required when CRON_ACTION=ensure"
    exit 2
  fi

  mkdir -p "${CRON_FILE_DIR}"
  cat >"${cron_file}" <<EOF
# oneops-managed:${CRON_NAME}
${CRON_SCHEDULE} ${CRON_RUN_AS} ${CRON_COMMAND}
EOF
  chmod 0644 "${cron_file}"
}

if [[ "${CRON_ACTION}" != "ensure" && "${CRON_ACTION}" != "remove" && "${CRON_ACTION}" != "list" ]]; then
  usage
  exit 2
fi

if [[ "${CRON_ACTION}" != "list" ]]; then
  require_name
fi

case "${CRON_TARGET}" in
  crontab)
    manage_user_crontab
    ;;
  cron.d)
    require_name
    manage_cron_d
    ;;
  *)
    echo "CRON_TARGET must be crontab or cron.d"
    exit 2
    ;;
esac

echo "cron action completed: action=${CRON_ACTION} target=${CRON_TARGET} name=${CRON_NAME:-all}"
