output "topic_alarm_id" {
  description = "The ARN of the SNS topic"
  value       = aws_sns_topic.alarm.id
}

output "topic_alarm_arn" {
  description = "The ARN of the SNS topic, as a more obvious property (clone of id)"
  value       = aws_sns_topic.alarm.arn
}

output "sns_topic_subscription_alarm_arn" {
  description = "ARN of the subscription."
  value       = aws_sns_topic_subscription.alarm.arn
}
