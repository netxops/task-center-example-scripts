# Terragrunt Live Secure Bucket Starter

一个尽量轻量的 Terragrunt live 目录起步模板，保留主线结构：

- `root.hcl` 统一 provider 与公共输入
- `non-prod/account.hcl` 环境级配置
- `non-prod/us-east-1/region.hcl` 区域级配置
- `non-prod/us-east-1/ops-secure-bucket/terragrunt.hcl` 业务单元
- `modules/s3-secure-bucket` 本地 module

## 用法

```bash
terragrunt -chdir=terragrunt/live-secure-bucket-starter/non-prod/us-east-1/ops-secure-bucket init
terragrunt -chdir=terragrunt/live-secure-bucket-starter/non-prod/us-east-1/ops-secure-bucket plan \
  -var='bucket_name=change-me-non-prod-us-east-1-ops-bucket'
```

