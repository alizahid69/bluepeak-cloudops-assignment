variable "name_prefix" { type = string }
variable "environment" { type = string }
variable "database_subnet_ids" { type = list(string) }
variable "database_security_group_id" { type = string }
variable "rds_kms_key_arn" { type = string }
variable "secrets_kms_key_arn" { type = string }
variable "database_name" {
  type    = string
  default = "counterdb"
}
variable "master_username" {
  type    = string
  default = "counteradmin"
}
variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}
variable "allocated_storage" {
  type    = number
  default = 20
}
variable "max_allocated_storage" {
  type    = number
  default = 100
}
variable "multi_az" {
  type    = bool
  default = false
}
variable "backup_retention_period" {
  type    = number
  default = 1
}
variable "deletion_protection" {
  type    = bool
  default = false
}
variable "skip_final_snapshot" {
  type    = bool
  default = true
}
variable "common_tags" {
  type    = map(string)
  default = {}
}
