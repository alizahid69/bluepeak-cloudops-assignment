variable "name_prefix" { type = string }
variable "environment" { type = string }
variable "aws_region" { type = string }
variable "application_security_group_id" { type = string }
variable "ebs_kms_key_arn" { type = string }
variable "ssm_kms_key_arn" { type = string }
variable "secrets_kms_key_arn" { type = string }
variable "logs_kms_key_arn" { type = string }
variable "db_endpoint" { type = string }
variable "db_port" { type = number }
variable "database_name" { type = string }
variable "db_secret_arn" {
  type      = string
  sensitive = true
}
variable "instance_type" {
  type    = string
  default = "t4g.small"
}
variable "application_port" {
  type    = number
  default = 8080
}
variable "root_volume_size" {
  type    = number
  default = 10
}
variable "common_tags" {
  type    = map(string)
  default = {}
}
