output "api_repository_arn" {
  description = "Full ARN of the repository."
  value       = aws_ecr_repository.api.arn
}

output "api_repository_registry_id" {
  description = "The registry ID where the repository was created."
  value       = aws_ecr_repository.api.registry_id
}

output "api_repository_url" {
  description = "The URL of the repository (in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName)."
  value       = aws_ecr_repository.api.repository_url
}

output "nginx_arn" {
  description = "Full ARN of the repository."
  value       = aws_ecr_repository.nginx.arn
}

output "nginx_repository_registry_id" {
  description = "The registry ID where the repository was created."
  value       = aws_ecr_repository.nginx.registry_id
}

output "nginx_repository_url" {
  description = "The URL of the repository (in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName)."
  value       = aws_ecr_repository.nginx.repository_url
}

output "frontend_arn" {
  description = "Full ARN of the repository."
  value       = aws_ecr_repository.frontend.arn
}

output "frontend_repository_registry_id" {
  description = "The registry ID where the repository was created."
  value       = aws_ecr_repository.frontend.registry_id
}

output "frontend_repository_url" {
  description = "The URL of the repository (in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName)."
  value       = aws_ecr_repository.frontend.repository_url
}

output "fluentbit_arn" {
  description = "Full ARN of the repository."
  value       = aws_ecr_repository.fluentbit.arn
}

output "fluentbit_repository_registry_id" {
  description = "The registry ID where the repository was created."
  value       = aws_ecr_repository.fluentbit.registry_id
}

output "fluentbit_repository_url" {
  description = "The URL of the repository (in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName)."
  value       = aws_ecr_repository.fluentbit.repository_url
}
