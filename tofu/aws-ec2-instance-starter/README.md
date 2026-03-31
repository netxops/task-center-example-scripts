# AWS EC2 Instance Starter For OpenTofu

OpenTofu 版 EC2 Starter，适合把已有 Terraform 执行习惯切换到 Tofu 时作为起步模板。

## 用法

```bash
tofu -chdir=tofu/aws-ec2-instance-starter init
tofu -chdir=tofu/aws-ec2-instance-starter plan \
  -var='aws_region=us-east-1' \
  -var='name=oneops-demo-ec2'
```

