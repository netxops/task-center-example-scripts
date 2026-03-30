terraform {
  required_version = ">= 1.5.0"
}

variable "environment" {
  type = string
}

variable "service_name" {
  type = string
}

variable "operator" {
  type = string
}

output "message" {
  value = "${var.service_name} is ready in ${var.environment} by ${var.operator}"
}

output "summary" {
  value = {
    tool         = "terragrunt"
    environment  = var.environment
    operator     = var.operator
    service_name = var.service_name
  }
}
