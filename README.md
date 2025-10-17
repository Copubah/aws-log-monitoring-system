# AWS Real-Time Log Monitoring and Alerting System

> **GitHub Repository:** `https://github.com/YOUR_USERNAME/aws-log-monitoring-system`

This Terraform project creates an automated AWS monitoring and alerting system that detects failed logins and error messages from EC2 instance logs.

## Architecture Overview

```
EC2 Instances -> CloudWatch Agent -> CloudWatch Logs -> Metric Filters -> CloudWatch Alarms -> SNS -> Email/Lambda
```

## Features

- Centralized Logging: CloudWatch Log Groups for EC2 instance logs
- Pattern Detection: Metric filters for "ERROR" and "Failed login" patterns
- Real-time Alerting: CloudWatch Alarms with SNS email notifications
- Automated Response: Optional Lambda function for incident remediation
- Security: IAM roles with least privilege access
- Cost Management: Log retention policies and resource tagging

## Project Structure

```
├── main.tf                 # Main Terraform configuration
├── variables.tf           # Input variables
├── outputs.tf            # Output values
├── terraform.tfvars      # Variable values (create from template)
├── modules/
│   ├── monitoring/       # CloudWatch and SNS resources
│   ├── iam/             # IAM roles and policies
│   └── lambda/          # Lambda function for remediation
├── backend.tf           # Remote state configuration
└── README.md           # This file
```

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform >= 1.0 installed
3. S3 bucket for remote state (update backend.tf)
4. DynamoDB table for state locking (update backend.tf)

## Setup Instructions

### 1. Clone and Initialize

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive
```

### 2. Configure Variables

Create `terraform.tfvars` from the template:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
project_name = "log-monitoring"
environment  = "dev"
alert_email  = "your-email@example.com"
region      = "us-west-2"

# Alarm thresholds
error_threshold       = 5
failed_login_threshold = 3
evaluation_periods    = 1
period_seconds       = 300

# Log retention
log_retention_days = 7

# Tags
tags = {
  Project     = "LogMonitoring"
  Environment = "Development"
  Owner       = "CloudEngineer"
  CostCenter  = "Engineering"
}
```

### 3. Deploy Infrastructure

```bash
# Plan deployment
terraform plan

# Apply changes
terraform apply

# Confirm with 'yes' when prompted
```

### 4. Test the System

1. Confirm SNS Subscription: Check your email and confirm the SNS subscription
2. Generate Test Logs: SSH to an EC2 instance and generate test logs:
   ```bash
   # Generate error logs
   logger "ERROR: Test error message for monitoring"
   logger "Failed login attempt from user testuser"
   ```
3. Monitor CloudWatch: Check CloudWatch Logs and Metrics in AWS Console
4. Verify Alerts: You should receive email alerts when thresholds are exceeded

### 5. Cleanup

```bash
# Destroy all resources
terraform destroy

# Confirm with 'yes' when prompted
```

## Configuration Options

### Environment Variables

- `AWS_REGION`: AWS region for deployment
- `AWS_PROFILE`: AWS CLI profile to use

### Terraform Workspaces

Use workspaces for different environments:

```bash
# Create and switch to staging workspace
terraform workspace new staging
terraform workspace select staging

# Deploy to staging
terraform apply -var-file="staging.tfvars"
```

## Monitoring and Maintenance

### CloudWatch Dashboards

The system creates CloudWatch dashboards for monitoring:
- Log ingestion rates
- Alarm states
- Error patterns over time

### Cost Optimization

- Log retention policies automatically delete old logs
- Resource tags enable cost allocation tracking
- Use CloudWatch Insights for efficient log querying

### Security Best Practices

- IAM roles follow least privilege principle
- CloudWatch Logs encrypted at rest
- SNS topics use server-side encryption
- Lambda functions have minimal permissions

## Troubleshooting

### Common Issues

1. SNS Subscription Not Confirmed
   - Check email spam folder
   - Verify email address in variables

2. CloudWatch Agent Not Sending Logs
   - Ensure EC2 instances have proper IAM role
   - Check CloudWatch Agent configuration
   - Verify network connectivity

3. Alarms Not Triggering
   - Check metric filter patterns
   - Verify alarm thresholds
   - Review CloudWatch Logs for data

### Useful Commands

```bash
# Check Terraform state
terraform show

# List resources
terraform state list

# Import existing resources
terraform import aws_cloudwatch_log_group.example /aws/ec2/logs

# Refresh state
terraform refresh
```

## Architecture Diagram

```
┌─────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   EC2       │    │   CloudWatch     │    │   CloudWatch    │
│ Instances   │───▶│     Logs         │───▶│  Metric Filters │
│             │    │                  │    │                 │
└─────────────┘    └──────────────────┘    └─────────────────┘
                                                      │
┌─────────────┐    ┌──────────────────┐              │
│   Email     │◀───│      SNS         │◀─────────────┘
│ Alerts      │    │     Topic        │
└─────────────┘    └──────────────────┘
                            │
                            ▼
                   ┌──────────────────┐
                   │     Lambda       │
                   │   (Optional)     │
                   │   Remediation    │
                   └──────────────────┘
```

## Contributing

1. Follow Terraform best practices
2. Update documentation for any changes
3. Test in development environment first
4. Use consistent naming conventions
5. Add appropriate tags to all resources

## License

This project is for educational and portfolio purposes.