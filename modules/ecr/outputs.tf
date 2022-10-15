output "ecr_api_arn" {
  description = "Full ARN of the repository."
  value       = aws_ecr_repository.api.arn
}
output "ecr_api_registry_id" {
  description = "The registry ID where the repository was created."
  value       = aws_ecr_repository.api.registry_id
}
output "ecr_api_repository_url" {
  description = "The URL of the repository (in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName)."
  value       = aws_ecr_repository.api.repository_url
}
