locals {
  image_expire_policy = <<-EOT
  {
    "rules": [
      {
          "rulePriority": 1,
          "description": "Keep 5 images",
          "selection": {
            "countNumber": 5, 
            "countType": "imageCountMoreThan",
            "tagStatus": "any"
          },
          "action": {
            "type": "expire"
          }
        }
      ]
    }
  EOT
}

resource "aws_ecr_repository" "api" {
  name = "${var.service_name}-${var.environment_identifier}-ecr-api"

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-ecr-api"
  }
}

resource "aws_ecr_repository" "nginx" {
  name = "${var.service_name}-${var.environment_identifier}-ecr-nginx"

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-ecr-nginx"
  }
}

resource "aws_ecr_repository" "frontend" {
  name = "${var.service_name}-${var.environment_identifier}-ecr-frontend"

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-ecr-frontend"
  }
}

resource "aws_ecr_repository" "fluentbit" {
  name = "${var.service_name}-${var.environment_identifier}-ecr-fluentbit"

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-ecr-fluentbit"
  }
}


resource "aws_ecr_lifecycle_policy" "api" {
  repository = aws_ecr_repository.api.name
  policy     = local.image_expire_policy
}

resource "aws_ecr_lifecycle_policy" "nginx" {
  repository = aws_ecr_repository.nginx.name
  policy     = local.image_expire_policy
}

resource "aws_ecr_lifecycle_policy" "frontend" {
  repository = aws_ecr_repository.frontend.name
  policy     = local.image_expire_policy
}

resource "aws_ecr_lifecycle_policy" "fluentbit" {
  repository = aws_ecr_repository.fluentbit.name
  policy     = local.image_expire_policy
}
