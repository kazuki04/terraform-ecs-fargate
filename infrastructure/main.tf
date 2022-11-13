terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
  }
}

provider "aws" {
  region  = "${local.region}"
}

provider "aws" {
  alias   = "use1"
  region  = "us-east-1"
}

locals {
  service_name           = "${var.service_name}"
  backend_buckent_name   = "${var.backend_buckent_name}"
  environment_identifier = "${var.environment_identifier}"
  region                 = "${var.region}"
}

module "iam" {
  source                 = "./modules/iam"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier

  topic_alarm_arn = module.sns.topic_alarm_arn
}

module "network" {
  source                 = "./modules/network"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier

  region             = local.region
  vpc_cidr           = var.vpc_cidr
  azs                = var.azs
  ingress_subnets    = var.ingress_subnets
  app_subnets        = var.app_subnets
  db_subnets         = var.db_subnets
  egress_subnets     = var.egress_subnets
  codebuild_subnets  = var.codebuild_subnets
  management_subnets = var.management_subnets
  vpc_endpoints      = var.vpc_endpoints
}

module "security_group" {
  source                 = "./modules/security_group"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier

  vpc_id = module.network.vpc_id
}

module "kms" {
  source = "./modules/kms"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier
}

module "secretsmanager" {
  source = "./modules/secretsmanager"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier

  kms_key_arn        = module.kms.arn
  exclude_characters = var.exclude_characters
}

module "s3" {
  source = "./modules/s3"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier

  kms_key_arn           = module.kms.arn
  codebuild_role_arn    = module.iam.codebuild_role_arn
  codepipeline_role_arn = module.iam.codepipeline_role_arn
}

module "cloudfront" {
  source = "./modules/cloudfront"
  providers = {
    aws = aws.use1
   }
  service_name           = local.service_name
  environment_identifier = local.environment_identifier

  alb_origin_dns_name          = module.alb.ingress_alb_dns_name
  cloudfron_bucket_domain_name = module.s3.cloudfron_bucket_domain_name
  cloudfront_enabled           = var.cloudfront_enabled
  http_version                 = var.http_version
  price_class                  = var.price_class
  viewer_certificate           = var.viewer_certificate
  cf_custom_header_name        = var.cf_custom_header_name
  cf_custom_header_value       = var.cf_custom_header_value
}

module "alb" {
  source                 = "./modules/alb"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier

  vpc_id           = module.network.vpc_id
  subnets          = module.network.ingress_subnet_ids
  sg_ingress_lb_id = module.security_group.sg_ingress_lb_id
}

module "ecr" {
  source                 = "./modules/ecr"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier
}
module "ecs" {
  source                 = "./modules/ecs"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier

  vpc_id                       = module.network.vpc_id
  app_subnets                  = module.network.app_subnet_ids
  api_target_group_arn         = module.alb.api_target_group_arn
  sg_app_id                    = module.security_group.sg_app_id
  sg_ingress_lb_id             = module.security_group.sg_ingress_lb_id
  task_execution_role_arn      = module.iam.task_execution_role_arn
  task_role_arn                = module.iam.task_role_arn
  api_repository_url           = module.ecr.api_repository_url
  nginx_repository_url         = module.ecr.nginx_repository_url
  frontend_repository_url      = module.ecr.frontend_repository_url
  fluentbit_repository_url     = module.ecr.fluentbit_repository_url
  secretsmanager_secret_db_arn = module.secretsmanager.aws_secretsmanager_secret_db_arn
  endpoint                     = module.rds.endpoint
  frontend_target_group_arn    = module.alb.frontend_target_group_arn
  cloudfront_domain_name       = module.cloudfront.domain_name
  program_log_bucket_name      = module.s3.program_log_bucket_id
  api_container_count          = var.api_container_count
  api_container_cpu            = var.api_container_cpu
  api_container_memory         = var.api_container_memory
  frontend_container_count     = var.frontend_container_count
  frontend_container_cpu       = var.frontend_container_cpu
  frontend_container_memory    = var.frontend_container_memory
  master_username              = var.master_username
  rails_env                    = var.rails_env
  secret_key_base              = var.secret_key_base
}

module "rds" {
  source                 = "./modules/rds"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier

  kms_key_arn                                = module.kms.arn
  master_password                            = module.secretsmanager.aws_secretsmanager_secret_db_password
  db_subnet_ids                              = module.network.db_subnet_ids
  sg_rds_id                                  = module.security_group.sg_rds_id
  master_username                            = var.master_username
  azs                                        = var.azs
  aurora_cluster_engine                      = var.aurora_cluster_engine
  aurora_cluster_engine_version              = var.aurora_cluster_engine_version
  db_cluster_parameter_group_description     = var.db_cluster_parameter_group_description
  db_cluster_parameter_group_family          = var.db_cluster_parameter_group_family
  db_cluster_parameter_group_parameters      = var.db_cluster_parameter_group_parameters
  db_parameter_group_parameters              = var.db_parameter_group_parameters
  db_parameter_group_description             = var.db_parameter_group_description
  db_parameter_group_family                  = var.db_parameter_group_family
  preferred_backup_window                    = var.preferred_backup_window
  backup_retention_period                    = var.backup_retention_period
  deletion_protection                        = var.deletion_protection
  enabled_cloudwatch_logs_exports_postgresql = var.enabled_cloudwatch_logs_exports_postgresql
  aurora_cluster_port                        = var.aurora_cluster_port
  preferred_maintenance_window               = var.preferred_maintenance_window
  auto_minor_version_upgrade                 = var.auto_minor_version_upgrade
  dev_instance_class                         = var.dev_instance_class
  prd_instance_class                         = var.prd_instance_class
  monitoring_interval                        = var.monitoring_interval
  performance_insights_enabled               = var.performance_insights_enabled
}

module "codebuild" {
  source                 = "./modules/codebuild"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier

  vpc_id                        = module.network.vpc_id
  codebuild_subnet_ids          = module.network.codebuild_subnet_ids
  sg_codebuild_id               = module.security_group.sg_codebuild_id
  api_repository_url            = module.ecr.api_repository_url
  nginx_repository_url          = module.ecr.nginx_repository_url
  fluentbit_repository_url      = module.ecr.fluentbit_repository_url
  frontend_repository_url       = module.ecr.frontend_repository_url
  service_role_arn              = module.iam.codebuild_role_arn
  runtime_version_for_codebuild = var.runtime_version_for_codebuild
}

module "codepipeline" {
  source                 = "./modules/codepipeline"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier

  code_build_api_arn        = module.codebuild.code_build_api_arn
  code_build_fluentbit_arn  = module.codebuild.code_build_fluentbit_arn
  code_build_frontend_arn   = module.codebuild.code_build_frontend_arn
  ecs_cluster_arn           = module.ecs.cluster_arn
  api_service_name          = module.ecs.api_service_name
  frontend_service_name     = module.ecs.frontend_service_name
  codepipeline_role_arn     = module.iam.codepipeline_role_arn
  kms_key_arn               = module.kms.arn
  artifact_bucket_id        = module.s3.artifact_bucket_id
  repository_name           = var.repository_name
}

module "waf" {
  source                 = "./modules/waf"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier

  ingress_alb_arn        = module.alb.ingress_alb_arn
  cf_custom_header_name  = var.cf_custom_header_name
  cf_custom_header_value = var.cf_custom_header_value
}


module "sns" {
  source                 = "./modules/sns"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier

  kms_key_arn             = module.kms.arn
  lambda_notify_slack_arn = module.lambda.lambda_notify_slack_arn
}

module "monitoring" {
  source                 = "./modules/monitoring"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier

  backend_error_log_arn         = module.ecs.backend_error_log_arn
  ecs_cluster_arn               = module.ecs.cluster_arn
  ecs_taskdef_api_arn           = module.ecs.api_taskdef_arn
  ecs_taskdef_frontend_arn      = module.ecs.frontend_taskdef_arn
  db_cluster_postgresql_arn     = module.rds.aws_rds_cluster_arn
  db_cluster_postgresql_log_arn = module.rds.db_cluster_postgresql_log_arn
  sns_topic_alarm_id            = module.sns.topic_alarm_id
}

module "lambda" {
  source                 = "./modules/lambda"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier

  lambda_notify_slack_role_arn = module.iam.lambda_notify_slack_role_arn
  lambda_runtime               = var.lambda_runtime
  topic_alarm_arn              = module.sns.topic_alarm_arn
  slack_webhook_url            = var.slack_webhook_url
  channel_name                 = var.channel_name
  username                     = var.username
}
