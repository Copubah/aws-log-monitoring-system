# variables.tf - Input variables for the log monitoring system

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "log-monitoring"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "alert_email" {
  description = "Email address for alert notifications"
  type        = string
}

variable "log_group_name" {
  description = "CloudWatch Log Group name"
  type        = string
  default     = "/aws/ec2/logs"
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 7
}

variable "error_threshold" {
  description = "Number of errors to trigger alarm"
  type        = number
  default     = 5
}

variable "failed_login_threshold" {
  description = "Number of failed logins to trigger alarm"
  type        = number
  default     = 3
}

variable "evaluation_periods" {
  description = "Number of periods to evaluate for alarm"
  type        = number
  default     = 1
}

variable "period_seconds" {
  description = "Period in seconds for alarm evaluation"
  type        = number
  default     = 300
}

variable "enable_lambda_remediation" {
  description = "Enable Lambda function for automated remediation"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "LogMonitoring"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

variable "sns_encryption_key_id" {
  description = "KMS key ID for SNS encryption (optional)"
  type        = string
  default     = null
}

variable "cloudwatch_logs_encryption_key_id" {
  description = "KMS key ID for CloudWatch Logs encryption (optional)"
  type        = string
  default     = null
}