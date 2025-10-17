# main.tf - Main Terraform configuration for AWS Log Monitoring System

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Local values for resource naming
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
  })
}

# IAM Module - Roles and policies for CloudWatch and Lambda
module "iam" {
  source = "./modules/iam"
  
  name_prefix = local.name_prefix
  tags        = local.common_tags
}

# Monitoring Module - CloudWatch Logs, Metric Filters, Alarms, and SNS
module "monitoring" {
  source = "./modules/monitoring"
  
  name_prefix                = local.name_prefix
  log_group_name            = var.log_group_name
  log_retention_days        = var.log_retention_days
  alert_email               = var.alert_email
  error_threshold           = var.error_threshold
  failed_login_threshold    = var.failed_login_threshold
  evaluation_periods        = var.evaluation_periods
  period_seconds           = var.period_seconds
  sns_encryption_key_id    = var.sns_encryption_key_id
  logs_encryption_key_id   = var.cloudwatch_logs_encryption_key_id
  tags                     = local.common_tags
}

# Lambda Module - Optional automated remediation function
module "lambda" {
  count  = var.enable_lambda_remediation ? 1 : 0
  source = "./modules/lambda"
  
  name_prefix      = local.name_prefix
  sns_topic_arn    = module.monitoring.sns_topic_arn
  lambda_role_arn  = module.iam.lambda_role_arn
  tags             = local.common_tags
}