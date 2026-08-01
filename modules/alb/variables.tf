variable "name_prefix" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "alb_security_group_id" { type = string }
variable "application_port" {
  type    = number
  default = 8080
}
variable "enable_deletion_protection" {
  type    = bool
  default = false
}
variable "common_tags" {
  type    = map(string)
  default = {}
}
