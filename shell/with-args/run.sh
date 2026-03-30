#!/usr/bin/env bash
set -euo pipefail

target_name="${1:-OneOps}"
task_message="${TASK_MESSAGE:-shell example with args}"
task_mode="${TASK_MODE:-smoke}"

echo "tool=shell"
echo "message=${task_message}"
echo "target_name=${target_name}"
echo "task_mode=${task_mode}"
echo "hostname=$(hostname)"
echo "pwd=$(pwd)"
