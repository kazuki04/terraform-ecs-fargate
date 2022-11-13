output "api_target_group_arn" {
  description = "The arn of api target group."
  value       = aws_lb_target_group.api.arn
}

output "frontend_target_group_arn" {
  description = "The arn of frontend target group."
  value       = aws_lb_target_group.frontend.arn
}

output "ingress_alb_id" {
  description = "The ARN of the load balancer (matches arn)."
  value       = aws_lb.ingress.id
}
output "ingress_alb_arn" {
  description = "The ARN of the load balancer (matches id)."
  value       = aws_lb.ingress.arn
}
output "ingress_alb_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics."
  value       = aws_lb.ingress.arn_suffix
}
output "ingress_alb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.ingress.dns_name
}
