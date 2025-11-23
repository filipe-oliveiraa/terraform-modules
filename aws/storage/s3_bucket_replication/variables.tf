variable "source_bucket_id" {
  description = "ID of the source S3 bucket where replication is configured."
  type        = string
}

variable "source_bucket_arn" {
  description = "ARN of the source S3 bucket."
  type        = string
}

variable "destination_bucket_id" {
  description = "ID of the destination S3 bucket that receives replicated objects."
  type        = string
}

variable "destination_bucket_arn" {
  description = "ARN of the destination S3 bucket."
  type        = string
}

variable "destination_account_id" {
  description = "AWS account ID that owns the destination bucket. Leave null for same-account replication."
  type        = string
  default     = null
}

variable "replication_role_name" {
  description = "Name for the IAM role used by S3 replication."
  type        = string
  default     = "s3-replication-role"
}

variable "manage_destination_bucket_policy" {
  description = "When true, this module will attach the required destination bucket policy. Disable if the destination bucket is managed in another account."
  type        = bool
  default     = false
}

variable "replication_rules" {
  description = "List of replication rules to create. Each rule can target a specific prefix and replication settings."
  type = list(object({
    id                               = string
    filter_prefix                    = optional(string)
    priority                         = optional(number)
    enable_replication               = optional(bool, true)
    enable_delete_marker_replication = optional(bool, false)
    destination_storage_class        = optional(string, "STANDARD")
    destination_kms_key_arn          = optional(string)
    enable_bucket_owner_enforced     = optional(bool, true)
  }))
  default = []
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
  default     = {}
}
