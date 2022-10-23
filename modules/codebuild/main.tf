data "aws_region" "current" {}

resource "aws_codebuild_project" "api" {
  name          = "${var.service_name}-${var.environment_identifier}-codebuild-api"
  description   = "${var.service_name} api CodeBuild project in ${var.environment_identifier}"
  build_timeout = "30"
  service_role  = var.service_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    
    environment_variable {
      name  = "RUNTIME_VERSION"
      value = var.runtime_version_for_codebuild
    }

    environment_variable {
      name  = "API_REPOSITORY"
      value = var.api_repository_url
    }

    environment_variable {
      name  = "API_REPOSITORY_NAME"
      value = element(split("/", var.api_repository_url), 1)
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${var.service_name}-${var.environment_identifier}-codebuild-ecs"
      stream_name = "cbproject-api"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = <<-EOT
      version: '0.2'
      artifacts:
        files:
          - imagedefinitions.json
      phases:
        install:
          runtime-versions:
            $RUNTIME_VERSION
        pre_build:
          commands:
            - echo Pre Build phase...
            - echo Logging in Amazon ECR...
            - AWS_ACCOUNT_ID=$(echo $CODEBUILD_BUILD_ARN | cut -f 5 -d :)
            - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
            - IMAGE_TAG="$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | sed 's/^[^a-zA-Z0-9_]*//' | head -c 8)"
        build:
          commands:
            - echo Build phase...
            - cd $CODEBUILD_SRC_DIR/program/api
            - docker build -t $API_REPOSITORY:latest .
            - docker tag $API_REPOSITORY:latest $API_REPOSITORY:$IMAGE_TAG
        post_build:
          commands:
            - echo Post Build phase...
            - docker push $API_REPOSITORY:$IMAGE_TAG
            - echo $IMAGE_TAG $API_REPOSITORY_NAME
            - MANIFEST=$(aws ecr batch-get-image --repository-name $API_REPOSITORY_NAME --region $AWS_DEFAULT_REGION --image-ids imageTag=$IMAGE_TAG --query 'images[].imageManifest' --output text)
            - echo $MANIFEST
            - aws ecr put-image --repository-name $API_REPOSITORY_NAME --region $AWS_DEFAULT_REGION --image-tag latest --image-manifest "$MANIFEST"
            - echo $IMAGE_TAG $API_REPOSITORY_NAME
    EOT
  }

  source_version = "master"

  vpc_config {
    vpc_id = var.vpc_id

    subnets = [
      var.codebuild_subnet_ids[0]
    ]

    security_group_ids = [
      var.sg_codebuild_id
    ]
  }

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-codebuild-api"
  }
}

resource "aws_cloudwatch_log_group" "ecs_cluster_container_insight" {
  name = "/aws/codebuild/${var.service_name}-${var.environment_identifier}-codebuild-ecs"
  retention_in_days = 90
}
