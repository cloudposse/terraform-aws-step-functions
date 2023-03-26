provider "aws" {
  region = var.region
}

locals {
  enabled = module.this.enabled

  logging_configuration = {
    include_execution_data = true
    level                  = "ALL"
  }

  # https://docs.aws.amazon.com/step-functions/latest/dg/concepts-amazon-states-language.html
  definition = {
    "Comment" = "Test Step Function"
    "StartAt" = "Hello"
    "States" = {
      "Hello" = {
        "Type"   = "Pass"
        "Result" = "Hello"
        "Next"   = "World"
      },
      "World" = {
        "Type"   = "Pass"
        "Result" = "World"
        "End"    = true
      }
    }
  }

  # https://docs.aws.amazon.com/step-functions/latest/dg/service-integration-iam-templates.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/lambda-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/sns-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/sqs-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/xray-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/athena-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/batch-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/dynamo-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/ecs-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/glue-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/sagemaker-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/emr-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/codebuild-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/eks-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/api-gateway-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/stepfunctions-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/eventbridge-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/activities-iam.html
  iam_policies = {
    # https://docs.aws.amazon.com/step-functions/latest/dg/sns-iam.html
    "SnsAllowPublish" = {
      effect = "Allow"
      actions = [
        "sns:Publish"
      ]
      resources = [
        module.sns.sns_topic_arn
      ]
    }

    # https://docs.aws.amazon.com/step-functions/latest/dg/sqs-iam.html
    "SqsAllowSendMessage" = {
      effect = "Allow"
      actions = [
        "sqs:SendMessage"
      ]
      resources = [
        local.enabled ? aws_sqs_queue.default[0].arn : ""
      ]
    }
  }
}

module "step_function" {
  source = "../../"

  type                                   = var.type
  step_function_name                     = var.step_function_name
  tracing_enabled                        = var.tracing_enabled
  existing_aws_cloudwatch_log_group_arn  = var.existing_aws_cloudwatch_log_group_arn
  cloudwatch_log_group_name              = var.cloudwatch_log_group_name
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_kms_key_id        = var.cloudwatch_log_group_kms_key_id
  existing_iam_role_arn                  = var.existing_iam_role_arn
  role_name                              = var.role_name
  role_description                       = var.role_description
  role_path                              = var.role_path
  role_force_detach_policies             = var.role_force_detach_policies
  role_permissions_boundary              = var.role_permissions_boundary
  logging_configuration                  = local.logging_configuration
  definition                             = local.definition
  iam_policies                           = local.iam_policies

  context = module.this.context
}

module "sns" {
  source  = "cloudposse/sns-topic/aws"
  version = "0.20.2"

  sqs_dlq_enabled    = true
  fifo_topic         = true
  fifo_queue_enabled = true

  context = module.this.context
}

resource "aws_sqs_queue" "default" {
  count = local.enabled ? 1 : 0

  name                       = module.this.id
  fifo_queue                 = false
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400
  max_message_size           = 2048
  delay_seconds              = 90
  receive_wait_time_seconds  = 10

  tags = module.this.tags
}
