# Task Center Example Scripts

This repository contains small, safe examples for OneOps task-center.

Structure:

- `shell/hello-world`
- `ansible/hello-world`
- `terraform/basic-output`
- `tofu/basic-output`
- `terragrunt/basic-stack`

Suggested mappings in the OneOps task creation UI:

- `shell`
  - `playbook_path`: leave empty
  - `arguments`: `bash shell/hello-world/run.sh`
- `ansible`
  - `playbook_path`: `ansible/hello-world/site.yml`
  - `inventory_content`: copy `ansible/hello-world/inventory.ini`
- `terraform`
  - `playbook_path`: `terraform/basic-output`
  - `arguments`: `["-input=false"]`
- `tofu`
  - `playbook_path`: `tofu/basic-output`
  - `arguments`: `["-input=false"]`
- `terragrunt`
  - `playbook_path`: `terragrunt/basic-stack`
  - `arguments`: `["-input=false"]`

Notes:

- All examples only produce local outputs and do not create real infrastructure.
- For private repository execution, configure `repo_url`, `repo_branch`, and `credential_code` in OneOps.
- For Agent execution, switch the run target to Agent and provide a valid `agent_code`.
