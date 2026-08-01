variable "name_prefix" { type = string }
variable "environment" { type = string }

variable "deletion_window_in_days" {
  type    = number
  default = 7

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "KMS deletion window must be between 7 and 30 days."
  }
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
