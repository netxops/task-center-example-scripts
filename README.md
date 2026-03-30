# Task Center Example Scripts

This repository contains small, safe examples for OneOps task-center.

Structure:

- `shell/hello-world`
- `shell/with-args`
- `ansible/hello-world`
- `terraform/basic-output`
- `terraform/variable-output`
- `tofu/basic-output`
- `tofu/variable-output`
- `terragrunt/basic-stack`
- `terragrunt/variable-stack`

Suggested mappings in the OneOps task creation UI:

- `shell`
  - `playbook_path`: leave empty
  - `arguments`: `bash shell/hello-world/run.sh`
  - script-path mode
    - `playbook_path`: `shell/hello-world/run.sh`
    - `arguments`: leave empty
  - args example
    - `playbook_path`: `shell/with-args/run.sh`
    - `arguments`: `demo-target`
    - optional env: `TASK_MESSAGE=hello from oneops`, `TASK_MODE=smoke`
- `ansible`
  - `playbook_path`: `ansible/hello-world/site.yml`
  - `inventory_content`: copy `ansible/hello-world/inventory.ini`
- `terraform`
  - `playbook_path`: `terraform/basic-output`
  - `arguments`: `["-input=false"]`
  - variable example
    - `playbook_path`: `terraform/variable-output`
    - `arguments`: `["-input=false","-var=environment=smoke","-var=service_name=demo-service","-var=operator=oneops-ui"]`
- `tofu`
  - `playbook_path`: `tofu/basic-output`
  - `arguments`: `["-input=false"]`
  - variable example
    - `playbook_path`: `tofu/variable-output`
    - `arguments`: `["-input=false","-var=environment=smoke","-var=service_name=demo-service","-var=operator=oneops-ui"]`
- `terragrunt`
  - `playbook_path`: `terragrunt/basic-stack`
  - `arguments`: `["-input=false"]`
  - variable example
    - `playbook_path`: `terragrunt/variable-stack`
    - `arguments`: `["-input=false"]`

Notes:

- All examples only produce local outputs and do not create real infrastructure.
- For private repository execution, configure `repo_url`, `repo_branch`, and `credential_code` in OneOps.
- For Agent execution, switch the run target to Agent and provide a valid `agent_code`.
- For local verification, run `bash run-local-smoke.sh`.
