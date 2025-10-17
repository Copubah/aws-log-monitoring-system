# modules/lambda/outputs.tf

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.remediation.arn
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.remediation.function_name
}

output "function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.remediation.invoke_arn
}

output "log_group_name" {
  description = "Name of the Lambda CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.lambda.name
}