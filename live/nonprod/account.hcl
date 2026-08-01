locals {
  account_name   = "nonprod"
  aws_account_id = "111111111111"
  role_name      = "CloudOpsTerraformExecutionRole"

  state_bucket      = "REPLACE-NONPROD-STATE-BUCKET"
  state_region      = "ap-south-1"
  state_kms_key_arn = "REPLACE-NONPROD-STATE-KMS-KEY-ARN"

  github_actions_role_arn = "arn:aws:iam::111111111111:role/CloudOpsGitHubActionsRole"
}
