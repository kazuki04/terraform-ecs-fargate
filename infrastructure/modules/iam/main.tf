################################################################################
# IAM resources for ECS
################################################################################
resource "aws_iam_role" "task_execution_role" {
  name = "${var.service_name}-${var.environment_identifier}-role-task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [ 
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    aws_iam_policy.task_execution_policy.arn
  ]

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-role-task_execution_role"
  }
}

resource "aws_iam_policy" "task_execution_policy" {
  name = "${var.service_name}-${var.environment_identifier}-policy-task_execution_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["kms:Decrypt"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["secretsmanager:GetSecretValue"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "task_role" {
  name = "${var.service_name}-${var.environment_identifier}-role-task_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [ 
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    aws_iam_policy.task_role.id
  ]

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-role-task_role"
  }
}

resource "aws_iam_policy" "task_role" {
  name = "${var.service_name}-${var.environment_identifier}-policy-task_role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
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
        Action   = [
          "ssm:GetParameter",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

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
        Action   = ["ec2:*"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["ecr:*"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["logs:*"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["kms:*"]
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
        Action   = ["iam:PassRole"]
        Effect   = "Allow"
        Resource = [
          aws_iam_role.task_execution_role.arn,
          aws_iam_role.task_role.arn
        ]
      },
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
      },
      {
        Action   = ["kms:*"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

################################################################################
# IAM resources for Lambda
################################################################################
resource "aws_iam_role" "lambda_notify_slack" {
  name = "${var.service_name}-${var.environment_identifier}-role-lambda_notify_slack"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns  = [ aws_iam_policy.lambda_notify_slack.id ]
  max_session_duration = 3600

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-role-lambda_notify_slack"
  }
}

resource "aws_iam_policy" "lambda_notify_slack" {
  name = "${var.service_name}-${var.environment_identifier}-policy-lambda_notify_slack"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sns:*"]
        Effect   = "Allow"
        Resource = [
          var.topic_alarm_arn
        ]
      },
      {
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:logs:*:*:*"
        ]
      }
    ]
  })
}
