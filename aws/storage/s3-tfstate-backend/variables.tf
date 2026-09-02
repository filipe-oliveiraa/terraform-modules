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

# Variables for S3 bucket policy 

# variable "s3_bucket_policy_optional" {
#   description = "Optional parameters for the S3 bucket policy."
#   type = object({
#     # Simple args
#     region              = optional(string)
#     })
#     default = {}
# }

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