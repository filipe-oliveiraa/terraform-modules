# Variables for S3 bucket 
variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
}

variable "s3_bucket_optional" {
  description = "Optional parameters for the S3 bucket."
  type = object({
    # Simple args
    region              = optional(string)
    bucket_prefix       = optional(string)
    force_destroy       = optional(bool)
    object_lock_enabled = optional(bool)
    tags                = optional(map(string))
  })
  default = {}
}

# Variables for S3 bucket versioning
variable "s3_bucket_versioning_optional" {
  description = "Optional parameters for S3 bucket versioning."
  type = object({
    mfa_delete            = optional(bool)
    expected_bucket_owner = optional(string)
    mfa                   = optional(string)
  })
  default = {}
}
variable "access_log_bucket" {
  description = "Bucket to deliver S3 server access logs to. Null (default) leaves access logging off - see the check block in main.tf for why that is a decision worth making rather than inheriting."
  type        = string
  default     = null
}

variable "access_log_prefix" {
  description = "Key prefix for delivered access logs. Ignored when access_log_bucket is null."
  type        = string
  default     = null
}
