include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
}

terraform {
  source = "../../../../modules/security-group"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "vpc-00000000000000000"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  vpc_id           = dependency.vpc.outputs.vpc_id
  application_port = local.env.locals.application_port
  database_port    = local.env.locals.database_port
}
