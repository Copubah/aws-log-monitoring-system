# Deployment Guide

## Quick Start

### Prerequisites
1. AWS CLI configured with appropriate permissions
2. Terraform >= 1.0 installed
3. Email address for alert notifications
4. S3 bucket for remote state (optional but recommended)

### Minimum Required Permissions
Your AWS user/role needs these permissions:
- CloudWatch: Full access to Logs, Metrics, Alarms, Dashboards
- SNS: Create topics, subscriptions, and policies
- IAM: Create roles and policies
- Lambda: Create and manage functions
- S3: Access to state bucket (if using remote state)
- DynamoDB: Access to lock table (if using remote state)

## Step-by-Step Deployment

### 1. Initial Setup

```bash
# Clone or download the project
git clone <repository-url>
cd aws-log-monitoring

# Copy configuration template
cp terraform.tfvars.example terraform.tfvars
```

### 2. Configure Variables

Edit `terraform.tfvars`:

```hcl
# Required variables
project_name = "log-monitoring"
environment  = "dev"
region      = "us-west-2"
alert_email  = "your-email@example.com"

# Optional customizations
error_threshold        = 5
failed_login_threshold = 3
log_retention_days     = 7
enable_lambda_remediation = true

# Tags for cost tracking
tags = {
  Project     = "LogMonitoring"
  Environment = "Development"
  Owner       = "YourName"
  CostCenter  = "Engineering"
}
```

### 3. Backend Configuration (Recommended)

Update `backend.tf` with your S3 bucket details:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "log-monitoring/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

### 4. Deploy Infrastructure

```bash
# Initialize Terraform
make init

# Validate and format
make validate
make format

# Plan deployment
make plan

# Apply changes
make apply
```

### 5. Confirm SNS Subscription

1. Check your email for SNS subscription confirmation
2. Click the confirmation link
3. Verify subscription in AWS Console

### 6. Configure EC2 Instances

#### Option A: New EC2 Instances

When launching new instances, attach the CloudWatch Agent IAM role:

```bash
# Get the instance profile name from Terraform output
terraform output cloudwatch_agent_instance_profile_name

# Use this profile when launching EC2 instances
aws ec2 run-instances \
  --image-id ami-12345678 \
  --instance-type t3.micro \
  --iam-instance-profile Name="log-monitoring-dev-cloudwatch-agent-profile"
```

#### Option B: Existing EC2 Instances

1. Attach the CloudWatch Agent IAM role to existing instances
2. Install CloudWatch Agent using the provided script:

```bash
# Copy files to EC2 instance
scp cloudwatch-agent-config.json ec2-user@instance-ip:~/
scp scripts/install-cloudwatch-agent.sh ec2-user@instance-ip:~/

# SSH to instance and run installation
ssh ec2-user@instance-ip
chmod +x install-cloudwatch-agent.sh
sudo ./install-cloudwatch-agent.sh us-west-2
```

### 7. Test the System

```bash
# Generate test logs locally
make test

# Or SSH to EC2 instance and run:
logger "ERROR: Test error message for monitoring"
logger "Failed login attempt from user testuser"
```

### 8. Verify Monitoring

1. Check CloudWatch Logs for incoming data
2. Monitor CloudWatch Alarms status
3. Verify email alerts are received
4. Review Lambda function logs (if enabled)

## Environment-Specific Deployments

### Development Environment

```bash
# Use development workspace
terraform workspace new dev
terraform workspace select dev

# Deploy with dev configuration
terraform apply -var-file="dev.tfvars"
```

### Staging Environment

```bash
# Create staging workspace
terraform workspace new staging
terraform workspace select staging

# Deploy with staging configuration
terraform apply -var-file="staging.tfvars"
```

### Production Environment

```bash
# Create production workspace
terraform workspace new prod
terraform workspace select prod

# Deploy with production configuration
terraform apply -var-file="prod.tfvars"
```

## Configuration Examples

### Development Configuration (dev.tfvars)

```hcl
project_name = "log-monitoring"
environment  = "dev"
region      = "us-west-2"
alert_email  = "dev-team@company.com"

# Lower thresholds for testing
error_threshold        = 2
failed_login_threshold = 1
evaluation_periods     = 1
period_seconds        = 300

# Shorter retention for cost savings
log_retention_days = 3

# Enable all features for testing
enable_lambda_remediation = true

tags = {
  Project     = "LogMonitoring"
  Environment = "Development"
  Owner       = "DevTeam"
  CostCenter  = "Engineering"
}
```

### Production Configuration (prod.tfvars)

```hcl
project_name = "log-monitoring"
environment  = "prod"
region      = "us-east-1"
alert_email  = "ops-team@company.com"

# Production thresholds
error_threshold        = 10
failed_login_threshold = 5
evaluation_periods     = 2
period_seconds        = 300

# Longer retention for compliance
log_retention_days = 30

# Enable remediation
enable_lambda_remediation = true

# Production encryption
sns_encryption_key_id             = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
cloudwatch_logs_encryption_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

tags = {
  Project     = "LogMonitoring"
  Environment = "Production"
  Owner       = "OpsTeam"
  CostCenter  = "Operations"
  Compliance  = "Required"
}
```

## Monitoring and Maintenance

### Daily Operations

1. Review CloudWatch Dashboard
2. Check alarm states
3. Monitor log ingestion rates
4. Review Lambda function performance

### Weekly Tasks

1. Analyze alert patterns
2. Review cost allocation reports
3. Update alarm thresholds if needed
4. Check system performance metrics

### Monthly Tasks

1. Review and update log retention policies
2. Analyze cost optimization opportunities
3. Update documentation
4. Review security configurations

## Troubleshooting

### Common Deployment Issues

#### Terraform Init Fails
```bash
# Check AWS credentials
aws sts get-caller-identity

# Verify S3 bucket exists and is accessible
aws s3 ls s3://your-terraform-state-bucket

# Check DynamoDB table
aws dynamodb describe-table --table-name terraform-state-lock
```

#### Permission Denied Errors
```bash
# Check IAM permissions
aws iam get-user
aws iam list-attached-user-policies --user-name your-username

# Verify assume role permissions if using roles
aws sts assume-role --role-arn arn:aws:iam::123456789012:role/YourRole --role-session-name test
```

#### SNS Subscription Issues
1. Check email spam folder
2. Verify email address in terraform.tfvars
3. Manually confirm subscription in AWS Console
4. Check SNS topic policy permissions

### Performance Issues

#### High Costs
1. Review log retention settings
2. Optimize metric filter patterns
3. Check CloudWatch Insights usage
4. Review alarm evaluation frequency

#### Missing Alerts
1. Verify CloudWatch Agent is running
2. Check log group permissions
3. Review metric filter patterns
4. Validate alarm thresholds

## Cleanup

### Temporary Cleanup
```bash
# Remove temporary files
make clean
```

### Full Cleanup
```bash
# Destroy all resources
make destroy

# Or manually
terraform destroy
```

### Workspace Cleanup
```bash
# List workspaces
terraform workspace list

# Delete workspace
terraform workspace select default
terraform workspace delete dev
```

## Security Best Practices

### IAM Security
- Use least privilege principle
- Regularly review IAM policies
- Enable CloudTrail for audit logging
- Use IAM roles instead of users where possible

### Encryption
- Enable KMS encryption for sensitive data
- Use separate KMS keys for different environments
- Regularly rotate encryption keys
- Monitor key usage

### Network Security
- Use VPC endpoints for AWS services
- Implement security groups and NACLs
- Monitor network traffic
- Use AWS Config for compliance

### Monitoring Security
- Enable GuardDuty for threat detection
- Use Security Hub for centralized security
- Monitor unusual API activity
- Implement incident response procedures

## Support and Resources

### Documentation
- AWS CloudWatch Documentation
- Terraform AWS Provider Documentation
- AWS Well-Architected Framework
- AWS Security Best Practices

### Community Resources
- Terraform Community
- AWS Forums
- Stack Overflow
- GitHub Issues

### Professional Support
- AWS Support Plans
- Terraform Cloud
- AWS Professional Services
- Third-party consultants