# Task Center Example Scripts

This repository now contains two layers of examples for OneOps task-center:

- practical starters
  - directly usable as task templates
  - focused on shell / ansible / terraform / tofu / terragrunt mainline scenarios
- importable OneOps assets
  - variable sets
  - task templates
  - scheduled tasks
- smoke examples
  - kept for runner regression and local validation

## Practical starters

- `shell/system-deep-inspection`
- `shell/system-quick-snapshot`
- `shell/batch-file-transfer`
- `shell/file-backup-rotate`
- `shell/cron-job-manage`
- `shell/periodic-pcap`
- `shell/linux-baseline-report`
- `shell/http-endpoint-check`
- `ansible/linux-deep-inspection`
- `ansible/batch-file-transfer`
- `ansible/file-backup-rotate`
- `ansible/cron-job-manage`
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
  - deep inspection
    - `playbook_path`: `shell/system-deep-inspection/run.sh`
  - quick snapshot
    - `playbook_path`: `shell/system-quick-snapshot/run.sh`
  - batch file transfer
    - `playbook_path`: `shell/batch-file-transfer/run.sh`
    - `arguments`: `./package.tar.gz /tmp/releases`
  - file backup rotate
    - `playbook_path`: `shell/file-backup-rotate/run.sh`
    - `arguments`: `/etc /opt/app/config.yaml`
  - cron job manage
    - `playbook_path`: `shell/cron-job-manage/run.sh`
  - periodic pcap
    - `playbook_path`: `shell/periodic-pcap/run.sh`
  - baseline report
    - `playbook_path`: `shell/linux-baseline-report/run.sh`
  - endpoint check
    - `playbook_path`: `shell/http-endpoint-check/run.sh`
    - `arguments`: `https://example.com/healthz`
- `ansible`
  - deep inspection
    - `playbook_path`: `ansible/linux-deep-inspection/site.yml`
    - `inventory_content`: copy `ansible/linux-deep-inspection/inventory.ini`
  - batch file transfer
    - `playbook_path`: `ansible/batch-file-transfer/site.yml`
    - `inventory_content`: copy `ansible/batch-file-transfer/inventory.ini`
    - `extra_vars_json`: `{"transfer_direction":"push","transfer_items_csv":"README.md","transfer_dest_dir":"/tmp/oneops-transfer"}`
  - file backup rotate
    - `playbook_path`: `ansible/file-backup-rotate/site.yml`
    - `inventory_content`: copy `ansible/file-backup-rotate/inventory.ini`
    - `extra_vars_json`: `{"backup_paths_csv":"/etc/hosts,/etc/resolv.conf","backup_retention_count":7}`
  - cron job manage
    - `playbook_path`: `ansible/cron-job-manage/site.yml`
    - `inventory_content`: copy `ansible/cron-job-manage/inventory.ini`
    - `extra_vars_json`: `{"cron_action":"ensure","cron_name":"ops-healthcheck","cron_job":"/usr/local/bin/healthcheck.sh >> /var/log/healthcheck.log 2>&1","cron_minute":"*/10"}`
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

- `batch-file-transfer` 依赖 SSH / rsync / scp，适合做文件上下发或日志回收。
- `periodic-pcap` 依赖 `tcpdump`，通常需要 root 或抓包权限。
- Some practical starters create real AWS resources. Review variables before apply.
- For private repository execution, configure `repo_url`, `repo_branch`, and `credential_code` in OneOps.
- For Agent execution, switch the run target to Agent and provide a valid `agent_code`.
- For local smoke validation, run `bash run-local-smoke.sh`.
- For OneOps task template batch import, see `templates/README.md`.

## Import Into OneOps

```bash
cd task-center-example-scripts
bash templates/import-variable-sets.sh
bash templates/import-to-oneops.sh
DEFAULT_PROJECT_ID=ops-demo bash templates/import-scheduled-tasks.sh
```

如果希望一次性导入：

```bash
cd task-center-example-scripts
DEFAULT_PROJECT_ID=ops-demo bash templates/bootstrap-oneops-assets.sh
```
