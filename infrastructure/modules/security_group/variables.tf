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
