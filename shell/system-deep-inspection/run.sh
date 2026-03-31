#!/usr/bin/env bash
set -euo pipefail

INSPECT_TOP_N="${INSPECT_TOP_N:-8}"
INSPECT_JOURNAL_LINES="${INSPECT_JOURNAL_LINES:-80}"
SHOW_JOURNAL_ERRORS="${SHOW_JOURNAL_ERRORS:-true}"
SHOW_NETWORK_DETAILS="${SHOW_NETWORK_DETAILS:-true}"

section() {
  printf '\n==== %s ====\n' "$1"
}

print_or_na() {
  local label="$1"
  local value="$2"
  printf '%-20s %s\n' "${label}:" "${value:-n/a}"
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

section "host"
print_or_na "hostname" "$(hostname 2>/dev/null || true)"
print_or_na "fqdn" "$(hostname -f 2>/dev/null || true)"
print_or_na "kernel" "$(uname -srmo 2>/dev/null || true)"
print_or_na "uptime" "$(uptime -p 2>/dev/null || uptime 2>/dev/null || true)"
print_or_na "last_boot" "$(who -b 2>/dev/null | awk '{print $3, $4}')"
print_or_na "current_time" "$(date '+%F %T %Z' 2>/dev/null || true)"

section "os-release"
if [[ -f /etc/os-release ]]; then
  cat /etc/os-release
else
  echo "/etc/os-release not found"
fi

section "cpu-memory"
print_or_na "cpu_cores" "$(nproc 2>/dev/null || true)"
print_or_na "load_avg" "$(cut -d' ' -f1-3 /proc/loadavg 2>/dev/null || true)"
if has_cmd free; then
  free -h
else
  echo "free command not available"
fi

section "filesystem"
if has_cmd df; then
  df -hPT -x tmpfs -x devtmpfs 2>/dev/null || df -hPT 2>/dev/null || true
else
  echo "df command not available"
fi

section "inode"
if has_cmd df; then
  df -hi -x tmpfs -x devtmpfs 2>/dev/null || df -hi 2>/dev/null || true
else
  echo "df command not available"
fi

section "block-devices"
if has_cmd lsblk; then
  lsblk -o NAME,FSTYPE,SIZE,TYPE,MOUNTPOINTS 2>/dev/null || true
else
  echo "lsblk command not available"
fi

section "network-summary"
if has_cmd ip; then
  ip -brief address show 2>/dev/null || true
  ip route show default 2>/dev/null || true
else
  print_or_na "ip_addresses" "$(hostname -I 2>/dev/null || true)"
fi

if [[ "${SHOW_NETWORK_DETAILS}" == "true" ]]; then
  section "network-details"
  if has_cmd ip; then
    ip route show 2>/dev/null || true
  fi
  if has_cmd ss; then
    ss -s 2>/dev/null || true
  fi
fi

section "failed-services"
if has_cmd systemctl; then
  systemctl --failed --no-pager --plain 2>/dev/null || true
else
  echo "systemctl command not available"
fi

section "top-cpu"
ps -eo pid,user,%cpu,%mem,etime,comm --sort=-%cpu 2>/dev/null | head -n "$((INSPECT_TOP_N + 1))" || true

section "top-memory"
ps -eo pid,user,%cpu,%mem,etime,comm --sort=-%mem 2>/dev/null | head -n "$((INSPECT_TOP_N + 1))" || true

section "listening-ports"
if has_cmd ss; then
  ss -lntup 2>/dev/null | head -n 50 || true
else
  echo "ss command not available"
fi

section "recent-logins"
if has_cmd last; then
  last -a -n 10 2>/dev/null || true
else
  echo "last command not available"
fi

if [[ "${SHOW_JOURNAL_ERRORS}" == "true" ]]; then
  section "journal-errors"
  if has_cmd journalctl; then
    journalctl -p err -n "${INSPECT_JOURNAL_LINES}" --no-pager 2>/dev/null || true
  else
    echo "journalctl command not available"
  fi
fi
