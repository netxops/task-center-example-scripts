variable "aws_region" {
  description = "AWS region used by the provider."
  type        = string
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "owner" {
  description = "Owner tag."
  type        = string
}

variable "force_destroy" {
  description = "Whether to delete bucket objects when destroying the bucket."
  type        = bool
  default     = false
}

variable "additional_tags" {
  description = "Additional tags applied to the bucket."
  type        = map(string)
  default     = {}
}

