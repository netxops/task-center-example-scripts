# AWS S3 Secure Bucket Starter For OpenTofu

和 Terraform 版本一致，用于在 OpenTofu 执行链路里快速落一个具备企业基础安全配置的 S3 Bucket。

## 用法

```bash
tofu -chdir=tofu/aws-s3-secure-bucket-starter init
tofu -chdir=tofu/aws-s3-secure-bucket-starter plan \
  -var='aws_region=us-east-1' \
  -var='bucket_name=change-me-oneops-secure-bucket'
```

