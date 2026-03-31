variable "aws_region" {
  description = "AWS region used by the provider."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name."
  type        = string
}

variable "environment" {
  description = "Environment tag for the bucket."
  type        = string
  default     = "non-prod"
}

variable "force_destroy" {
  description = "Whether to delete bucket objects when destroying the bucket."
  type        = bool
  default     = false
}

variable "enable_versioning" {
  description = "Enable bucket versioning."
  type        = bool
  default     = true
}

variable "enable_kms" {
  description = "Use SSE-KMS instead of AES256."
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "Optional KMS key id or ARN used when enable_kms is true."
  type        = string
  default     = null
}

variable "additional_tags" {
  description = "Additional tags applied to the bucket."
  type        = map(string)
  default     = {}
}

