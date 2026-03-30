terraform {
  required_version = ">= 1.5.0"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "service_name" {
  type    = string
  default = "task-center"
}

variable "operator" {
  type    = string
  default = "oneops"
}

locals {
  summary = {
    tool         = "tofu"
    environment  = var.environment
    service_name = var.service_name
    operator     = var.operator
  }
}

output "message" {
  value = "${var.service_name} is ready in ${var.environment} by ${var.operator}"
}

output "summary" {
  value = local.summary
}
