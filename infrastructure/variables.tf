variable "profile" {
  description = "AWS Configuretion Profile"
  type        = string
  default     = ""
}

variable "region" {
  description = "The region name"
  type        = string
  default     = ""
}

variable "repository_name" {
  description = "The name of repository"
  type        = string
  default     = ""
}

variable "backend_buckent_name" {
  description = "The backend bucket name"
  type        = string
  default     = ""
}

variable "service_name" {
  description = "The service Name"
  type        = string
  default     = ""
}

variable "environment_identifier" {
  description = "The environment identifier"
  type        = string
  default     = ""
}

################################################################################
# Network
################################################################################

variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC."
  type        = string
  default     = ""
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "ingress_subnets" {
  description = "A list of public subnets for ingress inside the VPC"
  type        = list(string)
  default     = []
}

variable "app_subnets" {
  description = "A list of private subnets for appliction inside the VPC"
  type        = list(string)
  default     = []
}

variable "db_subnets" {
  description = "A list of private subnets for database inside the VPC"
  type        = list(string)
  default     = []
}

variable "egress_subnets" {
  description = "A list of private subnets for egress inside the VPC"
  type        = list(string)
  default     = []
}

variable "codebuild_subnets" {
  description = "A list of private subnets for codebuild inside the VPC"
  type        = list(string)
  default     = []
}

variable "management_subnets" {
  description = "A list of private subnets for management inside the VPC"
  type        = list(string)
  default     = []
}

variable "vpc_endpoints" {
  description = "A list of VPC endpoints services"
  type        = list(string)
  default     = []
}

################################################################################
# ECS
################################################################################
variable "api_container_cpu" {
  description = "The CPU of api container"
  type        = number
  default     = 256
}

variable "api_container_memory" {
  description = "The memory of api container"
  type        = number
  default     = 512
}

variable "frontend_container_cpu" {
  description = "The CPU of frontend container"
  type        = number
  default     = 256
}

variable "frontend_container_memory" {
  description = "The memory of frontend container"
  type        = number
  default     = 512
}

variable "runtime_version_for_codebuild" {
  description = "The run time version for CodeBuild Project. For example, nodejs: 14"
  type        = string
  default     = ""
}

variable "api_container_count" {
  description = "The number of api container"
  type        = number
  default     = 0
}

variable "frontend_container_count" {
  description = "The number of frontend containers"
  type        = number
  default     = 0
}

variable "rails_env" {
  description = "The Environment for Rails"
  type        = string
  default     = ""
}

variable "secret_key_base" {
  description = "The secret key base for Rails"
  type        = string
  default     = ""
}

variable "exclude_characters" {
  description = "String of the characters that you don't want in the password."
  type        = string
  default     = ""
}

################################################################################
# RDS
################################################################################
variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window."
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "The days to retain backups for."
  type        = number
  default     = 0
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true. The default is false."
  type        = bool
  default     = true
}

variable "enabled_cloudwatch_logs_exports_postgresql" {
  description = "Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: audit, error, general, slowquery, postgresql (PostgreSQL)."
  type        = list(string)
  default     = []
}

variable "aurora_cluster_engine" {
  description = "The name of the database engine to be used for this DB cluster. Defaults to aurora. Valid Values: aurora, aurora-mysql, aurora-postgresql, mysql, postgres. (Note that mysql and postgres are Multi-AZ RDS clusters)."
  type        = string
  default     = ""
}

variable "aurora_cluster_engine_version" {
  description = "The database engine version. Updating this argument results in an outage. See the Aurora MySQL and Aurora Postgres documentation for your configured engine to determine this value."
  type        = string
  default     = ""
}

variable "aurora_cluster_port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = 5432
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window."
  type        = bool
  default     = false
}

variable "dev_instance_class" {
  description = "The instance class to use in dev environment."
  type        = string
  default     = ""
}

variable "prd_instance_class" {
  description = "The instance class to use in prd environment."
  type        = string
  default     = ""
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60."
  type        = number
  default     = 0
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled or not."
  type        = bool
  default     = true
}

variable "preferred_maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'."
  type        = string
  default     = ""
}

variable "db_cluster_parameter_group_description" {
  description = "ClusterParameterGroup for Aurora PostgreSQL"
  type        = string
  default     = ""
}

variable "db_cluster_parameter_group_family" {
  description = "The family of the DB cluster parameter group."
  type        = string
  default     = ""
}

variable "db_cluster_parameter_group_parameters" {
  description = "A list of DB cluster parameters to apply. Note that parameters may differ from a family to an other."
  type        = list(map(string))
  default     = []
}

variable "db_parameter_group_parameters" {
  description = "A list of DB parameters to apply. Note that parameters may differ from a family to an other"
  type        = list(map(string))
  default     = []
}

variable "db_parameter_group_description" {
  description = "InstanceParameter for Aurora PostgreSQL"
  type        = string
  default     = ""
}

variable "db_parameter_group_family" {
  description = "The family of the DB parameter group"
  type        = string
  default     = ""
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter.Time in UTC. Default: A 30-minute window selected at random from an 8-hour block of time per regionE.g., 04:00-09:00"
  type        = string
  default     = ""
}

variable "master_password" {
  description = "Password for the master DB user. Note - when specifying a value here, 'create_random_password' should be set to `false`"
  type        = string
  default     = null
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "root"
}

################################################################################
# CloudFront
################################################################################
variable "cloudfront_enabled" {
  description = "Whether the distribution is enabled to accept end user requests for content."
  type        = bool
  default     = true
}

variable "http_version" {
  description = "The maximum HTTP version to support on the distribution. Allowed values are http1.1, http2, http2and3 and http3. The default is http2."
  type        = string
  default     = ""
}

variable "price_class" {
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100"
  type        = string
  default     = ""
}

variable "viewer_certificate" {
  description = " The SSL configuration for this distribution (maximum one)."
  type        = map(string)
  default     = {}
}

variable "cf_custom_header_name" {
  description = "The custom header name of CloudFront"
  type        = string
  default     = ""
}

variable "cf_custom_header_value" {
  description = "The custom header value of CloudFront"
  type        = string
  default     = ""
}

################################################################################
# Lambda
################################################################################
variable "lambda_runtime" {
  description = "Identifier of the function's runtime."
  type        = string
  default     = ""
}

variable "slack_webhook_url" {
  description = "The URL of Slack webhook"
  type        = string
  default     = ""
}

variable "channel_name" {
  description = "The name of Slack channel"
  type        = string
  default     = ""
}

variable "username" {
  description = "The name of user"
  type        = string
  default     = ""
}
