data "aws_caller_identity" "current" {}

resource "aws_sns_topic" "alarm" {
  name = "${var.service_name}-${var.environment_identifier}-sns-topic-alarm"

  kms_master_key_id = var.kms_key_arn

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-sns-topic-alarm"
  }
}

resource "aws_sns_topic_subscription" "alarm" {
  topic_arn = aws_sns_topic.alarm.arn
  protocol  = "lambda"
  endpoint  = var.lambda_notify_slack_arn
}
