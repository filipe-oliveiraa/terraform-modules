#S3 Bucket to store Terraform state
resource "aws_s3_bucket" "s3_bucket" {
  # Required
  bucket = var.bucket_name

  # Simple optional arguments
  #region              = var.s3_bucket_optional.region
  bucket_prefix       = var.s3_bucket_optional.bucket_prefix
  force_destroy       = var.s3_bucket_optional.force_destroy
  object_lock_enabled = true
  tags                = var.s3_bucket_optional.tags
}

# S3 Bucket Versioning to enable versioning for the state files
resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status     = "Enabled" # default recommended by AWS
    mfa_delete = var.s3_bucket_versioning_optional.mfa_delete
  }

  expected_bucket_owner = var.s3_bucket_versioning_optional.expected_bucket_owner
  mfa                   = var.s3_bucket_versioning_optional.mfa
  #region                = var.s3_bucket_versioning_optional.region
}

# S3 Server-Side Encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}