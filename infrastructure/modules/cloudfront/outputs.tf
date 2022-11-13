output "domain_name" {
  description = "The domain name corresponding to the distribution. For example: d604721fxaaqy9.cloudfront.net."
  value       = aws_cloudfront_distribution.this.domain_name
}
