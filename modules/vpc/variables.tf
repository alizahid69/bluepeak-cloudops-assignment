variable "name_prefix" { type = string }
variable "vpc_cidr" { type = string }
variable "availability_zones" { type = list(string) }
variable "public_subnet_cidrs" { type = list(string) }
variable "application_subnet_cidrs" { type = list(string) }
variable "database_subnet_cidrs" { type = list(string) }
variable "single_nat_gateway" {
  type    = bool
  default = true
}
variable "common_tags" {
  type    = map(string)
  default = {}
}
