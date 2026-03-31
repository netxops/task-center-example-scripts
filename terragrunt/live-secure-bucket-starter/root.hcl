locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment_name = local.account_vars.locals.environment_name
  owner            = local.account_vars.locals.owner
  aws_region       = local.region_vars.locals.aws_region
}

generate "provider" {
  path      = "provider.generated.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
}
EOF
}

inputs = {
  aws_region  = local.aws_region
  environment = local.environment_name
  owner       = local.owner
}

