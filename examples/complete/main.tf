provider "aws" {
  region = var.region
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
  logging_configuration                  = var.logging_configuration
  existing_iam_role_arn                  = var.existing_iam_role_arn
  role_name                              = var.role_name
  role_description                       = var.role_description
  role_path                              = var.role_path
  role_force_detach_policies             = var.role_force_detach_policies
  role_permissions_boundary              = var.role_permissions_boundary
  definition                             = var.definition
  iam_policies                           = var.iam_policies

  context = module.this.context
}
