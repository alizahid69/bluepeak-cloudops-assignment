include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
}

terraform {
  source = "../../../../modules/ec2"
}

dependency "security_group" {
  config_path = "../security-group"

  mock_outputs = {
    application_security_group_id = "sg-00000000000000002"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "kms" {
  config_path = "../kms"

  mock_outputs = {
    key_arns = {
      ebs     = "arn:aws:kms:ap-south-1:111111111111:key/mock-ebs"
      ssm     = "arn:aws:kms:ap-south-1:111111111111:key/mock-ssm"
      secrets = "arn:aws:kms:ap-south-1:111111111111:key/mock-secrets"
      logs    = "arn:aws:kms:ap-south-1:111111111111:key/mock-logs"
    }
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "rds" {
  config_path = "../rds"

  mock_outputs = {
    db_endpoint           = "mock-db.internal"
    db_port               = 5432
    database_name         = "counterdb"
    master_user_secret_arn = "arn:aws:secretsmanager:ap-south-1:111111111111:secret:mock"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  application_security_group_id = dependency.security_group.outputs.application_security_group_id

  ebs_kms_key_arn     = dependency.kms.outputs.key_arns.ebs
  ssm_kms_key_arn     = dependency.kms.outputs.key_arns.ssm
  secrets_kms_key_arn = dependency.kms.outputs.key_arns.secrets
  logs_kms_key_arn    = dependency.kms.outputs.key_arns.logs

  db_endpoint    = dependency.rds.outputs.db_endpoint
  db_port        = dependency.rds.outputs.db_port
  database_name  = dependency.rds.outputs.database_name
  db_secret_arn  = dependency.rds.outputs.master_user_secret_arn

  instance_type    = local.env.locals.instance_type
  application_port = local.env.locals.application_port
}
