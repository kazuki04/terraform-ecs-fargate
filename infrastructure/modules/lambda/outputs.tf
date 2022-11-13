output "lambda_notify_slack_arn" {
  description = "Amazon Resource Name (ARN) specifying the lambda resource."
  value       = aws_lambda_function.notify_slack.arn
}
