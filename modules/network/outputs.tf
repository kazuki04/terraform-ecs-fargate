################################################################################
# VPC
################################################################################

output "vpc_arn" {
  description = "Amazon Resource Name (ARN) of VPC"
  value       = aws_vpc.this.arn
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

################################################################################
# Subnet
################################################################################

output "ingress_subnet_ids" {
  description = "The ID of the subnet"
  value       = aws_subnet.ingress[*].id
}

output "ingress_subnet_arns" {
  description = "The ARN of the subnet."
  value       = aws_subnet.ingress[*].arn
}

output "app_subnet_ids" {
  description = "The ID of the subnet"
  value       = aws_subnet.app[*].id
}

output "app_subnet_arns" {
  description = "The ARN of the subnet."
  value       = aws_subnet.app[*].arn
}

output "db_subnet_ids" {
  description = "The ID of the subnet"
  value       = aws_subnet.db[*].id
}

output "db_subnet_arns" {
  description = "The ARN of the subnet."
  value       = aws_subnet.db[*].arn
}

output "egress_subnet_ids" {
  description = "The ID of the subnet"
  value       = aws_subnet.egress[*].id
}

output "egress_subnet_arns" {
  description = "The ARN of the subnet."
  value       = aws_subnet.egress[*].arn
}

output "code_build_subnet_ids" {
  description = "The ID of the subnet"
  value       = aws_subnet.code_build[*].id
}

output "code_build_subnet_arns" {
  description = "The ARN of the subnet."
  value       = aws_subnet.code_build[*].arn
}

output "management_subnet_ids" {
  description = "The ID of the subnet"
  value       = aws_subnet.management[*].id
}

output "management_subnet_arns" {
  description = "The ARN of the subnet."
  value       = aws_subnet.management[*].arn
}
