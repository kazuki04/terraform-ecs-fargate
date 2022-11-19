locals {
  rds_memory_threshold                 = 95
  backend_error_log_group_name         = element(split(":", var.backend_error_log_arn), 6)
  db_cluster_postgresql_log_group_name = element(split(":", var.db_cluster_postgresql_log_arn), 6)
  ecs_cluster_name                     = element(split("/", var.ecs_cluster_arn), 1)
  task_definition_family_api           = element(split(":", element(split("/", var.ecs_taskdef_api_arn), 1)), 0)
  db_cluster_name                      = element(split(":", var.db_cluster_postgresql_arn), 6)
  db_t3_medium_memory_byte             = 1024 * 1024 * 4
  log_levels                           = [ "fatal", "error" ]

  metric_query_ecs_cpu = [
    {
      id          = "e1"
      expression  = "m2/m1*100"
      label       = "CPU uses over 80% usages"
      return_data = "true"
    },
    {
      id    = "m1"
      lavel = "CpuReserved"

      metric = [
        {
          metric_name = "CpuReserved"
          namespace   = "ECS/ContainerInsights"
          period      = 300
          stat        = "Average"
          dimensions  = {
            ClusterName          = local.ecs_cluster_name
            TaskDefinitionFamily = local.task_definition_family_api
          }
        }
      ]
    },
    {
      id = "m2"
      lavel = "CpuUtilized"

      metric = [
        {
          metric_name = "CpuUtilized"
          namespace   = "ECS/ContainerInsights"
          period      = 300
          stat        = "Average"
          dimensions  = {
            ClusterName          = local.ecs_cluster_name
            TaskDefinitionFamily = local.task_definition_family_api
          }
        }
      ]
    }
  ]

  metric_query_ecs_memory = [
    {
      id          = "e1"
      expression  = "m2/m1*100"
      label       = "Memory uses over 80% usages"
      return_data = "true"
    },
    {
      id = "m1"
      lavel = "MemoryReserved"

      metric = [
        {
          metric_name = "MemoryReserved"
          namespace   = "ECS/ContainerInsights"
          period      = 300
          stat        = "Average"
          unit        = "Megabytes"
          dimensions  = {
            ClusterName          = local.ecs_cluster_name
            TaskDefinitionFamily = local.task_definition_family_api
          }
        }
      ]
    },
    {
      id    = "m2"
      lavel = "MemoryUtilized"

      metric = [
        {
          metric_name = "MemoryUtilized"
          namespace   = "ECS/ContainerInsights"
          period      = 300
          stat        = "Average"
          unit        = "Megabytes"
          dimensions  = {
            ClusterName          = local.ecs_cluster_name
            TaskDefinitionFamily = local.task_definition_family_api
          }
        }
      ]
    }
  ]

  aurora_cpu_alarm = {
    writer = {
      threshold = 80
      period    = 300
      statistic = "Average"
    }
  }

  aurora_memory_alarm = {
    writer = {
      threshold = 1024 * 1024
      period    = 300
      statistic = "Average"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {
  alarm_name        = "${var.service_name}-${var.environment_identifier}-cwalarm-ecs-cpu"
  alarm_description = "The alarm triggers when ECS CPU usage exceeds a threshold value"
  actions_enabled   = "true"

  alarm_actions             = [var.sns_topic_alarm_id]
  ok_actions                = [var.sns_topic_alarm_id]
  insufficient_data_actions = [var.sns_topic_alarm_id]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 80

  datapoints_to_alarm = 1
  treat_missing_data  = "missing"

  dynamic "metric_query" {
    for_each = local.metric_query_ecs_cpu
    content {
      id          = lookup(metric_query.value, "id")
      label       = lookup(metric_query.value, "label", null)
      return_data = lookup(metric_query.value, "return_data", null)
      expression  = lookup(metric_query.value, "expression", null)

      dynamic "metric" {
        for_each = lookup(metric_query.value, "metric", [])
        content {
          metric_name = lookup(metric.value, "metric_name")
          namespace   = lookup(metric.value, "namespace")
          period      = lookup(metric.value, "period")
          stat        = lookup(metric.value, "stat")
          unit        = lookup(metric.value, "unit", null)
          dimensions  = lookup(metric.value, "dimensions", null)
        }
      }
    }
  }

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-cwalarm-ecs-cpu"
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory" {
  alarm_name        = "${var.service_name}-${var.environment_identifier}-cwalarm-ecs-memory"
  alarm_description = "The alarm triggers when ECS Memory usage exceeds a threshold value"
  actions_enabled   = "true"

  alarm_actions             = [var.sns_topic_alarm_id]
  ok_actions                = [var.sns_topic_alarm_id]
  insufficient_data_actions = [var.sns_topic_alarm_id]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 80

  datapoints_to_alarm = 1
  treat_missing_data  = "missing"

  dynamic "metric_query" {
    for_each = local.metric_query_ecs_memory
    content {
      id          = lookup(metric_query.value, "id")
      label       = lookup(metric_query.value, "label", null)
      return_data = lookup(metric_query.value, "return_data", null)
      expression  = lookup(metric_query.value, "expression", null)

      dynamic "metric" {
        for_each = lookup(metric_query.value, "metric", [])
        content {
          metric_name = lookup(metric.value, "metric_name")
          namespace   = lookup(metric.value, "namespace")
          period      = lookup(metric.value, "period")
          stat        = lookup(metric.value, "stat")
          unit        = lookup(metric.value, "unit", null)
          dimensions  = lookup(metric.value, "dimensions", null)
        }
      }
    }
  }

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-cwalarm-ecs-cpu"
  }
}

################################################################################
# Aurora
################################################################################
resource "aws_cloudwatch_metric_alarm" "aurora_cpu" {
  for_each = local.aurora_cpu_alarm

  alarm_name        = "${var.service_name}-${var.environment_identifier}-cwalarm-aurora-${each.key}-cpu"
  alarm_description = "The alarm triggers when Aurora CPU usage exceeds a threshold value"
  actions_enabled   = "true"

  alarm_actions             = [var.sns_topic_alarm_id]
  ok_actions                = [var.sns_topic_alarm_id]
  insufficient_data_actions = [var.sns_topic_alarm_id]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = each.value.threshold

  datapoints_to_alarm = 1
  treat_missing_data  = "missing"

  namespace    = "AWS/RDS"
  metric_name  = "CPUUtilization"
  unit         = "Percent"
  period       = each.value.period
  statistic    = each.value.statistic

  dimensions = {
    DBClusterIdentifier = local.db_cluster_name
    Role                = upper(each.key)
  }

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-cwalarm-aurora-cpu"
  }
}

resource "aws_cloudwatch_metric_alarm" "aurora_memory" {
  for_each = local.aurora_memory_alarm

  alarm_name        = "${var.service_name}-${var.environment_identifier}-cwalarm-aurora-${each.key}-memory"
  alarm_description = "The alarm triggers when Aurora Memory usage exceeds a threshold value"
  actions_enabled   = "true"

  alarm_actions             = [var.sns_topic_alarm_id]
  ok_actions                = [var.sns_topic_alarm_id]
  insufficient_data_actions = [var.sns_topic_alarm_id]

  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = local.db_t3_medium_memory_byte * 0.05 

  datapoints_to_alarm = 1
  treat_missing_data  = "missing"

  namespace    = "AWS/RDS"
  metric_name  = "FreeableMemory"
  unit         = "Bytes"
  period       = each.value.period
  statistic    = each.value.statistic

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-cwalarm-aurora-memory"
  }
}
################################################################################
# Metric filter
################################################################################

resource "aws_cloudwatch_log_metric_filter" "backend_fatal" {
  name           = "${var.service_name}-${var.environment_identifier}-metricfilter-backend-fatal"
  pattern        = <<PATTERN
   "\"level\":\"FATAL\""
  PATTERN
  log_group_name = local.backend_error_log_group_name

  metric_transformation {
    namespace = "${var.service_name}-${var.environment_identifier}-Monitoring"
    name      = "${var.service_name}-${var.environment_identifier}-ecs-backend-fatal"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "backend_error" {
  name           = "${var.service_name}-${var.environment_identifier}-metricfilter-backend-error"
  pattern        = <<PATTERN
   "\"level\":\"ERROR\""
  PATTERN
  log_group_name = local.backend_error_log_group_name

  metric_transformation {
    namespace = "${var.service_name}-${var.environment_identifier}-Monitoring"
    name      = "${var.service_name}-${var.environment_identifier}-ecs-backend-error"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "postgresql_fatal" {
  name           = "${var.service_name}-${var.environment_identifier}-metricfilter-postgresql-fatal"
  pattern        = "[(log = \"*FATAL*\") && (log != \"*the database system is starting up*\") && (log != \"*terminating connection due to administrator command*\")]"
  log_group_name = local.db_cluster_postgresql_log_group_name

  metric_transformation {
    namespace = "${var.service_name}-${var.environment_identifier}-Monitoring"
    name      = "${var.service_name}-${var.environment_identifier}-ecs-postgresql-fatal"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "postgresql_error" {
  name           = "${var.service_name}-${var.environment_identifier}-metricfilter-postgresql-error"
  pattern        = "[(log = \"*ERROR*\") && (log != \"*the database system is starting up*\") && (log != \"*terminating connection due to administrator command*\")]"
  log_group_name = local.db_cluster_postgresql_log_group_name

  metric_transformation {
    namespace = "${var.service_name}-${var.environment_identifier}-Monitoring"
    name      = "${var.service_name}-${var.environment_identifier}-ecs-postgresql-error"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "api_metric" {
  for_each = local.log_levels

  alarm_name        = "${var.service_name}-${var.environment_identifier}-cwalarm-ecs-api-${each.key}"
  alarm_description = "The alarm triggers when api ${each.key} metrics exceeds a threshold value"
  actions_enabled   = "true"

  alarm_actions             = [var.sns_topic_alarm_id]
  ok_actions                = [var.sns_topic_alarm_id]
  insufficient_data_actions = [var.sns_topic_alarm_id]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1

  datapoints_to_alarm = 1
  treat_missing_data  = "missing"

  namespace    = "${var.service_name}-${var.environment_identifier}-Monitoring"
  metric_name  = "fargate-sample-dev-ecs-backend-${each.key}"
  unit         = "None"
  period       = 300
  statistic    = "Average"

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-cwalarm-ecs-api-${each.key}"
  }
}
