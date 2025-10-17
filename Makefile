# Makefile for AWS Log Monitoring System

.PHONY: help init validate plan apply destroy test clean format docs

# Default target
help:
	@echo "AWS Log Monitoring System - Terraform Commands"
	@echo ""
	@echo "Available targets:"
	@echo "  init      - Initialize Terraform"
	@echo "  validate  - Validate Terraform configuration"
	@echo "  format    - Format Terraform files"
	@echo "  plan      - Plan Terraform deployment"
	@echo "  apply     - Apply Terraform configuration"
	@echo "  destroy   - Destroy all resources"
	@echo "  test      - Generate test logs"
	@echo "  clean     - Clean temporary files"
	@echo "  docs      - Generate documentation"
	@echo ""
	@echo "Environment variables:"
	@echo "  TF_VAR_alert_email - Email for alerts (required)"
	@echo "  AWS_REGION         - AWS region (default: us-west-2)"
	@echo "  AWS_PROFILE        - AWS profile to use"

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	terraform init
	@echo "Terraform initialized successfully!"

# Validate configuration
validate:
	@echo "Validating Terraform configuration..."
	terraform validate
	@echo "Configuration is valid!"

# Format Terraform files
format:
	@echo "Formatting Terraform files..."
	terraform fmt -recursive
	@echo "Files formatted successfully!"

# Plan deployment
plan: validate
	@echo "Planning Terraform deployment..."
	terraform plan -out=tfplan
	@echo "Plan completed! Review the changes above."

# Apply configuration
apply: plan
	@echo "Applying Terraform configuration..."
	terraform apply tfplan
	@echo "Deployment completed!"
	@echo ""
	@echo "Next steps:"
	@echo "1. Confirm SNS email subscription"
	@echo "2. Install CloudWatch Agent on EC2 instances"
	@echo "3. Run 'make test' to generate test logs"

# Destroy resources
destroy:
	@echo "WARNING: This will destroy all resources!"
	@echo "Press Ctrl+C to cancel, or wait 10 seconds to continue..."
	@sleep 10
	terraform destroy
	@echo "Resources destroyed!"

# Generate test logs
test:
	@echo "Generating test logs..."
	@if [ -f "scripts/test-monitoring.sh" ]; then \
		chmod +x scripts/test-monitoring.sh; \
		./scripts/test-monitoring.sh; \
	else \
		echo "Test script not found. Generating basic test logs..."; \
		logger "ERROR: Test error message for monitoring"; \
		logger "Failed login attempt from user testuser"; \
	fi

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
	rm -f tfplan
	rm -f terraform.tfstate.backup
	rm -f modules/lambda/remediation_function.zip
	find . -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	@echo "Cleanup completed!"

# Generate documentation
docs:
	@echo "Generating Terraform documentation..."
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown table --output-file TERRAFORM.md .; \
		echo "Documentation generated in TERRAFORM.md"; \
	else \
		echo "terraform-docs not installed. Install with:"; \
		echo "  brew install terraform-docs"; \
		echo "  or visit: https://terraform-docs.io/"; \
	fi

# Check prerequisites
check-prereqs:
	@echo "Checking prerequisites..."
	@command -v terraform >/dev/null 2>&1 || { echo "Terraform not installed!"; exit 1; }
	@command -v aws >/dev/null 2>&1 || { echo "AWS CLI not installed!"; exit 1; }
	@aws sts get-caller-identity >/dev/null 2>&1 || { echo "AWS credentials not configured!"; exit 1; }
	@[ -f "terraform.tfvars" ] || { echo "terraform.tfvars not found! Copy from terraform.tfvars.example"; exit 1; }
	@echo "Prerequisites check passed!"

# Full deployment workflow
deploy: check-prereqs init format validate apply
	@echo "Full deployment completed!"

# Development workflow
dev: format validate plan
	@echo "Development checks completed!"