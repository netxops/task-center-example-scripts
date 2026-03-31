# Task Center Example Scripts

This repository now contains two layers of examples for OneOps task-center:

- practical starters
  - directly usable as task templates
  - focused on shell / ansible / terraform / tofu / terragrunt mainline scenarios
- smoke examples
  - kept for runner regression and local validation

## Practical starters

- `shell/linux-baseline-report`
- `shell/http-endpoint-check`
- `ansible/linux-baseline`
- `ansible/linux-service-status`
- `terraform/aws-s3-secure-bucket-starter`
- `terraform/aws-ec2-instance-starter`
- `tofu/aws-s3-secure-bucket-starter`
- `tofu/aws-ec2-instance-starter`
- `terragrunt/live-secure-bucket-starter`

## Smoke examples

- `shell/hello-world`
- `shell/with-args`
- `ansible/hello-world`
- `terraform/basic-output`
- `terraform/variable-output`
- `tofu/basic-output`
- `tofu/variable-output`
- `terragrunt/basic-stack`
- `terragrunt/variable-stack`

## Suggested mappings in OneOps

- `shell`
  - baseline report
    - `playbook_path`: `shell/linux-baseline-report/run.sh`
  - endpoint check
    - `playbook_path`: `shell/http-endpoint-check/run.sh`
    - `arguments`: `https://example.com/healthz`
- `ansible`
  - baseline
    - `playbook_path`: `ansible/linux-baseline/site.yml`
    - `inventory_content`: copy `ansible/linux-baseline/inventory.ini`
  - service status
    - `playbook_path`: `ansible/linux-service-status/site.yml`
    - `inventory_content`: copy `ansible/linux-service-status/inventory.ini`
    - `extra_vars_json`: `{"service_name":"sshd"}`
- `terraform`
  - secure bucket
    - `playbook_path`: `terraform/aws-s3-secure-bucket-starter`
    - `arguments`: `["-input=false","-var=aws_region=us-east-1","-var=bucket_name=change-me-oneops-secure-bucket"]`
  - ec2 instance
    - `playbook_path`: `terraform/aws-ec2-instance-starter`
    - `arguments`: `["-input=false","-var=aws_region=us-east-1","-var=name=oneops-demo-ec2"]`
- `tofu`
  - secure bucket
    - `playbook_path`: `tofu/aws-s3-secure-bucket-starter`
    - `arguments`: `["-input=false","-var=aws_region=us-east-1","-var=bucket_name=change-me-oneops-tofu-bucket"]`
  - ec2 instance
    - `playbook_path`: `tofu/aws-ec2-instance-starter`
    - `arguments`: `["-input=false","-var=aws_region=us-east-1","-var=name=oneops-demo-ec2"]`
- `terragrunt`
  - live secure bucket
    - `playbook_path`: `terragrunt/live-secure-bucket-starter/non-prod/us-east-1/ops-secure-bucket`
    - `arguments`: `["plan","-input=false","-var=bucket_name=change-me-non-prod-us-east-1-ops-bucket"]`

## Notes

- Some practical starters create real AWS resources. Review variables before apply.
- For private repository execution, configure `repo_url`, `repo_branch`, and `credential_code` in OneOps.
- For Agent execution, switch the run target to Agent and provide a valid `agent_code`.
- For local smoke validation, run `bash run-local-smoke.sh`.
- For OneOps task template batch import, see `templates/README.md`.
