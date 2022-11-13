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

variable "lambda_notify_slack_arn" {
  description = "The arn of lambda for notify slack"
  type        = string
  default     = ""
}
