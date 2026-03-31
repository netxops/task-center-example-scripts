# AWS S3 Secure Bucket Starter

基于常见企业基线，创建一个默认开启以下能力的 S3 Bucket：

- 公网访问阻断
- 版本控制
- 服务端加密
- 标准化标签

## 用法

```bash
terraform -chdir=terraform/aws-s3-secure-bucket-starter init
terraform -chdir=terraform/aws-s3-secure-bucket-starter plan \
  -var='aws_region=us-east-1' \
  -var='bucket_name=change-me-oneops-secure-bucket'
```

