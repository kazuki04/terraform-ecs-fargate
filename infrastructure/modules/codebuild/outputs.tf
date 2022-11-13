output "code_build_api_arn" {
  description = "ARN of the CodeBuild project."
  value       = aws_codebuild_project.api.arn
}

output "code_build_api_id" {
  description = "Name (if imported via name) or ARN (if created via Terraform or imported via ARN) of the CodeBuild project."
  value       = aws_codebuild_project.api.id
}

output "code_build_frontend_arn" {
  description = "ARN of the CodeBuild project."
  value       = aws_codebuild_project.frontend.arn
}

output "code_build_frontend_id" {
  description = "Name (if imported via name) or ARN (if created via Terraform or imported via ARN) of the CodeBuild project."
  value       = aws_codebuild_project.frontend.id
}

output "code_build_fluentbit_arn" {
  description = "ARN of the CodeBuild project."
  value       = aws_codebuild_project.fluentbit.arn
}

output "code_build_fluetbit_id" {
  description = "Name (if imported via name) or ARN (if created via Terraform or imported via ARN) of the CodeBuild project."
  value       = aws_codebuild_project.fluentbit.id
}
