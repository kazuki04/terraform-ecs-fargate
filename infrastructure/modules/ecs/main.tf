locals {
  backend_error_log_group_name = element(split(":" , aws_cloudwatch_log_group.ecs_backend_error.arn), 6)
}

data "aws_region" "current" {}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_ecs_task_definition" "api" {
  task_definition = aws_ecs_task_definition.api.family
}

data "aws_ecs_task_definition" "frontend" {
  task_definition = aws_ecs_task_definition.frontend.family
}

resource "aws_ecs_cluster" "this" {
  name = "${var.service_name}-${var.environment_identifier}-ecscluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  depends_on = [
    aws_cloudwatch_log_group.ecs_cluster_container_insight
  ]

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-ecscluster"
  }
}

resource "aws_ecs_service" "api" {
  name    = "${var.service_name}-${var.environment_identifier}-ecsservice-api"
  cluster = aws_ecs_cluster.this.id

  desired_count                      = var.api_container_count
  force_new_deployment               = true
  health_check_grace_period_seconds  = 120
  launch_type                        = "FARGATE"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  enable_execute_command             = true
  task_definition                    = data.aws_ecs_task_definition.api.arn


  load_balancer {
    target_group_arn = var.api_target_group_arn
    container_name   = "nginx"
    container_port   = 80
  }

  network_configuration {
    subnets          = var.app_subnets
    security_groups  = [ var.sg_app_id ]
    assign_public_ip = true
  }

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-ecsservice-api"
  }

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }
}

resource "aws_ecs_task_definition" "api" {
  family                   = "${var.service_name}-${var.environment_identifier}-taskdef-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.api_container_cpu
  memory                   = var.api_container_memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn
  skip_destroy             = true


  container_definitions = <<-EOT
  [
    {
      "name": "api",
      "cpu": 0,
      "mountPoints": [],
      "image": "${var.api_repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8000,
          "hostPort": 8000,
          "protocol": "tcp"
        }
      ],
      "volumesFrom": [],
      "logConfiguration": {
        "logDriver": "awsfirelens",
        "secretOptions": [],
        "options": {}
      },
      "linuxParameters": {
        "initProcessEnabled": true
      },
      "environment": [
        {
          "name": "POSTGRES_HOST",
          "value": "${var.endpoint}"
        },
        {
          "name": "POSTGRES_USER",
          "value": "${var.master_username}"
        },
        {
          "name": "CLOUDFRONT_HOST",
          "value": "${var.cloudfront_domain_name}"
        },
        {
          "name": "RAILS_ENV",
          "value": "${var.rails_env}"
        },
        {
          "name": "SECRET_KEY_BASE",
          "value": "${var.secret_key_base}"
        }
      ],
      "secrets": [
        {
          "name": "POSTGRES_PASSWORD",
          "valueFrom": "${var.secretsmanager_secret_db_arn}"
        }
      ]
    },
    {
      "name": "nginx",
      "image": "${var.nginx_repository_url}",
      "essential": true,
      "cpu": 0,
      "mountPoints": [],
      "environment": [],
      "portMappings": [
        {
          "containerPort": 80
        }
      ],
      "volumesFrom": [
        {
          "sourceContainer": "api",
          "readOnly": true
        }
      ],
      "logConfiguration": {
        "logDriver": "awsfirelens",
        "secretOptions": [],
        "options": {}
      },
      "linuxParameters": {
        "initProcessEnabled": true
      }
    },
    {
      "name": "fluentbit",
      "image": "${var.fluentbit_repository_url}",
      "essential": true,
       "cpu": 0,
       "mountPoints": [],
       "portMappings":[],
       "user": "0",
       "volumesFrom": [],
      "firelensConfiguration": {
        "type": "fluentbit",
        "options": {
          "config-file-type": "file",
          "config-file-value": "/fluent-bit/etc/backend/extra.conf"
        }
      },
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${var.service_name}-${var.environment_identifier}-ecs-taskdef-fluentbit",
          "awslogs-region": "${data.aws_region.current.name}",
          "awslogs-create-group": "true",
          "awslogs-stream-prefix": "fluentbit"
        }
      },
      "linuxParameters": {
        "initProcessEnabled": true
      },
      "environment": [
        {
          "name": "SERVICE_NAME",
          "value": "${var.service_name}"
        },
        {
          "name": "ENVIRONMENT_IDENTIFIER",
          "value": "${var.environment_identifier}"
        },
        {
          "name": "AWS_REGION",
          "value": "${data.aws_region.current.name}"
        },
        {
          "name": "BACKEND_ERROR_LOG_GROUP_NAME",
          "value": "${local.backend_error_log_group_name}"
        },
        {
          "name": "PROGRAM_LOG_BUCKET",
          "value": "${var.program_log_bucket_name}"
        }
      ]
    }
  ]
  EOT
}
resource "aws_ecs_service" "frontend" {
  name    = "${var.service_name}-${var.environment_identifier}-ecsservice-frontend"
  cluster = aws_ecs_cluster.this.id

  desired_count                      = var.frontend_container_count
  force_new_deployment               = true
  health_check_grace_period_seconds  = 360
  launch_type                        = "FARGATE"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  enable_execute_command             = true
  task_definition                    = data.aws_ecs_task_definition.frontend.arn

  load_balancer {
    target_group_arn = var.frontend_target_group_arn
    container_name   = "frontend"
    container_port   = 3000
  }

  network_configuration {
    subnets          = var.app_subnets
    security_groups  = [ var.sg_app_id ]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [
      desired_count 
    ]
  }

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-ecsservice-frontend"
  }
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.service_name}-${var.environment_identifier}-taskdef-frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.frontend_container_cpu
  memory                   = var.frontend_container_memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn
  skip_destroy             = true

  container_definitions = <<-EOT
  [
    {
      "name": "frontend",
      "cpu":  0,
      "environment": [],
      "mountPoints": [],
      "image": "${var.frontend_repository_url}",
      "essential": true,
      "volumesFrom": [],
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000,
          "protocol": "tcp" 
        }
      ],
      "logConfiguration": {
        "logDriver": "awsfirelens",
        "secretOptions": [],
        "options": {}
      },
      "linuxParameters": {
        "initProcessEnabled": true
      }
    },
    {
      "name": "fluentbit",
      "image": "${var.fluentbit_repository_url}",
      "essential": true,
      "cpu": 0,
      "mountPoints": [],
      "portMappings": [],
      "user": "0",
      "volumesFrom": [],
      "firelensConfiguration": {
        "type": "fluentbit",
        "options": {
          "config-file-type": "file",
          "config-file-value": "/fluent-bit/etc/frontend/extra.conf"
        }
      },
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${var.service_name}-${var.environment_identifier}-ecs-taskdef-fluentbit",
          "awslogs-region": "${data.aws_region.current.name}",
          "awslogs-create-group": "true",
          "awslogs-stream-prefix": "fluentbit"
        }
      },
      "linuxParameters": {
        "initProcessEnabled": true
      },
      "environment": [
        {
          "name": "SERVICE_NAME",
          "value": "${var.service_name}"
        },
        {
          "name": "ENVIRONMENT_IDENTIFIER",
          "value": "${var.environment_identifier}"
        },
        {
          "name": "AWS_REGION",
          "value": "${data.aws_region.current.name}"
        },
        {
          "name": "BACKEND_ERROR_LOG_GROUP_NAME",
          "value": "${local.backend_error_log_group_name}"
        },
        {
          "name": "PROGRAM_LOG_BUCKET",
          "value": "${var.program_log_bucket_name}"
        }
      ]
    }
  ]
  EOT
}

resource "aws_cloudwatch_log_group" "ecs_taskdef_api" {
  name              = "${var.service_name}-${var.environment_identifier}-ecs-taskdef-api"
  retention_in_days = 90
}

resource "aws_cloudwatch_log_group" "ecs_taskdef_frontend" {
  name              = "${var.service_name}-${var.environment_identifier}-ecs-taskdef-frontend"
  retention_in_days = 90
}

resource "aws_cloudwatch_log_group" "ecs_taskdef_fluentbit" {
  name              = "${var.service_name}-${var.environment_identifier}-ecs-taskdef-fluentbit"
  retention_in_days = 90
}

resource "aws_cloudwatch_log_group" "ecs_backend_error" {
  name              = "${var.service_name}-${var.environment_identifier}-logs-backend-error"
  retention_in_days = 90
}

resource "aws_cloudwatch_log_group" "ecs_cluster_container_insight" {
  name              = "/aws/ecs/containerinsights/${var.service_name}-${var.environment_identifier}-ecscluster/performance"
  retention_in_days = 90
}
