# S3 Bucket Outputs
output "bucket_id" {
  description = "Name of the bucket."
  value       = aws_s3_bucket.s3_bucket.id
}

output "bucket_arn" {
  description = "ARN of the bucket."
  value       = aws_s3_bucket.s3_bucket.arn
}

output "bucket_domain_name" {
  description = "Bucket domain name."
  value       = aws_s3_bucket.s3_bucket.bucket_domain_name
}

output "bucket_region" {
  description = "AWS region this bucket resides in."
  value       = aws_s3_bucket.s3_bucket.bucket_region
}

output "bucket_regional_domain_name" {
  description = "Region-specific bucket domain name."
  value       = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "Route 53 Hosted Zone ID for this bucket's region."
  value       = aws_s3_bucket.s3_bucket.hosted_zone_id
}

output "bucket_tags_all" {
  description = "All tags, including provider-level default_tags."
  value       = aws_s3_bucket.s3_bucket.tags_all
}

# S3 Bucket Policy - No outputs


#s3 Bucket Versioning Outputs
output "bucket_versioning_id" {
  description = "ID of the bucket."
  value       = aws_s3_bucket_versioning.s3_bucket_versioning.bucket
}