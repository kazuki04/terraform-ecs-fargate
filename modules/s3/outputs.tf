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
