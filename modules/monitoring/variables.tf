# modules/monitoring/variables.tf

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "log_group_name" {
  description = "CloudWatch Log Group name"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
}

variable "alert_email" {
  description = "Email address for alert notifications"
  type        = string
}

variable "error_threshold" {
  description = "Number of errors to trigger alarm"
  type        = number
}

variable "failed_login_threshold" {
  description = "Number of failed logins to trigger alarm"
  type        = number
}

variable "evaluation_periods" {
  description = "Number of periods to evaluate for alarm"
  type        = number
}

variable "period_seconds" {
  description = "Period in seconds for alarm evaluation"
  type        = number
}

variable "sns_encryption_key_id" {
  description = "KMS key ID for SNS encryption"
  type        = string
  default     = null
}

variable "logs_encryption_key_id" {
  description = "KMS key ID for CloudWatch Logs encryption"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}