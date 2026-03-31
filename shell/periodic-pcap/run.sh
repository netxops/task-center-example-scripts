#!/usr/bin/env bash
set -euo pipefail

PCAP_INTERFACE="${PCAP_INTERFACE:-any}"
PCAP_OUTPUT_DIR="${PCAP_OUTPUT_DIR:-/tmp/oneops-pcaps}"
PCAP_FILE_PREFIX="${PCAP_FILE_PREFIX:-capture}"
PCAP_ROTATE_SECONDS="${PCAP_ROTATE_SECONDS:-300}"
PCAP_ROTATE_COUNT="${PCAP_ROTATE_COUNT:-12}"
PCAP_SNAPLEN="${PCAP_SNAPLEN:-0}"
PCAP_FILTER="${PCAP_FILTER:-}"
PCAP_EXTRA_ARGS="${PCAP_EXTRA_ARGS:-}"

usage() {
  cat <<'EOF'
Usage:
  bash shell/periodic-pcap/run.sh

Environment variables:
  PCAP_INTERFACE       Capture interface. Default: any
  PCAP_OUTPUT_DIR      Output directory. Default: /tmp/oneops-pcaps
  PCAP_FILE_PREFIX     File prefix. Default: capture
  PCAP_ROTATE_SECONDS  Rotate interval in seconds. Default: 300
  PCAP_ROTATE_COUNT    How many files to keep in ring buffer. Default: 12
  PCAP_SNAPLEN         Snap length. Default: 0
  PCAP_FILTER          Optional tcpdump filter, for example: port 53
  PCAP_EXTRA_ARGS      Optional extra tcpdump args
EOF
}

if ! command -v tcpdump >/dev/null 2>&1; then
  echo "tcpdump command not available"
  exit 1
fi

mkdir -p "${PCAP_OUTPUT_DIR}"

output_pattern="${PCAP_OUTPUT_DIR%/}/${PCAP_FILE_PREFIX}-%Y%m%d-%H%M%S.pcap"

cmd=(
  tcpdump
  -i "${PCAP_INTERFACE}"
  -nn
  -s "${PCAP_SNAPLEN}"
  -G "${PCAP_ROTATE_SECONDS}"
  -W "${PCAP_ROTATE_COUNT}"
  -w "${output_pattern}"
)

if [[ -n "${PCAP_EXTRA_ARGS}" ]]; then
  # shellcheck disable=SC2206
  extra_args=( ${PCAP_EXTRA_ARGS} )
  cmd+=("${extra_args[@]}")
fi

if [[ -n "${PCAP_FILTER}" ]]; then
  cmd+=("${PCAP_FILTER}")
fi

echo "Starting periodic capture"
echo "output_pattern=${output_pattern}"
echo "interface=${PCAP_INTERFACE} rotate_seconds=${PCAP_ROTATE_SECONDS} rotate_count=${PCAP_ROTATE_COUNT}"
printf 'command='
printf '%q ' "${cmd[@]}"
printf '\n'

"${cmd[@]}"
