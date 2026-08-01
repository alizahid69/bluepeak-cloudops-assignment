output "state_bucket" {
  value = aws_s3_bucket.state.id
}
output "state_region" {
  value = var.aws_region
}
output "state_kms_key_arn" {
  value = aws_kms_key.state.arn
}
output "state_kms_alias" {
  value = aws_kms_alias.state.name
}
