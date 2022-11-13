variable "service_name" {
  description = "Service Name"
  type        = string
}

variable "environment_identifier" {
  description = "Environment identifier"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "The Id of VPC"
  type        = string
  default     = ""
}

variable "sg_app_id" {
  description = "The Id of VPC"
  type        = string
  default     = ""
}

variable "api_container_count" {
  description = "The number of api containers"
  type        = number
  default     = 0
}

variable "app_subnets" {
  description = "The number of subnets for app"
  type        = list(string)
  default     = []
}

variable "api_container_cpu" {
  description = "(Optional) Number of cpu units used by the task. If the requires_compatibilities is FARGATE this field is required."
  type        = number
  default     = 256
}

variable "api_container_memory" {
  description = "(Optional) Amount (in MiB) of memory used by the task. If the requires_compatibilities is FARGATE this field is required."
  type        = number
  default     = 512
}

variable "task_execution_role_arn" {
  description = "ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume."
  type        = string
  default     = ""
}

variable "task_role_arn" {
  description = "(Optional) ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services."
  type        = string
  default     = ""
}

variable "api_repository_url" {
  description = "The URI of api repository"
  type        = string 
  default     = ""
}

variable "nginx_repository_url" {
  description = "The URI of nginx repository"
  type        = string 
  default     = ""
}

variable "fluentbit_repository_url" {
  description = "The URI of fluentbit repository"
  type        = string 
  default     = ""
}

variable "sg_ingress_lb_id" {
  description = "The Id of Security Group for ingress alb"
  type        = string
  default     = ""
}

variable "api_target_group_arn" {
  description = "The Arn of API target group"
  type        = string
  default     = ""
}

variable "secretsmanager_secret_db_arn" {
  description = "The Arn of secrets manager secret for database"
  type        = string
  default     = ""
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "root"
}

variable "endpoint" {
  description = "The DNS address of the RDS instance"
  type        = string
  default     = ""
}

variable "frontend_container_count" {
  description = "The number of frontend containers"
  type        = number
  default     = 0
}

variable "frontend_container_cpu" {
  description = "The DNS address of the RDS instance"
  type        = string
  default     = ""
}

variable "frontend_container_memory" {
  description = "The DNS address of the RDS instance"
  type        = string
  default     = ""
}

variable "frontend_repository_url" {
  description = "The DNS address of the RDS instance"
  type        = string
  default     = ""
}

variable "frontend_target_group_arn" {
  description = "The Arn of Frontend target group"
  type        = string
  default     = ""
}

variable "cloudfront_domain_name" {
  description = "The Host of CloudFront"
  type        = string
  default     = ""
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
variable "program_log_bucket_name" {
  description = "The name of the bucket."
  type        = string
  default     = ""
}
