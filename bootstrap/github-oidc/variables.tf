variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "github_organization" { type = string }
variable "github_repository" { type = string }
variable "github_branch" {
  type    = string
  default = "main"
}
variable "execution_role_name" {
  type    = string
  default = "CloudOpsTerraformExecutionRole"
}
variable "github_role_name" {
  type    = string
  default = "CloudOpsGitHubActionsRole"
}
