#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

run_step() {
  local title="$1"
  shift
  echo
  echo "==> ${title}"
  "$@"
}

run_step "shell hello-world" bash "${ROOT_DIR}/shell/hello-world/run.sh"
run_step "shell with-args" env TASK_MESSAGE="smoke run" TASK_MODE="local" bash "${ROOT_DIR}/shell/with-args/run.sh" "demo-target"
run_step "ansible hello-world" ansible-playbook -i "${ROOT_DIR}/ansible/hello-world/inventory.ini" "${ROOT_DIR}/ansible/hello-world/site.yml" -e '{"smoke_message":"ansible smoke run"}'

run_step \
  "terraform basic-output plan" \
  env TF_DATA_DIR="${TMP_DIR}/terraform-basic-data" terraform -chdir="${ROOT_DIR}/terraform/basic-output" init -backend=false -input=false
run_step \
  "terraform variable-output plan" \
  env TF_DATA_DIR="${TMP_DIR}/terraform-vars-data" terraform -chdir="${ROOT_DIR}/terraform/variable-output" plan -input=false -lock=false -var='environment=smoke' -var='service_name=demo-service' -var='operator=local-runner'

run_step \
  "tofu basic-output plan" \
  env TF_DATA_DIR="${TMP_DIR}/tofu-basic-data" tofu -chdir="${ROOT_DIR}/tofu/basic-output" init -backend=false -input=false
run_step \
  "tofu variable-output plan" \
  env TF_DATA_DIR="${TMP_DIR}/tofu-vars-data" tofu -chdir="${ROOT_DIR}/tofu/variable-output" plan -input=false -lock=false -var='environment=smoke' -var='service_name=demo-service' -var='operator=local-runner'

run_step \
  "terragrunt basic-stack plan" \
  env TF_DATA_DIR="${TMP_DIR}/terragrunt-basic-data" TG_DOWNLOAD_DIR="${TMP_DIR}/terragrunt-basic-cache" terragrunt run --all plan --working-dir "${ROOT_DIR}/terragrunt/basic-stack" --non-interactive
run_step \
  "terragrunt variable-stack plan" \
  env TF_DATA_DIR="${TMP_DIR}/terragrunt-vars-data" TG_DOWNLOAD_DIR="${TMP_DIR}/terragrunt-vars-cache" terragrunt run --all plan --working-dir "${ROOT_DIR}/terragrunt/variable-stack" --non-interactive

echo
echo "All task-center smoke checks passed."
