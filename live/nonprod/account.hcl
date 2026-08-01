locals {
  account_name   = "nonprod"
  aws_account_id = "322517362792"
  role_name      = "CloudOpsGitHubActionsRole"

  state_bucket      = "bluepeak-nonprod-terraform-state-322517362792"
  state_region      = "ap-south-1"
  state_kms_key_arn = "arn:aws:kms:ap-south-1:322517362792:key/3f24b787-cc41-4dee-b2ea-0d116ec9d3ee"

  github_actions_role_arn = "arn:aws:iam::322517362792:role/CloudOpsGitHubActionsRole"
}
