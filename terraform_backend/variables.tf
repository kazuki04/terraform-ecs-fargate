variable "profile" {
  description = "AWS Configuretion Profile"
  type        = string
  default     = ""
}

variable "service_name" {
  description = "The service Name"
  type        = string
  default     = "fargate-sample"
}

variable "environment_identifier" {
  description = "The environment identifier"
  type        = string
  default     = ""
}

variable "region" {
  description = "The region name"
  type        = string
  default     = ""
}
