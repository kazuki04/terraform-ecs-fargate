terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

################################################################################
# KMS
################################################################################
resource "aws_kms_key" "terraform_backend_remote_state" {
  description             = "KMS key for terraform_backend_remote_state"
  deletion_window_in_days = 10
}

################################################################################
# S3
################################################################################
resource "aws_s3_bucket" "terraform_backend_remote_state" {
  bucket = "${var.service_name}-${var.environment_identifier}-bucket-backend"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-bucket-backend"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.terraform_backend_remote_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_backend_remote_state" {
  bucket = aws_s3_bucket.terraform_backend_remote_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_backend_remote_state.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "terraform_backend_remote_state" {
  bucket = aws_s3_bucket.terraform_backend_remote_state.id
  versioning_configuration {
    status = "Enabled"
  }
}


################################################################################
# DynamoDB
################################################################################
resource "aws_dynamodb_table" "terraform_backend_state_lock" {
  name = "${var.service_name}-${var.environment_identifier}-dynamodb-backend-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-dynamodb-backend-state-lock"
  }
}
