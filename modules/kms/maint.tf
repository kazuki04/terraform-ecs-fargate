data "aws_caller_identity" "current" {}

resource "aws_kms_key" "this" {
  description             = "KMS key for ${var.service_name} in ${var.environment_identifier}"
  policy = <<-EOT
    {
        "Version": "2012-10-17",
        "Id": "${var.service_name}-${var.environment_identifier}-policy-kms",
        "Statement": [
            {
                "Sid": "Enable IAM User Permissions",
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                },
                "Action": "kms:*",
                "Resource": "*"
            }
        ]
    }
  EOT
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.service_name}-${var.environment_identifier}-kms"
  target_key_id = aws_kms_key.this.key_id
}
