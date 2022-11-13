output "task_execution_role_arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = aws_iam_role.task_execution_role.arn
}

output "task_role_arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = aws_iam_role.task_role.arn
}

output "codebuild_role_arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = aws_iam_role.codebuild.arn
}

output "codepipeline_role_arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = aws_iam_role.codepipeline.arn
}

output "lambda_notify_slack_role_arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = aws_iam_role.lambda_notify_slack.arn
}
