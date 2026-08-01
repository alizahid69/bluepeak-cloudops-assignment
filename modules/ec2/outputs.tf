output "launch_template_id" { value = aws_launch_template.application.id }
output "launch_template_latest_version" { value = aws_launch_template.application.latest_version }
output "instance_profile_name" { value = aws_iam_instance_profile.application.name }
output "parameter_path" { value = local.parameter_path }
