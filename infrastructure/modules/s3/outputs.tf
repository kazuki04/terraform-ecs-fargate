output "artifact_bucket_id" {
  description = "The name of the bucket."
  value       = aws_s3_bucket.artifact.id
}

output "artifact_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = aws_s3_bucket.artifact.arn
}

output "artifact_bucket_domain_name" {
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com."
  value       = aws_s3_bucket.artifact.bucket_domain_name
}

output "cloudfront_bucket_id" {
  description = "The name of the bucket."
  value       = aws_s3_bucket.cloudfront.id
}

output "cloudfron_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = aws_s3_bucket.cloudfront.arn
}

output "cloudfron_bucket_domain_name" {
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com."
  value       = aws_s3_bucket.cloudfront.bucket_domain_name
}

output "program_log_bucket_id" {
  description = "The name of the bucket."
  value       = aws_s3_bucket.program_log.id
}

output "program_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = aws_s3_bucket.program_log.arn
}

output "program_bucket_domain_name" {
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com."
  value       = aws_s3_bucket.program_log.bucket_domain_name
}
