output "replication_role_arn" {
  description = "ARN of the IAM role used for S3 replication."
  value       = aws_iam_role.replication.arn
}

output "replication_role_name" {
  description = "Name of the IAM role used for S3 replication."
  value       = aws_iam_role.replication.name
}

output "destination_bucket_policy_json" {
  description = "Bucket policy JSON granting replication permissions to the destination bucket."
  value       = data.aws_iam_policy_document.destination_bucket_policy.json
}

output "replication_configuration_id" {
  description = "ID of the replication configuration rule."
  value       = aws_s3_bucket_replication_configuration.this.id
}
