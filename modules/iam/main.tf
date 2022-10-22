################################################################################
# IAM resources for CodeBuild
################################################################################
resource "aws_iam_role" "code_build" {
  name = "${var.service_name}-${var.environment_identifier}-role-code_build"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [ aws_iam_policy.code_build.id ]

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-role-code_build"
  }
}

resource "aws_iam_policy" "code_build" {
  name = "${var.service_name}-${var.environment_identifier}-policy-code_build"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:*"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["s3:*"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["ec2:*"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["ecr:*"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
