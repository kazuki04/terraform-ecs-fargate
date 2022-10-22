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
        var.code_build_role_arn,
        var.code_pipeline_role_arn
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
        var.code_build_role_arn,
        var.code_pipeline_role_arn
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
