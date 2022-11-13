output "aws_secretsmanager_secret_db_arn" {
  description = "ARN of the secret."
  value       = aws_secretsmanager_secret.db.arn
}

output "aws_secretsmanager_secret_db_password" {
  description = "The password of the secret for db."
  value       = random_password.master_password.result
}
