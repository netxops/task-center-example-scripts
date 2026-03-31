include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/s3-secure-bucket"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

inputs = {
  bucket_name = "change-me-${local.account_vars.locals.environment_name}-${local.region_vars.locals.aws_region}-ops-bucket"
}

