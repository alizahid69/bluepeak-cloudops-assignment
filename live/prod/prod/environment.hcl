locals {
  customer     = "bluepeak"
  project_name = "counter-app"
  environment  = "prod"

  aws_region         = "ap-south-1"
  availability_zones = ["ap-south-1a", "ap-south-1b"]

  vpc_cidr                 = "10.30.0.0/16"
  public_subnet_cidrs      = ["10.30.0.0/24", "10.30.1.0/24"]
  application_subnet_cidrs = ["10.30.10.0/24", "10.30.11.0/24"]
  database_subnet_cidrs    = ["10.30.20.0/24", "10.30.21.0/24"]

  single_nat_gateway = false

  application_port = 8080
  database_port    = 5432

  instance_type    = "t4g.small"
  asg_min_size     = 2
  asg_desired_size = 2
  asg_max_size     = 6

  rds_instance_class      = "db.t4g.small"
  rds_multi_az            = true
  rds_backup_retention    = 14
  rds_deletion_protection = true
  rds_skip_final_snapshot = false

  kms_deletion_window = 30
}
