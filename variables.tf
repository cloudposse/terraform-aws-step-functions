variable "step_function_name" {
  type        = string
  description = "The name of the Step Function. If not provided, a name will be generated from the context"
  default     = null
}

variable "definition" {
  type        = map(string)
  description = "The Amazon States Language definition for the Step Function. Refer to https://docs.aws.amazon.com/step-functions/latest/dg/concepts-amazon-states-language.html for more details"
}

variable "tracing_enabled" {
  type        = bool
  description = "When set to true, AWS X-Ray tracing is enabled. Make sure the State Machine has the correct IAM policies for logging"
  default     = false
}

variable "type" {
  type        = string
  description = "Determines whether a Standard or Express state machine is created. The default is STANDARD. Valid Values: STANDARD, EXPRESS"
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "EXPRESS"], upper(var.type))
    error_message = "Step Function type must STANDARD or EXPRESS."
  }
}

variable "existing_aws_cloudwatch_log_group_arn" {
  type        = string
  description = "The Amazon Resource Name (ARN) of the existing CloudWatch Log Group to use for the Step Function. If not provided, a new CloudWatch Log Group will be created"
  default     = null
}

variable "logging_configuration" {
  type = object({
    log_destination        = optional(string)
    include_execution_data = bool
    level                  = string
  })
  description = "Defines what execution history events are logged and where they are logged"
  default = {
    include_execution_data = false
    level                  = "OFF"
  }
}

variable "cloudwatch_log_group_name" {
  type        = string
  description = "Name of Cloudwatch Logs Group to use. If not provided, a name will be generated from the context"
  default     = null
}

variable "cloudwatch_log_group_retention_in_days" {
  type        = number
  description = "Specifies the number of days to retain log events in the Log Group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653"
  default     = null
}

variable "cloudwatch_log_group_kms_key_id" {
  type        = string
  description = "The ARN of the KMS Key to use when encrypting log data"
  default     = null
}

variable "existing_iam_role_arn" {
  type        = string
  description = "The Amazon Resource Name (ARN) of the existing IAM role to use for the Step Function. If not provided, a new IAM role will be created"
  default     = null
}

variable "role_name" {
  type        = string
  description = "Name of the created IAM role. If not provided, a name will be generated from the context"
  default     = null
}

variable "role_description" {
  type        = string
  description = "Description of the created IAM role"
  default     = null
}

variable "role_path" {
  type        = string
  description = "Path of the created IAM role"
  default     = null
}

variable "role_force_detach_policies" {
  type        = bool
  description = "Specifies to force detaching any policies the created IAM role has before destroying it"
  default     = true
}

variable "role_permissions_boundary" {
  type        = string
  description = "The ARN of the policy that is used to set the permissions boundary for the created IAM role"
  default     = null
}

variable "iam_policies" {
  type = map(object({
    effect        = string
    actions       = optional(list(string))
    not_actions   = optional(list(string))
    resources     = optional(list(string))
    not_resources = optional(list(string))
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    not_principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    condition = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })))
  }))
  description = "IAM policies to attach to the created IAM role for the Step Function. The map keys will be used as the policy SIDs"
  default     = {}
}
