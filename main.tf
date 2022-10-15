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

module "ecr" {
  source                 = "./modules/ecr"
  service_name           = local.service_name
  environment_identifier = local.environment_identifier
}
