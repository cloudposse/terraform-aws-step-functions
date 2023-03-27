locals {
  logging_enabled                 = local.enabled && try(var.logging_configuration["level"], null) != null && try(var.logging_configuration["level"], "OFF") != "OFF"
  create_aws_cloudwatch_log_group = local.enabled && (var.existing_aws_cloudwatch_log_group_arn == null || var.existing_aws_cloudwatch_log_group_arn == "")
  cloudwatch_log_group_arn        = local.create_aws_cloudwatch_log_group ? one(aws_cloudwatch_log_group.logs[*].arn) : var.existing_aws_cloudwatch_log_group_arn
  cloudwatch_log_name             = var.cloudwatch_log_group_name != null && var.cloudwatch_log_group_name != "" ? var.cloudwatch_log_group_name : module.logs_label.id
}

module "logs_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["logs"]

  context = module.this.context
}

data "aws_iam_policy_document" "logs" {
  count = local.create_role && local.logging_enabled ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "logs" {
  count = local.create_role && local.logging_enabled ? 1 : 0

  name   = local.cloudwatch_log_name
  policy = data.aws_iam_policy_document.logs[0].json

  tags = module.logs_label.tags
}

resource "aws_iam_policy_attachment" "logs" {
  count = local.create_role && local.logging_enabled ? 1 : 0

  name       = local.cloudwatch_log_name
  roles      = [aws_iam_role.default[0].name]
  policy_arn = aws_iam_policy.logs[0].arn
}

resource "aws_cloudwatch_log_group" "logs" {
  count = local.create_aws_cloudwatch_log_group && local.logging_enabled ? 1 : 0

  name              = local.cloudwatch_log_name
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  tags = module.logs_label.tags
}
