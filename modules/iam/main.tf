################################################################################
# IAM resources for CodeBuild
################################################################################
resource "aws_iam_role" "codebuild" {
  name = "${var.service_name}-${var.environment_identifier}-role-codebuild"

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

  managed_policy_arns = [ aws_iam_policy.codebuild.id ]

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-role-codebuild"
  }
}

resource "aws_iam_policy" "codebuild" {
  name = "${var.service_name}-${var.environment_identifier}-policy-codebuild"

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

################################################################################
# IAM resources for CodePipeline
################################################################################
resource "aws_iam_role" "codepipeline" {
  name = "${var.service_name}-${var.environment_identifier}-role-codepipeline"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns  = [ aws_iam_policy.codepipeline.id ]
  max_session_duration = 3600

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-role-codepipeline"
  }
}

resource "aws_iam_policy" "codepipeline" {
  name = "${var.service_name}-${var.environment_identifier}-policy-codepipeline"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:UploadArchive",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:CancelUploadArchive"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["s3:*"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["codebuild:*"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["ecs:*"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
