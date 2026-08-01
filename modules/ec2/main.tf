data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

locals {
  parameter_path = "/${var.name_prefix}/application"

  parameters = {
    APP_ENV       = var.environment
    APP_PORT      = tostring(var.application_port)
    DB_HOST       = var.db_endpoint
    DB_PORT       = tostring(var.db_port)
    DB_NAME       = var.database_name
    DB_SECRET_ARN = var.db_secret_arn
    AWS_REGION    = var.aws_region
  }
}

resource "aws_ssm_parameter" "application" {
  for_each = nonsensitive(local.parameters)

  name   = "${local.parameter_path}/${each.key}"
  type   = "SecureString"
  value  = each.value
  key_id = var.ssm_kms_key_arn

  tags = merge(var.common_tags, {
    Name = "${local.parameter_path}/${each.key}"
  })
}

resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/ec2/${var.name_prefix}/application"
  retention_in_days = var.environment == "prod" ? 30 : 7
  kms_key_id        = var.logs_kms_key_arn

  tags = merge(var.common_tags, {
    Name = "/aws/ec2/${var.name_prefix}/application"
  })
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "application" {
  name               = "${var.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ec2-role"
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.application.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "application" {
  statement {
    sid = "ReadParameters"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter${local.parameter_path}/*"
    ]
  }

  statement {
    sid = "ReadDatabaseSecret"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = [var.db_secret_arn]
  }

  statement {
    sid       = "DecryptConfiguration"
    actions   = ["kms:Decrypt"]
    resources = [var.ssm_kms_key_arn, var.secrets_kms_key_arn]
  }

  statement {
    sid = "WriteLogs"

    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]

    resources = ["${aws_cloudwatch_log_group.application.arn}:*"]
  }
}

resource "aws_iam_role_policy" "application" {
  name   = "${var.name_prefix}-application-policy"
  role   = aws_iam_role.application.id
  policy = data.aws_iam_policy_document.application.json
}

resource "aws_iam_instance_profile" "application" {
  name = "${var.name_prefix}-instance-profile"
  role = aws_iam_role.application.name
}

resource "aws_launch_template" "application" {
  name_prefix   = "${var.name_prefix}-"
  image_id      = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.instance_type

  iam_instance_profile {
    arn = aws_iam_instance_profile.application.arn
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.application_security_group_id]
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      encrypted             = true
      kms_key_id            = var.ebs_kms_key_arn
      delete_on_termination = true
    }
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    parameter_path = local.parameter_path
    aws_region     = var.aws_region
    log_group_name = aws_cloudwatch_log_group.application.name
  }))

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.common_tags, {
      Name = "${var.name_prefix}-application"
    })
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(var.common_tags, {
      Name = "${var.name_prefix}-application"
    })
  }

  update_default_version = true
}
