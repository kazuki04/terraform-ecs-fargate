variable "service_name" {
  description = "Service Name"
  type        = string
}

variable "environment_identifier" {
  description = "Environment identifier"
  type        = string
  default     = ""
}

variable "lambda_runtime" {
  description = "Identifier of the function's runtime."
  type        = string
  default     = ""
}

variable "lambda_notify_slack_role_arn" {
  description = "The Arn of role for lambda to notify slack."
  type        = string
  default     = ""
}

variable "topic_alarm_arn" {
  description = "The ARN of the SNS topic"
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
