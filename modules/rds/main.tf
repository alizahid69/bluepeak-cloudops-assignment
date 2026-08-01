resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db-subnets"
  subnet_ids = var.database_subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-db-subnets"
  })
}

resource "aws_db_instance" "this" {
  identifier = substr("${var.name_prefix}-postgres", 0, 63)

  engine         = "postgres"
  engine_version = "16"

  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = var.rds_kms_key_arn

  db_name  = var.database_name
  username = var.master_username
  port     = 5432

  manage_master_user_password   = true
  master_user_secret_kms_key_id = var.secrets_kms_key_arn

  multi_az               = var.multi_az
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.database_security_group_id]

  backup_retention_period = var.backup_retention_period
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot       = true

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name_prefix}-final"

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  performance_insights_enabled          = true
  performance_insights_kms_key_id       = var.rds_kms_key_arn
  performance_insights_retention_period = 7

  apply_immediately = var.environment != "prod"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-postgres"
  })
}
