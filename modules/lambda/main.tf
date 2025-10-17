# modules/lambda/main.tf - Lambda function for automated remediation

# Lambda function code
resource "aws_lambda_function" "remediation" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.name_prefix}-remediation"
  role            = var.lambda_role_arn
  handler         = "index.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = "python3.9"
  timeout         = 60

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-remediation-function"
  })
}

# Lambda function code archive
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/remediation_function.zip"
  source {
    content = templatefile("${path.module}/remediation_function.py", {
      # Template variables can be added here if needed
    })
    filename = "index.py"
  }
}

# SNS subscription to trigger Lambda
resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = var.sns_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.remediation.arn
}

# Lambda permission for SNS to invoke
resource "aws_lambda_permission" "sns_invoke" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.remediation.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.remediation.function_name}"
  retention_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-lambda-logs"
  })
}