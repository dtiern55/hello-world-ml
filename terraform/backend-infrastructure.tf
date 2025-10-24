# Backend infrastructure - S3 and DynamoDB for state management
# This file should remain in your Terraform config

resource "aws_s3_bucket" "terraform_state" {
  bucket = "hello-world-ml-tf-state-942497601151"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "shared"
  }

  lifecycle {
    prevent_destroy = true # Safety: don't accidentally delete state!
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "hello-world-ml-tf-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = "shared"
  }

  lifecycle {
    prevent_destroy = true # Safety: don't accidentally delete locks!
  }
}

data "aws_caller_identity" "current" {}