#!/usr/bin/env bash
set -euo pipefail

EXPECTED_STATUS="${EXPECTED_STATUS:-200}"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-10}"
RETRY_COUNT="${RETRY_COUNT:-0}"
METHOD="${METHOD:-GET}"
BODY_CONTAINS="${BODY_CONTAINS:-}"
SHOW_BODY="${SHOW_BODY:-false}"

usage() {
  cat <<'EOF'
Usage:
  bash shell/http-endpoint-check/run.sh https://example.com [https://example.org]

Environment variables:
  EXPECTED_STATUS   Expected status code list, comma separated. Default: 200
  TIMEOUT_SECONDS   Curl timeout in seconds. Default: 10
  RETRY_COUNT       Curl retry count. Default: 0
  METHOD            HTTP method. Default: GET
  BODY_CONTAINS     Optional substring that must exist in response body
  SHOW_BODY         true/false, whether to print response body
EOF
}

status_matches() {
  local actual="$1"
  local expected_list="$2"
  local item
  IFS=',' read -r -a items <<<"${expected_list}"
  for item in "${items[@]}"; do
    if [[ "${actual}" == "${item// /}" ]]; then
      return 0
    fi
  done
  return 1
}

if [[ "$#" -eq 0 ]]; then
  usage
  exit 2
fi

failures=0

for url in "$@"; do
  body_file="$(mktemp)"
  trap 'rm -f "${body_file}"' EXIT

  curl_output="$(
    curl -sS \
      --location \
      --max-time "${TIMEOUT_SECONDS}" \
      --retry "${RETRY_COUNT}" \
      --request "${METHOD}" \
      --output "${body_file}" \
      --write-out '%{http_code} %{time_total} %{remote_ip}' \
      "${url}" 2>&1
  )" || {
    echo "[FAIL] ${url} curl_error=${curl_output}"
    failures=$((failures + 1))
    rm -f "${body_file}"
    continue
  }

  http_code="$(awk '{print $1}' <<<"${curl_output}")"
  total_time="$(awk '{print $2}' <<<"${curl_output}")"
  remote_ip="$(awk '{print $3}' <<<"${curl_output}")"

  if ! status_matches "${http_code}" "${EXPECTED_STATUS}"; then
    echo "[FAIL] ${url} status=${http_code} expected=${EXPECTED_STATUS} remote_ip=${remote_ip} total_time=${total_time}s"
    failures=$((failures + 1))
    if [[ "${SHOW_BODY}" == "true" ]]; then
      echo "----- body -----"
      cat "${body_file}"
    fi
    rm -f "${body_file}"
    continue
  fi

  if [[ -n "${BODY_CONTAINS}" ]] && ! grep -Fq "${BODY_CONTAINS}" "${body_file}"; then
    echo "[FAIL] ${url} status=${http_code} body_missing=${BODY_CONTAINS}"
    failures=$((failures + 1))
    if [[ "${SHOW_BODY}" == "true" ]]; then
      echo "----- body -----"
      cat "${body_file}"
    fi
    rm -f "${body_file}"
    continue
  fi

  echo "[OK]   ${url} status=${http_code} remote_ip=${remote_ip} total_time=${total_time}s"
  if [[ "${SHOW_BODY}" == "true" ]]; then
    echo "----- body -----"
    cat "${body_file}"
  fi
  rm -f "${body_file}"
done

if [[ "${failures}" -gt 0 ]]; then
  exit 1
fi

