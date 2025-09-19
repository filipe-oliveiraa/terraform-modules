variable "assume_role_policy" {
  description = "Assume role policy JSON string. Use EOF to define the policy."
  type        = string
}

variable "iam_role_optional" {
  description = "Optional parameters for the IAM role."
  type = object({
    description           = optional(string)
    force_detach_policies = optional(bool)
    max_session_duration  = optional(number)
    name                  = optional(string)
    name_prefix           = optional(string)
    path                  = optional(string)
    permissions_boundary  = optional(string)
    tags                  = optional(map(string))
    inline_policy = optional(object({
      name   = string
      policy = string
    }))
  })
}