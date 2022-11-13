################################################################################
# Alarm
################################################################################
data "archive_file" "notify_slack" {
  type             = "zip"
  source_file      = "${path.root}/../program/functions/alarm/notify_slack.py"
  output_file_mode = "0666"
  output_path      = "${path.module}/files/notify_slack.py.zip"
}

resource "aws_lambda_function" "notify_slack" {
  filename         = "${data.archive_file.notify_slack.output_path}"
  function_name    = "${var.service_name}-${var.environment_identifier}-lambda-notify_slack"
  role             = var.lambda_notify_slack_role_arn
  handler          = "notify_slack.lambda_handler"
  runtime          = var.lambda_runtime
  source_code_hash = "${data.archive_file.notify_slack.output_base64sha256}"

    environment {
      variables = {
        SLACK_WEBHOOK_URL = var.slack_webhook_url
        CHANNEL_NAME      = var.channel_name
        USERNAME          = var.username
      }
  }

  depends_on = [
    aws_cloudwatch_log_group.notify_slack
  ]

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-lambda-notify_slack"
  }
}

resource "aws_lambda_permission" "notify_slack" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notify_slack.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.topic_alarm_arn
}

resource "aws_cloudwatch_log_group" "notify_slack" {
  name              = "/aws/lambda/${var.service_name}-${var.environment_identifier}-lambda-notify_slack"
  retention_in_days = 90
}
