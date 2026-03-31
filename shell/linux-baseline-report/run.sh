#!/usr/bin/env bash
set -euo pipefail

TOP_N="${BASELINE_TOP_N:-5}"

section() {
  printf '\n==== %s ====\n' "$1"
}

print_or_na() {
  local label="$1"
  local value="$2"
  printf '%-20s %s\n' "${label}:" "${value:-n/a}"
}

section "host"
print_or_na "hostname" "$(hostname 2>/dev/null || true)"
print_or_na "fqdn" "$(hostname -f 2>/dev/null || true)"
print_or_na "kernel" "$(uname -srmo 2>/dev/null || true)"
print_or_na "uptime" "$(uptime -p 2>/dev/null || uptime 2>/dev/null || true)"
print_or_na "last_boot" "$(who -b 2>/dev/null | awk '{print $3, $4}')"

section "cpu-memory"
print_or_na "cpu_cores" "$(nproc 2>/dev/null || true)"
print_or_na "load_avg" "$(cut -d' ' -f1-3 /proc/loadavg 2>/dev/null || true)"
if command -v free >/dev/null 2>&1; then
  free -h
else
  echo "free command not available"
fi

section "disk"
if command -v df >/dev/null 2>&1; then
  df -hPT -x tmpfs -x devtmpfs 2>/dev/null || df -hPT 2>/dev/null || true
else
  echo "df command not available"
fi

section "network"
if command -v ip >/dev/null 2>&1; then
  ip -brief address show 2>/dev/null || true
else
  print_or_na "ip_addresses" "$(hostname -I 2>/dev/null || true)"
fi

section "top-cpu"
ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu 2>/dev/null | head -n "$((TOP_N + 1))" || true

section "top-memory"
ps -eo pid,user,%cpu,%mem,comm --sort=-%mem 2>/dev/null | head -n "$((TOP_N + 1))" || true

section "listening-ports"
if command -v ss >/dev/null 2>&1; then
  ss -lntup 2>/dev/null | head -n 25 || true
else
  echo "ss command not available"
fi

