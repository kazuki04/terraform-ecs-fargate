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

variable "codebuild_role_arn" {
  description = "The arn of CodeBuild role"
  type        = string
  default     = ""
}

variable "codepipeline_role_arn" {
  description = "The arn of CodePipeline role"
  type        = string
  default     = ""
}
