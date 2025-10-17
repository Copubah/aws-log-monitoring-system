# outputs.tf - Output values for the log monitoring system

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = module.monitoring.sns_topic_arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic"
  value       = module.monitoring.sns_topic_name
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = module.monitoring.log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group"
  value       = module.monitoring.log_group_arn
}

output "error_alarm_name" {
  description = "Name of the error CloudWatch alarm"
  value       = module.monitoring.error_alarm_name
}

output "failed_login_alarm_name" {
  description = "Name of the failed login CloudWatch alarm"
  value       = module.monitoring.failed_login_alarm_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda remediation function"
  value       = var.enable_lambda_remediation ? module.lambda[0].function_arn : null
}

output "lambda_function_name" {
  description = "Name of the Lambda remediation function"
  value       = var.enable_lambda_remediation ? module.lambda[0].function_name : null
}

output "cloudwatch_agent_role_arn" {
  description = "ARN of the CloudWatch Agent IAM role"
  value       = module.iam.cloudwatch_agent_role_arn
}

output "cloudwatch_agent_instance_profile_name" {
  description = "Name of the CloudWatch Agent instance profile"
  value       = module.iam.cloudwatch_agent_instance_profile_name
}

output "dashboard_url" {
  description = "URL to the CloudWatch dashboard"
  value       = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=${var.project_name}-${var.environment}-dashboard"
}