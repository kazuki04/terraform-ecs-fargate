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

resource "aws_ecr_lifecycle_policy" "api" {
  repository = aws_ecr_repository.api.name
  policy     = local.image_expire_policy
}
