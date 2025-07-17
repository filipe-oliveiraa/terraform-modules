variable "policy" {
  description = "The IAM policy document in JSON format"
  type        = string
}

variable "iam_policy_optional" {
  description = "Optional parameters for the IAM policy"
  type = object({
    policy      = string
    description = optional(string)
    name_prefix = optional(string)
    name        = optional(string)
    path        = optional(string)
    tags        = optional(map(string))
  })
}