output "state_machine_id" {
  description = "State machine ID"
  value       = one(aws_sfn_state_machine.default[*].id)
}

output "state_machine_arn" {
  description = "State machine ARN"
  value       = one(aws_sfn_state_machine.default[*].arn)
}

output "state_machine_creation_date" {
  description = "State machine creation date"
  value       = one(aws_sfn_state_machine.default[*].creation_date)
}

output "state_machine_status" {
  description = "State machine status"
  value       = one(aws_sfn_state_machine.default[*].status)
}

output "role_arn" {
  description = "The ARN of the IAM role created for the Step Function"
  value       = one(aws_iam_role.default[*].arn)
}

output "role_name" {
  description = "The name of the IAM role created for the Step Function"
  value       = one(aws_iam_role.default[*].name)
}
