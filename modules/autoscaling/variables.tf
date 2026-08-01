variable "name_prefix" { type = string }
variable "application_subnet_ids" { type = list(string) }
variable "launch_template_id" { type = string }
variable "launch_template_version" { type = string }
variable "target_group_arn" { type = string }
variable "min_size" { type = number }
variable "desired_capacity" { type = number }
variable "max_size" { type = number }
variable "cpu_target_value" {
  type    = number
  default = 60
}
variable "common_tags" {
  type    = map(string)
  default = {}
}
