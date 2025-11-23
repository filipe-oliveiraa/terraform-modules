# -------------------------
# S3 bucket related outputs
# -------------------------
output "bucket_id" {
  description = "S3 bucket ID."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "S3 bucket ARN."
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "Public domain name of the S3 bucket."
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_website_endpoint" {
  description = "Website endpoint for directly accessing the S3 static site (useful for health checks or debugging)."
  value       = length(aws_s3_bucket_website_configuration.this) > 0 ? aws_s3_bucket_website_configuration.this[0].website_endpoint : null
}

output "bucket_regional_domain_name" {
  description = "Regional domain name that CloudFront uses as the origin."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "Route 53 hosted zone ID for the S3 bucket."
  value       = aws_s3_bucket.this.hosted_zone_id
}

# ------------------------------
# CloudFront distribution outputs
# ------------------------------
output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.this.id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution."
  value       = aws_cloudfront_distribution.this.arn
}

output "cloudfront_domain_name" {
  description = "Domain name assigned to the CloudFront distribution."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "Route 53 hosted zone ID for the CloudFront distribution."
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

# ------------------------------
# Origin access control metadata
# ------------------------------
output "origin_access_control_id" {
  description = "ID of the CloudFront origin access control."
  value       = aws_cloudfront_origin_access_control.this.id
}
