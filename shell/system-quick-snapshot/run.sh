#!/usr/bin/env bash
set -euo pipefail

section() {
  printf '\n==== %s ====\n' "$1"
}

print_or_na() {
  local label="$1"
  local value="$2"
  printf '%-18s %s\n' "${label}:" "${value:-n/a}"
}

section "summary"
print_or_na "hostname" "$(hostname 2>/dev/null || true)"
print_or_na "time" "$(date '+%F %T %Z' 2>/dev/null || true)"
print_or_na "kernel" "$(uname -srmo 2>/dev/null || true)"
print_or_na "uptime" "$(uptime -p 2>/dev/null || uptime 2>/dev/null || true)"
print_or_na "load" "$(cut -d' ' -f1-3 /proc/loadavg 2>/dev/null || true)"
print_or_na "ipv4" "$(hostname -I 2>/dev/null | xargs || true)"

section "cpu-memory"
if command -v free >/dev/null 2>&1; then
  free -h
else
  echo "free command not available"
fi

section "disk-top"
if command -v df >/dev/null 2>&1; then
  df -hPT -x tmpfs -x devtmpfs 2>/dev/null | head -n 10 || df -hPT 2>/dev/null | head -n 10 || true
else
  echo "df command not available"
fi

section "failed-services"
if command -v systemctl >/dev/null 2>&1; then
  systemctl list-units --failed --no-pager --plain 2>/dev/null || true
else
  echo "systemctl command not available"
fi

section "top-processes"
ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu 2>/dev/null | head -n 6 || true
