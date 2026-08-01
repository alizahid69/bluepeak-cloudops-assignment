include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
}

terraform {
  source = "../../../../modules/vpc"
}

inputs = {
  vpc_cidr                 = local.env.locals.vpc_cidr
  availability_zones       = local.env.locals.availability_zones
  public_subnet_cidrs      = local.env.locals.public_subnet_cidrs
  application_subnet_cidrs = local.env.locals.application_subnet_cidrs
  database_subnet_cidrs    = local.env.locals.database_subnet_cidrs
  single_nat_gateway       = local.env.locals.single_nat_gateway
}
