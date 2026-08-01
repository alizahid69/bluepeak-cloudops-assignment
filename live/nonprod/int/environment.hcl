locals {
  customer     = "bluepeak"
  project_name = "counter-app"
  environment  = "int"

  aws_region         = "ap-south-1"
  availability_zones = ["ap-south-1a", "ap-south-1b"]

  vpc_cidr                 = "10.20.0.0/16"
  public_subnet_cidrs      = ["10.20.0.0/24", "10.20.1.0/24"]
  application_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]
  database_subnet_cidrs    = ["10.20.20.0/24", "10.20.21.0/24"]

  single_nat_gateway = false

  application_port = 8080
  database_port    = 5432

  instance_type    = "t4g.small"
  asg_min_size     = 2
  asg_desired_size = 2
  asg_max_size     = 4

  rds_instance_class      = "db.t4g.small"
  rds_multi_az            = true
  rds_backup_retention    = 7
  rds_deletion_protection = false
  rds_skip_final_snapshot = false

  kms_deletion_window = 14
}
