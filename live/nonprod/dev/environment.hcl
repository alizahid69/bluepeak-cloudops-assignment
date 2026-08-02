locals {
  customer     = "bluepeak"
  project_name = "counter-app"
  environment  = "dev"

  aws_region         = "ap-south-1"
  availability_zones = ["ap-south-1a", "ap-south-1b"]

  vpc_cidr                 = "10.10.0.0/16"
  public_subnet_cidrs      = ["10.10.0.0/24", "10.10.1.0/24"]
  application_subnet_cidrs = ["10.10.10.0/24", "10.10.11.0/24"]
  database_subnet_cidrs    = ["10.10.20.0/24", "10.10.21.0/24"]

  single_nat_gateway = true

  application_port = 8080
  database_port    = 5432

  asg_health_check_grace_period = 900
  asg_default_instance_warmup   = 180

  instance_type    = "t4g.small"
  asg_min_size     = 1
  asg_desired_size = 1
  asg_max_size     = 2

  rds_instance_class      = "db.t4g.micro"
  rds_multi_az            = false
  rds_backup_retention    = 1
  rds_deletion_protection = false
  rds_skip_final_snapshot = true

  kms_deletion_window = 7
}
