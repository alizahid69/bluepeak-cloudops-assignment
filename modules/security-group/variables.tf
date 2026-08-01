variable "name_prefix" { type = string }
variable "vpc_id" { type = string }
variable "application_port" {
  type    = number
  default = 8080
}
variable "database_port" {
  type    = number
  default = 5432
}
variable "common_tags" {
  type    = map(string)
  default = {}
}
