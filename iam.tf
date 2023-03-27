locals {
  create_role      = local.enabled && (var.existing_iam_role_arn == null || var.existing_iam_role_arn == "")
  role_arn         = local.create_role ? one(aws_iam_role.default[*].arn) : var.existing_iam_role_arn
  role_name        = var.role_name != null && var.role_name != "" ? var.role_name : module.this.id
  role_description = var.role_description != null && var.role_description != "" ? var.role_description : local.role_name
  aws_region       = one(data.aws_region.current[*].name)
}

data "aws_region" "current" {
  count = local.create_role ? 1 : 0
}

data "aws_iam_policy_document" "assume_role" {
  count = local.create_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.${local.aws_region}.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "default" {
  count = local.create_role ? 1 : 0

  name                  = local.role_name
  description           = local.role_description
  path                  = var.role_path
  force_detach_policies = var.role_force_detach_policies
  permissions_boundary  = var.role_permissions_boundary
  assume_role_policy    = data.aws_iam_policy_document.assume_role[0].json

  tags = module.this.tags
}

data "aws_iam_policy_document" "default" {
  count = local.create_role ? 1 : 0

  dynamic "statement" {
    for_each = var.iam_policies

    content {
      sid           = statement.key
      effect        = statement.value.effect
      actions       = lookup(statement.value, "actions", [])
      not_actions   = lookup(statement.value, "not_actions", [])
      resources     = lookup(statement.value, "resources", [])
      not_resources = lookup(statement.value, "not_resources", [])

      dynamic "principals" {
        for_each = lookup(statement.value, "principals", null) != null ? statement.value.principals : []

        content {
          identifiers = principals.value.identifiers
          type        = principals.value.type
        }
      }

      dynamic "not_principals" {
        for_each = lookup(statement.value, "not_principals", null) != null ? statement.value.not_principals : []

        content {
          identifiers = not_principals.value.identifiers
          type        = not_principals.value.type
        }
      }

      dynamic "condition" {
        for_each = lookup(statement.value, "condition", null) != null ? statement.value.condition : []

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_iam_policy" "default" {
  count = local.create_role ? 1 : 0

  name   = local.role_name
  policy = data.aws_iam_policy_document.default[0].json

  tags = module.this.tags
}

resource "aws_iam_policy_attachment" "default" {
  count = local.create_role ? 1 : 0

  name       = local.role_name
  roles      = [aws_iam_role.default[0].name]
  policy_arn = aws_iam_policy.default[0].arn
}
