################################################################################
# Artifact
################################################################################
resource "aws_s3_bucket" "artifact" {
  bucket = "${var.service_name}-${var.environment_identifier}-bucket-artifact"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-bucket-artifact"
  }
}

resource "aws_s3_bucket_public_access_block" "artifact" {
  bucket = aws_s3_bucket.artifact.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifact" {
  bucket = aws_s3_bucket.artifact.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "artifact" {
  bucket = aws_s3_bucket.artifact.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "artifact" {
  bucket = aws_s3_bucket.artifact.id
  policy = data.aws_iam_policy_document.artifact.json
}

data "aws_iam_policy_document" "artifact" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [
        var.codebuild_role_arn,
        var.codepipeline_role_arn
      ]
    }

    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.artifact.arn,
      "${aws_s3_bucket.artifact.arn}/*",
    ]
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = [
        var.codebuild_role_arn,
        var.codepipeline_role_arn
      ]
    }

    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:Put*"
    ]

    resources = [
      "${aws_s3_bucket.artifact.arn}/*",
    ]
  }
}

################################################################################
# CloudFront Log Bucket
################################################################################
resource "aws_s3_bucket" "cloudfront" {
  bucket = "${var.service_name}-${var.environment_identifier}-bucket-cloudfront"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-bucket-cloudfront"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudfront" {
  bucket = aws_s3_bucket.cloudfront.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudfront" {
  bucket = aws_s3_bucket.cloudfront.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "cloudfront" {
  bucket = aws_s3_bucket.cloudfront.id
  versioning_configuration {
    status = "Enabled"
  }
}

################################################################################
# Program Log Bucket
################################################################################
resource "aws_s3_bucket" "program_log" {
  bucket = "${var.service_name}-${var.environment_identifier}-bucket-program-log"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-bucket-program-log"
  }
}

resource "aws_s3_bucket_public_access_block" "program_log" {
  bucket = aws_s3_bucket.program_log.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "program_log" {
  bucket = aws_s3_bucket.program_log.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "program_log" {
  bucket = aws_s3_bucket.program_log.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "program_log" {
  bucket = aws_s3_bucket.program_log.bucket

  rule {
    id = "log"
    expiration {
      days = 90
    }

    status = "Enabled"
  }
}
