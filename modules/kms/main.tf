data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  purposes = toset([
    "ebs",
    "rds",
    "ssm",
    "secrets",
    "logs"
  ])
}

data "aws_iam_policy_document" "this" {
  for_each = local.purposes

  statement {
    sid    = "EnableAccountAdministration"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  # CloudWatch Logs can use only the logs CMK.
  dynamic "statement" {
    for_each = each.key == "logs" ? [1] : []

    content {
      sid    = "AllowCloudWatchLogsEncryption"
      effect = "Allow"

      principals {
        type = "Service"

        identifiers = [
          "logs.${data.aws_region.current.region}.amazonaws.com"
        ]
      }

      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]

      resources = ["*"]

      condition {
        test     = "ArnLike"
        variable = "kms:EncryptionContext:aws:logs:arn"

        values = [
          "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/ec2/${var.name_prefix}/*"
        ]
      }
    }
  }

  # Auto Scaling can use the EBS CMK to launch encrypted instances.
  dynamic "statement" {
    for_each = each.key == "ebs" ? [1] : []

    content {
      sid    = "AllowAutoScalingServiceLinkedRoleUseOfEbsKey"
      effect = "Allow"

      principals {
        type = "AWS"

        identifiers = [
          "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        ]
      }

      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]

      resources = ["*"]
    }
  }

  # Auto Scaling requires a KMS grant for AWS-managed EBS resources.
  dynamic "statement" {
    for_each = each.key == "ebs" ? [1] : []

    content {
      sid    = "AllowAutoScalingServiceLinkedRoleGrantForEbs"
      effect = "Allow"

      principals {
        type = "AWS"

        identifiers = [
          "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        ]
      }

      actions   = ["kms:CreateGrant"]
      resources = ["*"]

      condition {
        test     = "Bool"
        variable = "kms:GrantIsForAWSResource"
        values   = ["true"]
      }
    }
  }
}

resource "aws_kms_key" "this" {
  for_each = local.purposes

  description             = "${var.name_prefix} ${each.key} encryption key"
  enable_key_rotation     = true
  deletion_window_in_days = var.deletion_window_in_days
  policy                  = data.aws_iam_policy_document.this[each.key].json

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-${each.key}"
    Purpose = each.key
  })
}

resource "aws_kms_alias" "this" {
  for_each = local.purposes

  name          = "alias/${var.name_prefix}-${each.key}"
  target_key_id = aws_kms_key.this[each.key].key_id
}