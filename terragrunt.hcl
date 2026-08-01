locals {
  account_config = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env_config     = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  account_name   = local.account_config.locals.account_name
  aws_account_id = local.account_config.locals.aws_account_id
  role_name      = local.account_config.locals.role_name

  state_bucket      = local.account_config.locals.state_bucket
  state_region      = local.account_config.locals.state_region
  state_kms_key_arn = local.account_config.locals.state_kms_key_arn

  environment  = local.env_config.locals.environment
  aws_region   = local.env_config.locals.aws_region
  project_name = local.env_config.locals.project_name
  customer     = local.env_config.locals.customer

  name_prefix = "${local.customer}-${local.project_name}-${local.environment}"

  common_tags = {
    Customer      = local.customer
    Project       = local.project_name
    Environment   = local.environment
    AWSAccount    = local.account_name
    ManagedBy     = "Terraform"
    Orchestration = "Terragrunt"
  }
}

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket       = local.state_bucket
    key          = "${local.customer}/${local.project_name}/${local.environment}/${local.aws_region}/${path_relative_to_include()}/terraform.tfstate"
    region       = local.state_region
    encrypt      = true
    kms_key_id   = local.state_kms_key_arn
    use_lockfile = true

    disable_bucket_update = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.80, < 7.0"
    }
  }
}

provider "aws" {
  region = "${local.aws_region}"

  default_tags {
    tags = ${jsonencode(local.common_tags)}
  }
}
EOF
}

inputs = {
  name_prefix = local.name_prefix
  environment = local.environment
  aws_region  = local.aws_region
  common_tags = local.common_tags
}
