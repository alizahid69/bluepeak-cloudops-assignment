variable "account_name" {
  type = string
  validation {
    condition     = contains(["nonprod", "prod"], var.account_name)
    error_message = "account_name must be nonprod or prod."
  }
}
variable "aws_account_id" {
  type = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be a 12-digit AWS account ID."
  }
}
variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "bucket_prefix" {
  type    = string
  default = "cloudops-terraform-state"
}
variable "kms_deletion_window_in_days" {
  type    = number
  default = 30
}
variable "force_destroy" {
  type    = bool
  default = false
}
variable "common_tags" {
  type    = map(string)
  default = {}
}
