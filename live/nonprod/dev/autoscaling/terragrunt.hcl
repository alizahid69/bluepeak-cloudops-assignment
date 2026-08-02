include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
}

terraform {
  source = "../../../../modules/autoscaling"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    application_subnet_ids = ["subnet-00000000000000005", "subnet-00000000000000006"]
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "ec2" {
  config_path = "../ec2"

  mock_outputs = {
    launch_template_id             = "lt-00000000000000000"
    launch_template_latest_version = "1"
  }

  mock_outputs_allowed_terraform_commands = [
    "validate",
    "plan"
  ]

  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "alb" {
  config_path = "../alb"

  mock_outputs = {
    target_group_arn = "arn:aws:elasticloadbalancing:ap-south-1:111111111111:targetgroup/mock/123456"
    application_url  = "http://mock-alb"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  application_subnet_ids  = dependency.vpc.outputs.application_subnet_ids
  launch_template_id      = dependency.ec2.outputs.launch_template_id
  launch_template_version = tostring(dependency.ec2.outputs.launch_template_latest_version)
  target_group_arn        = dependency.alb.outputs.target_group_arn

  min_size         = local.env.locals.asg_min_size
  desired_capacity = local.env.locals.asg_desired_size
  max_size         = local.env.locals.asg_max_size
}
