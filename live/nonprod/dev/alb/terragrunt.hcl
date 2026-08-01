include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
}

terraform {
  source = "../../../../modules/alb"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id           = "vpc-00000000000000000"
    public_subnet_ids = ["subnet-00000000000000001", "subnet-00000000000000002"]
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "security_group" {
  config_path = "../security-group"

  mock_outputs = {
    alb_security_group_id = "sg-00000000000000000"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  vpc_id                     = dependency.vpc.outputs.vpc_id
  public_subnet_ids          = dependency.vpc.outputs.public_subnet_ids
  alb_security_group_id      = dependency.security_group.outputs.alb_security_group_id
  application_port           = local.env.locals.application_port
  enable_deletion_protection = local.env.locals.environment == "prod"
}
