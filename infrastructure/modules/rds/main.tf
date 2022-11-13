
locals {
  is_dev_environment = var.environment_identifier == "dev" ? true : false
  db_instance_count  = local.is_dev_environment ? 1 : 2
}

################################################################################
# DB Subnet Group
################################################################################

resource "aws_db_subnet_group" "this" {

  name        = "${var.service_name}-${var.environment_identifier}-subnetgroup"
  description = "For Aurora cluster ${var.service_name}"
  subnet_ids  = var.db_subnet_ids

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-subnetgroup"
  }
}

################################################################################
# Cluster
################################################################################

resource "aws_rds_cluster" "this" {
  cluster_identifier              = "${var.service_name}-${var.environment_identifier}-db-cluster"
  apply_immediately               = var.apply_immediately
  skip_final_snapshot             = true
  availability_zones              = var.azs
  backup_retention_period         = var.backup_retention_period
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.id
  db_subnet_group_name            = aws_db_subnet_group.this.id
  deletion_protection             = var.deletion_protection
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports_postgresql
  engine                          = var.aurora_cluster_engine
  engine_version                  = var.aurora_cluster_engine_version
  kms_key_id                      = var.kms_key_arn
  master_password                 = var.master_password
  master_username                 = var.master_username
  port                            = var.aurora_cluster_port
  preferred_backup_window         = var.preferred_backup_window
  preferred_maintenance_window    = var.preferred_maintenance_window
  storage_encrypted               = true
  vpc_security_group_ids          = [ var.sg_rds_id ]

  lifecycle {
    ignore_changes = [
      availability_zones
    ]
  }

  depends_on = [
    aws_cloudwatch_log_group.db_cluster_postgresql
  ]

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-db-cluster"
  }
}

################################################################################
# Cluster Instance(s)
################################################################################

resource "aws_rds_cluster_instance" "this" {
  count = local.db_instance_count

  identifier                   = "${var.service_name}-${var.environment_identifier}-db-instance-${count.index + 1}"
  instance_class               = local.is_dev_environment ?  var.dev_instance_class : var.prd_instance_class
  apply_immediately            = var.apply_immediately
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  availability_zone            = var.azs[count.index]
  cluster_identifier           = aws_rds_cluster.this.id
  db_parameter_group_name      = aws_db_parameter_group.this.id
  db_subnet_group_name         = aws_db_subnet_group.this.id
  engine                       = var.aurora_cluster_engine
  engine_version               = var.aurora_cluster_engine_version
  monitoring_interval          = var.monitoring_interval
  monitoring_role_arn          = aws_iam_role.rds_enhanced_monitoring.arn
  performance_insights_enabled = var.performance_insights_enabled
  preferred_maintenance_window = var.preferred_maintenance_window

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-db-instance-${count.index + 1}"
  }
}

################################################################################
# Enhanced Monitoring
################################################################################

data "aws_iam_policy_document" "monitoring_rds_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = "${var.service_name}-${var.environment_identifier}-role-db-monitoring"

  assume_role_policy  = data.aws_iam_policy_document.monitoring_rds_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  ]

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-role-db-monitoring"
  }
}

################################################################################
# Cluster Parameter Group
################################################################################

resource "aws_rds_cluster_parameter_group" "this" {
  name        = "${var.service_name}-${var.environment_identifier}-cluster-parametergroup"
  description = var.db_cluster_parameter_group_description
  family      = var.db_cluster_parameter_group_family

  dynamic "parameter" {
    for_each = var.db_cluster_parameter_group_parameters

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      # apply_method = "immediate"
      apply_method = "pending-reboot"
    }
  }

  lifecycle {
    ignore_changes = [
      parameter
    ]
  }

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-cluster-parametergroup"
  }
}

################################################################################
# DB Parameter Group
################################################################################

resource "aws_db_parameter_group" "this" {
  name        = "${var.service_name}-${var.environment_identifier}-db-parametergroup"
  description = var.db_parameter_group_description
  family      = var.db_parameter_group_family

  dynamic "parameter" {
    for_each = var.db_parameter_group_parameters

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      # apply_method = "immediate"
      apply_method = "pending-reboot"
    }
  }

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-db-parametergroup"
  }
}

################################################################################
# DB CloudWatch Logs
################################################################################
resource "aws_cloudwatch_log_group" "db_cluster_postgresql" {
  name              = "/aws/rds/cluster/${var.service_name}-${var.environment_identifier}-db-cluster/postgresql"
  retention_in_days = 90
}
