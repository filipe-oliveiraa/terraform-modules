variable "policy" {
  description = "Assume role policy JSON string. Use EOF to define the policy."
  type        = string
}

variable "iam_policy_optional" {
  description = "Optional parameters for the IAM policy"
  type = object({
    description = optional(string)
    name_prefix = optional(string)
    name        = optional(string)
    path        = optional(string)
    tags        = optional(map(string))
  })
}