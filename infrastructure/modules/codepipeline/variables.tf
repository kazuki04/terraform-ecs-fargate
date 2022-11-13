variable "service_name" {
  description = "Service Name"
  type        = string
}

variable "environment_identifier" {
  description = "Environment identifier"
  type        = string
  default     = ""
}

variable "repository_name" {
  description = "The name of repository"
  type        = string
  default     = ""
}

variable "codepipeline_role_arn" {
  description = "The role for CodePipeline"
  type        = string
  default     = ""
}

variable "artifact_bucket_id" {
  description = "The id of Bucket for artifact store"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "The arn of kms key"
  type        = string
  default     = ""
}

variable "code_build_api_arn" {
  description = "The arn of CodeBuild project for api"
  type        = string
  default     = ""
}

variable "code_build_frontend_arn" {
  description = "The arn of CodeBuild project for api"
  type        = string
  default     = ""
}

variable "code_build_fluentbit_arn" {
  description = "The arn of CodeBuild project for api"
  type        = string
  default     = ""
}

variable "ecs_cluster_arn" {
  description = "The arn of ECS cluster"
  type        = string
  default     = ""
}

variable "api_service_name" {
  description = "The name of api ECS service"
  type        = string
  default     = ""
}

variable "frontend_service_name" {
  description = "The name of frontend ECS service"
  type        = string
  default     = ""
}
