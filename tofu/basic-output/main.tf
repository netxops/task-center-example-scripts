terraform {
  required_version = ">= 1.5.0"
}

locals {
  example_message = "tofu example from github"
}

output "message" {
  value = local.example_message
}
