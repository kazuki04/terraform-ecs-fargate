data "aws_region" "current" {}

locals {
  runtime_language         = element(split(":", var.runtime_version_for_codebuild), 0)
  runtime_version          = element(split(":", var.runtime_version_for_codebuild), 1)
  api_container_name       = "api"
  nginx_container_name     = "nginx"
  frontend_container_name  = "frontend"
  fluentbit_container_name = "fluentbit"
}

resource "aws_codebuild_project" "api" {
  name          = "${var.service_name}-${var.environment_identifier}-codebuild-api"
  description   = "${var.service_name} api CodeBuild project in ${var.environment_identifier}"
  build_timeout = "30"
  service_role  = var.service_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "API_REPOSITORY"
      value = var.api_repository_url
    }

    environment_variable {
      name  = "API_REPOSITORY_NAME"
      value = element(split("/", var.api_repository_url), 1)
    }

    environment_variable {
      name  = "API_CONTAINER_NAME"
      value = local.api_container_name
    }

    environment_variable {
      name  = "NGINX_REPOSITORY"
      value = var.nginx_repository_url
    }

    environment_variable {
      name  = "NGINX_REPOSITORY_NAME"
      value = element(split("/", var.nginx_repository_url), 1)
    }

    environment_variable {
      name  = "NGINX_CONTAINER_NAME"
      value = local.nginx_container_name
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
            ${local.runtime_language}: ${local.runtime_version}
        pre_build:
          commands:
            - echo Pre Build phase...
            - echo Logging in Amazon ECR...
            - AWS_ACCOUNT_ID=$(echo $CODEBUILD_BUILD_ARN | cut -f 5 -d :)
            - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
            - IMAGE_TAG="$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | sed 's/^[^a-zA-Z0-9_]*//' | head -c 8)"
            - echo trivy install...
            - rpm -ivh https://github.com/aquasecurity/trivy/releases/download/v0.34.0/trivy_0.34.0_Linux-64bit.rpm
        build:
          commands:
            - echo Build phase...
            - echo Build api ...
            - cd $CODEBUILD_SRC_DIR/program/backend
            - docker build -t $API_REPOSITORY:latest -f docker/api/Dockerfile .
            - docker tag $API_REPOSITORY:latest $API_REPOSITORY:$IMAGE_TAG
            - echo Build nginx ...
            - docker build -t $NGINX_REPOSITORY:latest -f docker/nginx/Dockerfile .
            - docker tag $NGINX_REPOSITORY:latest $NGINX_REPOSITORY:$IMAGE_TAG
        post_build:
          commands:
            - echo Post Build phase...
            - echo Image scanning...
            - trivy image $API_REPOSITORY:$IMAGE_TAG --severity CRITICAL --no-progress  --vuln-type library --exit-code 1 --timeout 15m
            - echo Push api ...
            - docker push $API_REPOSITORY:$IMAGE_TAG
            - echo $IMAGE_TAG $API_REPOSITORY_NAME
            - MANIFEST=$(aws ecr batch-get-image --repository-name $API_REPOSITORY_NAME --region $AWS_DEFAULT_REGION --image-ids imageTag=$IMAGE_TAG --query 'images[].imageManifest' --output text)
            - echo $MANIFEST
            - aws ecr put-image --repository-name $API_REPOSITORY_NAME --region $AWS_DEFAULT_REGION --image-tag latest --image-manifest "$MANIFEST"
            - echo Push nginx ...
            - docker push $NGINX_REPOSITORY:$IMAGE_TAG
            - echo $IMAGE_TAG $NGINX_REPOSITORY_NAME
            - MANIFEST=$(aws ecr batch-get-image --repository-name $NGINX_REPOSITORY_NAME --region $AWS_DEFAULT_REGION --image-ids imageTag=$IMAGE_TAG --query 'images[].imageManifest' --output text)
            - echo $MANIFEST
            - aws ecr put-image --repository-name $NGINX_REPOSITORY_NAME --region $AWS_DEFAULT_REGION --image-tag latest --image-manifest "$MANIFEST"
            - echo Writing image definitions file...
            - cd $CODEBUILD_SRC_DIR
            - echo "[{\"name\":\"$API_CONTAINER_NAME\",\"imageUri\":\"$API_REPOSITORY:$IMAGE_TAG\"},{\"name\":\"$NGINX_CONTAINER_NAME\",\"imageUri\":\"$NGINX_REPOSITORY:$IMAGE_TAG\"}]" > imagedefinitions.json
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

resource "aws_codebuild_project" "frontend" {
  name          = "${var.service_name}-${var.environment_identifier}-codebuild-frontend"
  description   = "${var.service_name} frontend CodeBuild project in ${var.environment_identifier}"
  build_timeout = "30"
  service_role  = var.service_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "FRONTEND_REPOSITORY"
      value = var.frontend_repository_url
    }

    environment_variable {
      name  = "FRONTEND_CONTAINER_NAME"
      value = local.frontend_container_name
    }

    environment_variable {
      name  = "FRONTEND_REPOSITORY_NAME"
      value = element(split("/", var.frontend_repository_url), 1)
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${var.service_name}-${var.environment_identifier}-codebuild-ecs"
      stream_name = "cbproject-frontend"
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
            ${local.runtime_language}: ${local.runtime_version}
        pre_build:
          commands:
            - echo Pre Build phase...
            - echo Logging in Amazon ECR...
            - AWS_ACCOUNT_ID=$(echo $CODEBUILD_BUILD_ARN | cut -f 5 -d :)
            - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
            - IMAGE_TAG="$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | sed 's/^[^a-zA-Z0-9_]*//' | head -c 8)"
            - echo trivy install...
            - rpm -ivh https://github.com/aquasecurity/trivy/releases/download/v0.34.0/trivy_0.34.0_Linux-64bit.rpm
        build:
          commands:
            - echo Build phase...
            - echo Build frontend...
            - cd $CODEBUILD_SRC_DIR/program/frontend
            - docker build -t $FRONTEND_REPOSITORY:latest -f docker/Dockerfile.prod .
            - docker tag $FRONTEND_REPOSITORY:latest $FRONTEND_REPOSITORY:$IMAGE_TAG
        post_build:
          commands:
            - echo Post Build phase...
            - echo Image scanning...
            - trivy image $FRONTEND_REPOSITORY:$IMAGE_TAG --severity CRITICAL --no-progress --security-checks vuln --vuln-type library --exit-code 1 --timeout 15m
            - echo Push frontend...
            - docker push $FRONTEND_REPOSITORY:$IMAGE_TAG
            - echo $IMAGE_TAG $FRONTEND_REPOSITORY_NAME
            - MANIFEST=$(aws ecr batch-get-image --repository-name $FRONTEND_REPOSITORY_NAME --region $AWS_DEFAULT_REGION --image-ids imageTag=$IMAGE_TAG --query 'images[].imageManifest' --output text)
            - echo $MANIFEST
            - aws ecr put-image --repository-name $FRONTEND_REPOSITORY_NAME --region $AWS_DEFAULT_REGION --image-tag latest --image-manifest "$MANIFEST"
            - echo Writing image definitions file...
            - cd $CODEBUILD_SRC_DIR
            - echo "[{\"name\":\"$FRONTEND_CONTAINER_NAME\",\"imageUri\":\"$FRONTEND_REPOSITORY:$IMAGE_TAG\"}]" > imagedefinitions.json
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
    Name = "${var.service_name}-${var.environment_identifier}-codebuild-frontend"
  }
}


resource "aws_codebuild_project" "fluentbit" {
  name          = "${var.service_name}-${var.environment_identifier}-codebuild-fluentbit"
  description   = "${var.service_name} fluentbit CodeBuild project in ${var.environment_identifier}"
  build_timeout = "30"
  service_role  = var.service_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "FLUENTBIT_REPOSITORY"
      value = var.fluentbit_repository_url
    }

    environment_variable {
      name  = "FLUENTBIT_CONTAINER_NAME"
      value = local.fluentbit_container_name
    }

    environment_variable {
      name  = "FLUENTBIT_REPOSITORY_NAME"
      value = element(split("/", var.fluentbit_repository_url), 1)
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${var.service_name}-${var.environment_identifier}-codebuild-ecs"
      stream_name = "cbproject-fluentbit"
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
            ${local.runtime_language}: ${local.runtime_version}
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
            - cd $CODEBUILD_SRC_DIR/program/fluentbit
            - echo Build fluentbit...
            - docker build -t $FLUENTBIT_REPOSITORY:latest .
            - docker tag $FLUENTBIT_REPOSITORY:latest $FLUENTBIT_REPOSITORY:$IMAGE_TAG
        post_build:
          commands:
            - echo Post Build phase...
            - echo Push fluentbit...
            - docker push $FLUENTBIT_REPOSITORY:$IMAGE_TAG
            - echo $IMAGE_TAG $FLUENTBIT_REPOSITORY_NAME
            - MANIFEST=$(aws ecr batch-get-image --repository-name $FLUENTBIT_REPOSITORY_NAME --region $AWS_DEFAULT_REGION --image-ids imageTag=$IMAGE_TAG --query 'images[].imageManifest' --output text)
            - echo $MANIFEST
            - aws ecr put-image --repository-name $FLUENTBIT_REPOSITORY_NAME --region $AWS_DEFAULT_REGION --image-tag latest --image-manifest "$MANIFEST"
            - echo Writing image definitions file...
            - cd $CODEBUILD_SRC_DIR
            - echo "[{\"name\":\"$FLUENTBIT_CONTAINER_NAME\",\"imageUri\":\"$FLUENTBIT_REPOSITORY:$IMAGE_TAG\"}]" > imagedefinitions.json
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
    Name = "${var.service_name}-${var.environment_identifier}-codebuild-fluentbit"
  }
}

resource "aws_cloudwatch_log_group" "ecs_cluster_container_insight" {
  name = "/aws/codebuild/${var.service_name}-${var.environment_identifier}-codebuild-ecs"
  retention_in_days = 90
}
