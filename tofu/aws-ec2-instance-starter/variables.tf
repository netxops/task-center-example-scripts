variable "aws_region" {
  description = "AWS region used by the provider."
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "EC2 instance Name tag."
  type        = string
  default     = "oneops-ec2-starter"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Optional subnet id. Leave null to use the account default behavior."
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "Optional security groups attached to the instance."
  type        = list(string)
  default     = []
}

variable "key_name" {
  description = "Optional EC2 key pair name."
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address."
  type        = bool
  default     = true
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 20
}

variable "ami_owner" {
  description = "AMI owner for Amazon Linux image discovery."
  type        = string
  default     = "amazon"
}

variable "additional_tags" {
  description = "Additional tags applied to the instance."
  type        = map(string)
  default     = {}
}

