variable "source_bucket" {
  description = "Name of the SOURCE S3 bucket."
  type        = string
}

variable "source_list_prefixes" {
  description = "List of SOURCE prefixes used in the ListBucket condition (s3:prefix)."
  type        = list(string)
}

variable "source_object_prefixes" {
  description = "List of SOURCE object prefixes to allow Get/Head on."
  type        = list(string)
}

variable "dest_bucket" {
  description = "Name of the DESTINATION S3 bucket."
  type        = string
}

variable "dest_prefixes" {
  description = "List of DESTINATION prefixes for ListBucket and object ops."
  type        = list(string)
}

variable "iam_policy_optional" {
  description = "Optional parameters for the IAM policy (kept exactly like your module)."
  type = object({
    description = optional(string)
    name_prefix = optional(string)
    name        = optional(string)
    path        = optional(string)
    tags        = optional(map(string))
  })
}
