variable "region" {
  description = "Region"
  type        = string
}

variable "service_name" {
  description = "Service Name"
  type        = string
}

variable "environment_identifier" {
  description = "Environment identifier"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC."
  type        = string
  default     = ""
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "ingress_subnets" {
  description = "A list of public subnets for ingress inside the VPC"
  type        = list(string)
  default     = []
}

variable "app_subnets" {
  description = "A list of private subnets for appliction inside the VPC"
  type        = list(string)
  default     = []
}

variable "db_subnets" {
  description = "A list of private subnets for database inside the VPC"
  type        = list(string)
  default     = []
}

variable "egress_subnets" {
  description = "A list of private subnets for egress inside the VPC"
  type        = list(string)
  default     = []
}

variable "codebuild_subnets" {
  description = "A list of private subnets for codebuild inside the VPC"
  type        = list(string)
  default     = []
}

variable "management_subnets" {
  description = "A list of private subnets for management inside the VPC"
  type        = list(string)
  default     = []
}

variable "vpc_endpoints" {
  description = "A list of VPC endpoints services"
  type        = list(string)
  default     = []
}
