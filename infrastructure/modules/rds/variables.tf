variable "service_name" {
  description = "Service Name"
  type        = string
}

variable "environment_identifier" {
  description = "Environment identifier"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "The arn of kms key"
  type        = string
  default     = ""
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "sg_rds_id" {
  description = "ID of the security group."
  type        = string
  default     = ""
}

variable "db_subnet_ids" {
  description = "ID of the subnet groups."
  type        = list(string)
  default     = []
}

variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window."
  type        = bool
  default     = true
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

variable "db_parameter_group_family" {
  description = "The family of the DB parameter group"
  type        = string
  default     = ""
}

variable "db_parameter_group_description" {
  description = "InstanceParameter for Aurora PostgreSQL"
  type        = string
  default     = ""
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter.Time in UTC. Default: A 30-minute window selected at random from an 8-hour block of time per regionE.g., 04:00-09:00"
  type        = string
  default     = ""
}

variable "backup_retention_period" {
  description = "The days to retain backups for. Default `7`"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to `true`. The default is `false`"
  type        = bool
  default     = null
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

variable "aurora_cluster_port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = 5432
}

variable "preferred_maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'."
  type        = string
  default     = ""
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
