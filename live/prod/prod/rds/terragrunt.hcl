include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
}

terraform {
  source = "../../../../modules/rds"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    database_subnet_ids = ["subnet-00000000000000003", "subnet-00000000000000004"]
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "security_group" {
  config_path = "../security-group"

  mock_outputs = {
    database_security_group_id = "sg-00000000000000001"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "kms" {
  config_path = "../kms"

  mock_outputs = {
    key_arns = {
      rds     = "arn:aws:kms:ap-south-1:111111111111:key/mock-rds"
      secrets = "arn:aws:kms:ap-south-1:111111111111:key/mock-secrets"
    }
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  database_subnet_ids        = dependency.vpc.outputs.database_subnet_ids
  database_security_group_id = dependency.security_group.outputs.database_security_group_id
  rds_kms_key_arn            = dependency.kms.outputs.key_arns.rds
  secrets_kms_key_arn        = dependency.kms.outputs.key_arns.secrets

  instance_class          = local.env.locals.rds_instance_class
  multi_az                = local.env.locals.rds_multi_az
  backup_retention_period = local.env.locals.rds_backup_retention
  deletion_protection     = local.env.locals.rds_deletion_protection
  skip_final_snapshot     = local.env.locals.rds_skip_final_snapshot
}
