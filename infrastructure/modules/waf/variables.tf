variable "service_name" {
  description = "Service Name"
  type        = string
}

variable "environment_identifier" {
  description = "Environment identifier"
  type        = string
  default     = ""
}

variable "cf_custom_header_name" {
  description = "The custom header name of CloudFront"
  type        = string
  default     = ""
}

variable "cf_custom_header_value" {
  description = "The custom header value of CloudFront"
  type        = string
  default     = ""
}

variable "ingress_alb_arn" {
  description = "The arn of ingress ALB"
  type        = string
  default     = ""
}
