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

variable "subnets" {
  description = "The name of Application Load Balancer"
  type        = list(string)
  default     = []
}

variable "sg_ingress_lb_id" {
  description = "ID of the security group."
  type        = string
  default     = ""
}
