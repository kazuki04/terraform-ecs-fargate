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

output "ingress_subnet_id" {
  description = "The ID of the subnet"
  value       = aws_route_table.ingress.id
}

output "ingress_subnet_arn" {
  description = "The ARN of the subnet."
  value       = aws_route_table.ingress.arn
}

output "app_subnet_id" {
  description = "The ID of the subnet"
  value       = aws_route_table.app.id
}

output "app_subnet_arn" {
  description = "The ARN of the subnet."
  value       = aws_route_table.app.arn
}

output "db_subnet_id" {
  description = "The ID of the subnet"
  value       = aws_route_table.db.id
}

output "db_subnet_arn" {
  description = "The ARN of the subnet."
  value       = aws_route_table.db.arn
}

output "egress_subnet_id" {
  description = "The ID of the subnet"
  value       = aws_route_table.egress.id
}

output "egress_subnet_arn" {
  description = "The ARN of the subnet."
  value       = aws_route_table.egress.arn
}

output "code_build_subnet_id" {
  description = "The ID of the subnet"
  value       = aws_route_table.code_build.id
}

output "code_build_subnet_arn" {
  description = "The ARN of the subnet."
  value       = aws_route_table.code_build.arn
}

output "management_subnet_id" {
  description = "The ID of the subnet"
  value       = aws_route_table.management.id
}

output "management_subnet_arn" {
  description = "The ARN of the subnet."
  value       = aws_route_table.management.arn
}
