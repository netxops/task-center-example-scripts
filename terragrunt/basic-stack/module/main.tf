terraform {
  required_version = ">= 1.5.0"
}

variable "example_message" {
  type = string
}

output "message" {
  value = var.example_message
}
