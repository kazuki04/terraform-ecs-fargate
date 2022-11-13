locals {
  master_password = random_password.master_password.result
}

resource "random_password" "master_password" {
  length  = 8
  special = false
}

resource "aws_secretsmanager_secret" "db" {
  name       = "${var.service_name}-${var.environment_identifier}-secret-db-pw"
  kms_key_id = var.kms_key_arn
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.arn
  secret_string = local.master_password
}

