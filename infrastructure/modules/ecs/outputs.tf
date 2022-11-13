output "cluster_arn" {
  description = "The ARN of ECS cluster."
  value       = aws_ecs_cluster.this.arn
}

output "api_service_name" {
  description = "The name of api ECS service."
  value       = aws_ecs_service.api.name
}

output "frontend_service_name" {
  description = "The name of frontend ECS service."
  value       = aws_ecs_service.frontend.name
}

output "api_taskdef_arn" {
  description = "Full ARN of the Task Definition (including both family and revision)."
  value       = aws_ecs_task_definition.api.arn
}

output "frontend_taskdef_arn" {
  description = "Full ARN of the Task Definition (including both family and revision)."
  value       = aws_ecs_task_definition.frontend.arn
}
output "ecs_backend_error" {
  description = "The name of frontend ECS service."
  value       = aws_ecs_service.frontend.name
}

output "backend_error_log_arn" {
  description = "The Arn of backend error log group."
  value       = aws_cloudwatch_log_group.ecs_backend_error.arn
}
