output "state_machine_id" {
  description = "State machine ID"
  value       = module.step_function.state_machine_id
}

output "state_machine_arn" {
  description = "State machine ARN"
  value       = module.step_function.state_machine_arn
}

output "state_machine_creation_date" {
  description = "State machine creation date"
  value       = module.step_function.state_machine_creation_date
}

output "state_machine_status" {
  description = "State machine status"
  value       = module.step_function.state_machine_status
}

output "role_arn" {
  description = "The ARN of the IAM role created for the Step Function"
  value       = module.step_function.role_arn
}

output "role_name" {
  description = "The name of the IAM role created for the Step Function"
  value       = module.step_function.role_name
}
