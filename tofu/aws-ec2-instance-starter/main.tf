provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = merge(
    {
      ManagedBy = "OneOps"
      Template  = "tofu-aws-ec2-instance-starter"
      Name      = var.name
    },
    var.additional_tags,
  )
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = length(var.security_group_ids) > 0 ? var.security_group_ids : null
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip_address

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted   = true
    volume_size = var.root_volume_size
    volume_type = "gp3"
    tags        = local.common_tags
  }

  tags = local.common_tags
}

