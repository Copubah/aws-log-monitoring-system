# modules/iam/outputs.tf

output "cloudwatch_agent_role_arn" {
  description = "ARN of the CloudWatch Agent IAM role"
  value       = aws_iam_role.cloudwatch_agent.arn
}

output "cloudwatch_agent_role_name" {
  description = "Name of the CloudWatch Agent IAM role"
  value       = aws_iam_role.cloudwatch_agent.name
}

output "cloudwatch_agent_instance_profile_name" {
  description = "Name of the CloudWatch Agent instance profile"
  value       = aws_iam_instance_profile.cloudwatch_agent.name
}

output "cloudwatch_agent_instance_profile_arn" {
  description = "ARN of the CloudWatch Agent instance profile"
  value       = aws_iam_instance_profile.cloudwatch_agent.arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution.arn
}

output "lambda_role_name" {
  description = "Name of the Lambda execution role"
  value       = aws_iam_role.lambda_execution.name
}