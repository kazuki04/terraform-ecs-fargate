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

variable "codebuild_subnet_ids" {
  description = "The subnet for CodeBuild"
  type        = list(string)
  default     = []
}

variable "sg_codebuild_id" {
  description = "ID of the security group."
  type        = string
  default     = ""
}

variable "service_role_arn" {
  description = "Amazon Resource Name (ARN) for CodeBuild."
  type        = string
  default     = ""
}

variable "runtime_version_for_codebuild" {
  description = "The run time version for CodeBuild Project. For example, nodejs: 14"
  type        = string
  default     = ""
}

variable "api_repository_url" {
  description = "The URL of api ECR repository"
  type        = string
  default     = ""
}
