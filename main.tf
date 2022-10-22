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
  profile = "${var.profile}"
}

locals {
  service_name              = "${var.service_name}"
  backend_buckent_name      = "${var.backend_buckent_name}"
  environment_identifier    = "${var.environment_identifier}"
  region                    = "${var.region}"
}

module "iam" {
  source                 = "./modules/iam"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier
}

module "network" {
  source                 = "./modules/network"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier

  region                 = local.region
  vpc_cidr               = var.vpc_cidr
  azs                    = var.azs
  ingress_subnets        = var.ingress_subnets
  app_subnets            = var.app_subnets
  db_subnets             = var.db_subnets
  egress_subnets         = var.egress_subnets
  code_build_subnets     = var.code_build_subnets
  management_subnets     = var.management_subnets
  vpc_endpoints          = var.vpc_endpoints
}

module "security_group" {
  source                 = "./modules/security_group"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier

  vpc_id  = module.network.vpc_id
}

module "kms" {
  source = "./modules/kms"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier
}

module "alb" {
  source                 = "./modules/alb"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier

  vpc_id  = module.network.vpc_id
  subnets = module.network.ingress_subnet_ids
  sg_ingress_lb_id = module.security_group.sg_ingress_lb_id
}

module "ecr" {
  source                 = "./modules/ecr"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier
}

module "code_build" {
  source                 = "./modules/code_build"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier

  vpc_id                         = module.network.vpc_id
  code_build_subnet_ids          = module.network.code_build_subnet_ids
  sg_code_build_id               = module.security_group.sg_code_build_id
  api_repository_url             = module.ecr.api_repository_url
  service_role_arn               = module.iam.code_build_role_arn
  runtime_version_for_code_build = var.runtime_version_for_code_build
}

