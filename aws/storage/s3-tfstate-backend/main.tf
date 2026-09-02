#S3 Bucket to store Terraform state
resource "aws_s3_bucket" "s3_bucket" {
  # Required
  bucket = var.bucket_name

  # Simple optional arguments
  #region              = var.s3_bucket_optional.region
  bucket_prefix = var.s3_bucket_optional.bucket_prefix
  force_destroy = var.s3_bucket_optional.force_destroy

  # Defaults to on, because this bucket holds Terraform state and object lock is
  # what stops a corrupted or truncated state file from overwriting the last
  # good one. It was previously hardcoded to true, which silently ignored a
  # caller who set it to false - and object lock cannot be turned off once the
  # bucket exists, so that is not a decision to make on someone's behalf.
  object_lock_enabled = coalesce(var.s3_bucket_optional.object_lock_enabled, true)

  tags = var.s3_bucket_optional.tags
}

resource "aws_s3_bucket_logging" "s3_bucket_logging" {
  count = var.access_log_bucket != null ? 1 : 0

  bucket        = aws_s3_bucket.s3_bucket.id
  target_bucket = var.access_log_bucket
  target_prefix = coalesce(var.access_log_prefix, "${var.bucket_name}/")
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
# Suggestion, not a requirement. A check block warns on plan and apply without
# ever blocking them.

check "state_bucket_access_logging" {
  assert {
    condition     = var.access_log_bucket != null
    error_message = "Server access logging is off on the Terraform state bucket. Set access_log_bucket to enable it. It costs S3 storage for the log objects, which is why it is not on by default - but this bucket holds every resource id and often more, so a record of who read it is worth the few cents."
  }
}
