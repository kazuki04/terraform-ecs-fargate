variable "service_name" {
  description = "Service Name"
  type        = string
}

variable "environment_identifier" {
  description = "Environment identifier"
  type        = string
  default     = ""
}

variable "topic_alarm_arn" {
  description = "The ARN of the SNS topic"
  type        = string
  default     = ""
}
