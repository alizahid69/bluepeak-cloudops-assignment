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
variable "health_check_grace_period" {
  type        = number
  description = "Time in seconds before ELB health checks can replace a newly launched instance."
  default     = 900

  validation {
    condition     = var.health_check_grace_period >= 0
    error_message = "health_check_grace_period must be zero or greater."
  }
}

variable "default_instance_warmup" {
  type        = number
  description = "Default instance warm-up time used by Auto Scaling."
  default     = 180

  validation {
    condition     = var.default_instance_warmup >= 0
    error_message = "default_instance_warmup must be zero or greater."
  }
}
