# OneOps Task Templates

这个目录提供一批更偏实战的 OneOps 任务模板，不再以 hello-world 为主。

## 文件说明

- `task-template-catalog.json`
  - 模板清单
  - 适合批量导入到 `/platform/task-templates`
- `import-to-oneops.sh`
  - 模板导入脚本
  - 支持按模板名称自动 create / update

## 当前边界

当前 OneOps 任务模板 API 只能保存这些字段：

- `name`
- `description`
- `app_type`
- `playbook_path`
- `repo_url`
- `repo_branch`
- `extra_vars_json`

当前还不能通过模板直接保存：

- `arguments`
- `inventory_content`
- `run_on_agent`
- `agent_code`

所以导入模板后，创建任务时仍建议补充：

- Shell / Terraform / Tofu / Terragrunt 的 `arguments`
- Ansible 的 `inventory_content`
- Agent 执行位置与 `agent_code`

## 默认推荐导入

- `task-center-shell-system-deep-inspection`
- `task-center-shell-system-quick-snapshot`
- `task-center-shell-batch-file-transfer`
- `task-center-shell-file-backup-rotate`
- `task-center-shell-cron-job-manage`
- `task-center-shell-periodic-pcap`
- `task-center-shell-linux-baseline-report`
- `task-center-shell-http-endpoint-check`
- `task-center-ansible-linux-deep-inspection`
- `task-center-ansible-batch-file-transfer`
- `task-center-ansible-file-backup-rotate`
- `task-center-ansible-cron-job-manage`
- `task-center-ansible-linux-baseline`
- `task-center-ansible-linux-service-status`
- `task-center-terraform-aws-s3-secure-bucket`
- `task-center-terraform-aws-ec2-instance`
- `task-center-tofu-aws-s3-secure-bucket`
- `task-center-tofu-aws-ec2-instance`
- `task-center-terragrunt-live-secure-bucket`

说明：

- 这些模板里有一部分会创建真实 AWS 资源，不再只是 smoke 样例。
- 仓库里旧的 hello-world / basic-output / variable-output 目录仍保留，主要用于链路回归和本地冒烟。

## 导入命令

```bash
cd task-center-example-scripts
bash templates/import-to-oneops.sh
```

常用环境变量：

```bash
API_BASE=http://127.0.0.1:8080/api/v1
AUTH_TOKEN=abc123
CATALOG_PATH=templates/task-template-catalog.json
DRY_RUN=true
```
