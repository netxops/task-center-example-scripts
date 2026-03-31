# AWS EC2 Instance Starter

提供一个现代化、可直接扩展的 EC2 单机模板，默认包含：

- Amazon Linux 2023 AMI 自动发现
- IMDSv2 强制开启
- 根盘加密与标准标签

## 用法

```bash
terraform -chdir=terraform/aws-ec2-instance-starter init
terraform -chdir=terraform/aws-ec2-instance-starter plan \
  -var='aws_region=us-east-1' \
  -var='name=oneops-demo-ec2'
```

如果你的 AWS 账号没有默认子网，建议显式传入 `subnet_id` 和 `security_group_ids`。

