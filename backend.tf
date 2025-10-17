# backend.tf - Remote state configuration

terraform {
  backend "s3" {
    # Update these values for your environment
    bucket         = "your-terraform-state-bucket"
    key            = "log-monitoring/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    
    # Optional: Use versioning for state file protection
    versioning = true
  }
}

# Example S3 bucket and DynamoDB table for state management
# Uncomment and apply separately before using remote backend

# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "your-terraform-state-bucket"
#   
#   tags = {
#     Name        = "Terraform State Bucket"
#     Environment = "shared"
#     Purpose     = "terraform-state"
#   }
# }

# resource "aws_s3_bucket_versioning" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# resource "aws_s3_bucket_public_access_block" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# resource "aws_dynamodb_table" "terraform_state_lock" {
#   name           = "terraform-state-lock"
#   billing_mode   = "PAY_PER_REQUEST"
#   hash_key       = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   tags = {
#     Name        = "Terraform State Lock Table"
#     Environment = "shared"
#     Purpose     = "terraform-state-lock"
#   }
# }