variable "profile" {
  description = "AWS Configuretion Profile"
  type        = string
  default     = ""
}

variable "region" {
  description = "The region name"
  type        = string
  default     = ""
}

variable "backend_buckent_name" {
  description = "The backend bucket name"
  type        = string
  default     = ""
}

variable "service_name" {
  description = "The service Name"
  type        = string
  default     = ""
}

variable "environment_identifier" {
  description = "The environment identifier"
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

variable "code_build_subnets" {
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

variable "api_container_cpu" {
  description = "The CPU of api container"
  type        = number
  default     = 256
}

variable "api_container_memory" {
  description = "The memory of api container"
  type        = number
  default     = 512
}

variable "runtime_version_for_code_build" {
  description = "The run time version for CodeBuild Project. For example, nodejs: 14"
  type        = string
  default     = ""
}
