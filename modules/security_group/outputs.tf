output "sg_ingress_lb_id" {
  description = "ID of the security group."
  value       = aws_security_group.ingress_lb.id
}


output "sg_code_build_id" {
  description = "ID of the security group."
  value       = aws_security_group.code_build.id
}
