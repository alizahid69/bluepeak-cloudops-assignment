locals {
  account_name   = "prod"
  aws_account_id = "222222222222"
  role_name      = "CloudOpsTerraformExecutionRole"

  state_bucket      = "REPLACE-PROD-STATE-BUCKET"
  state_region      = "ap-south-1"
  state_kms_key_arn = "REPLACE-PROD-STATE-KMS-KEY-ARN"

  github_actions_role_arn = "arn:aws:iam::222222222222:role/CloudOpsGitHubActionsRole"
}
