#!/usr/bin/env bash
set -euo pipefail

BACKUP_ROOT="${BACKUP_ROOT:-/tmp/oneops-file-backups}"
BACKUP_PREFIX="${BACKUP_PREFIX:-$(hostname -s 2>/dev/null || echo local)}"
BACKUP_RETENTION_COUNT="${BACKUP_RETENTION_COUNT:-7}"
BACKUP_EXCLUDE_FILE="${BACKUP_EXCLUDE_FILE:-}"

usage() {
  cat <<'EOF'
Usage:
  bash shell/file-backup-rotate/run.sh /etc /opt/app/config.yaml

Environment variables:
  BACKUP_ROOT             Backup directory. Default: /tmp/oneops-file-backups
  BACKUP_PREFIX           Archive name prefix. Default: current hostname
  BACKUP_RETENTION_COUNT  How many archives to keep. Default: 7
  BACKUP_EXCLUDE_FILE     Optional tar exclude file
EOF
}

if [[ "$#" -eq 0 ]]; then
  usage
  exit 2
fi

mkdir -p "${BACKUP_ROOT}"

timestamp="$(date '+%Y%m%d-%H%M%S')"
archive_path="${BACKUP_ROOT%/}/${BACKUP_PREFIX}-${timestamp}.tar.gz"
manifest_path="${archive_path%.tar.gz}.manifest.txt"

tar_args=(-czf "${archive_path}")
if [[ -n "${BACKUP_EXCLUDE_FILE}" ]]; then
  tar_args+=(--exclude-from "${BACKUP_EXCLUDE_FILE}")
fi

echo "Creating backup archive: ${archive_path}"
tar "${tar_args[@]}" "$@"

{
  echo "archive=${archive_path}"
  echo "created_at=$(date '+%F %T %Z')"
  echo "host=$(hostname 2>/dev/null || true)"
  echo "sources=$*"
} >"${manifest_path}"

if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "${archive_path}" >"${archive_path}.sha256"
fi

mapfile -t old_archives < <(find "${BACKUP_ROOT}" -maxdepth 1 -type f -name "${BACKUP_PREFIX}-*.tar.gz" | sort -r)
if [[ "${#old_archives[@]}" -gt "${BACKUP_RETENTION_COUNT}" ]]; then
  for archive in "${old_archives[@]:${BACKUP_RETENTION_COUNT}}"; do
    echo "Removing old archive: ${archive}"
    rm -f "${archive}" "${archive%.tar.gz}.manifest.txt" "${archive}.sha256"
  done
fi

echo "Backup completed: ${archive_path}"
