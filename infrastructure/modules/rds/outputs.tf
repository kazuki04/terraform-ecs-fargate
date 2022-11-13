output "aws_rds_cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster"
  value       = aws_rds_cluster.this.arn
}

output "endpoint" {
  description = "The DNS address of the RDS instance"
  value       = aws_rds_cluster.this.endpoint
}

output "reader_endpoint" {
  description = "A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas"
  value       = aws_rds_cluster.this.reader_endpoint
}

output "db_cluster_postgresql_log_arn" {
  description = "The Arn of backend error log group."
  value       = aws_cloudwatch_log_group.db_cluster_postgresql.arn
}
