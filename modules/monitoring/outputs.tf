# modules/monitoring/outputs.tf

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.alerts.name
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.main.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.main.arn
}

output "error_alarm_name" {
  description = "Name of the error CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.error_alarm.alarm_name
}

output "failed_login_alarm_name" {
  description = "Name of the failed login CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.failed_login_alarm.alarm_name
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}