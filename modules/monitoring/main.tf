# modules/monitoring/main.tf - CloudWatch and SNS resources

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "main" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_days
  kms_key_id        = var.logs_encryption_key_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-log-group"
  })
}

# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name              = "${var.name_prefix}-alerts"
  kms_master_key_id = var.sns_encryption_key_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alerts-topic"
  })
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "alerts" {
  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action = "sns:Publish"
        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}

# SNS Email Subscription
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Metric Filter for ERROR patterns
resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  name           = "${var.name_prefix}-error-filter"
  log_group_name = aws_cloudwatch_log_group.main.name
  pattern        = "[timestamp, request_id, level=\"ERROR\", ...]"

  metric_transformation {
    name      = "${var.name_prefix}-error-count"
    namespace = "${var.name_prefix}/LogMetrics"
    value     = "1"
  }
}

# Metric Filter for Failed Login patterns
resource "aws_cloudwatch_log_metric_filter" "failed_login_filter" {
  name           = "${var.name_prefix}-failed-login-filter"
  log_group_name = aws_cloudwatch_log_group.main.name
  pattern        = "[timestamp, request_id, level, message=\"Failed login*\", ...]"

  metric_transformation {
    name      = "${var.name_prefix}-failed-login-count"
    namespace = "${var.name_prefix}/LogMetrics"
    value     = "1"
  }
}

# CloudWatch Alarm for Errors
resource "aws_cloudwatch_metric_alarm" "error_alarm" {
  alarm_name          = "${var.name_prefix}-error-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "${var.name_prefix}-error-count"
  namespace           = "${var.name_prefix}/LogMetrics"
  period              = var.period_seconds
  statistic           = "Sum"
  threshold           = var.error_threshold
  alarm_description   = "This metric monitors error occurrences in application logs"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-error-alarm"
  })
}

# CloudWatch Alarm for Failed Logins
resource "aws_cloudwatch_metric_alarm" "failed_login_alarm" {
  alarm_name          = "${var.name_prefix}-failed-login-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "${var.name_prefix}-failed-login-count"
  namespace           = "${var.name_prefix}/LogMetrics"
  period              = var.period_seconds
  statistic           = "Sum"
  threshold           = var.failed_login_threshold
  alarm_description   = "This metric monitors failed login attempts"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-failed-login-alarm"
  })
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["${var.name_prefix}/LogMetrics", "${var.name_prefix}-error-count"],
            [".", "${var.name_prefix}-failed-login-count"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Log Monitoring Metrics"
          period  = 300
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 24
        height = 6

        properties = {
          query   = "SOURCE '${aws_cloudwatch_log_group.main.name}' | fields @timestamp, @message | filter @message like /ERROR/ or @message like /Failed login/ | sort @timestamp desc | limit 100"
          region  = data.aws_region.current.name
          title   = "Recent Error and Failed Login Events"
        }
      }
    ]
  })
}

# Data source for current region
data "aws_region" "current" {}