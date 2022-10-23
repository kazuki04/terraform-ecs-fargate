output "codebuild_role_arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = aws_iam_role.codebuild.arn
}

output "codepipeline_role_arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = aws_iam_role.codepipeline.arn
}
