include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
}

terraform {
  source = "../../../../modules/kms"
}

inputs = {
  deletion_window_in_days = local.env.locals.kms_deletion_window
}
