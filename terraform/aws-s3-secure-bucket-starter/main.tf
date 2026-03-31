provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = merge(
    {
      ManagedBy   = "OneOps"
      Template    = "terraform-aws-s3-secure-bucket-starter"
      Environment = var.environment
    },
    var.additional_tags,
  )
}

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
  tags          = local.common_tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.enable_kms ? "aws:kms" : "AES256"
      kms_master_key_id = var.enable_kms ? var.kms_key_id : null
    }
  }
}

