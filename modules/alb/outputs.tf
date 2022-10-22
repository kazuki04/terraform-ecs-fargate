output "api_target_group_arn" {
  description = "The arn of api target group."
  value       = aws_lb_target_group.api.id
}
