variable "service_name" {
  description = "Service Name"
  type        = string
}

variable "environment_identifier" {
  description = "Environment identifier"
  type        = string
  default     = ""
}

variable "backend_error_log_arn" {
  description = "The Arn of backend error log group."
  type        = string
  default     = ""
}

variable "db_cluster_postgresql_log_arn" {
  description = "The Arn of db cluster postgresql log group."
  type        = string
  default     = ""
}
variable "db_cluster_postgresql_arn" {
  description = "The Arn of db cluster postgresql."
  type        = string
  default     = ""
}

variable "ecs_cluster_arn" {
  description = "The arn of ecs cluster."
  type        = string
  default     = ""
}

variable "ecs_taskdef_api_arn" {
  description = "The arn of ecs task denifiniton for api."
  type        = string
  default     = ""
}

variable "ecs_taskdef_frontend_arn" {
  description = "The arn of ecs task denifiniton for frontend."
  type        = string
  default     = ""
}

variable "sns_topic_alarm_id" {
  description = "The ARN of the SNS topic."
  type        = string
  default     = ""
}
