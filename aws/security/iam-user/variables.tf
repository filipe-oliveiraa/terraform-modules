variable "name" {
  description = "The name of the IAM user."
  type        = string
}

variable "iam_user_optional" {
  description = "Optional parameters for the IAM user."
  type = object({
    path                 = optional(string)
    permissions_boundary = optional(string)
    force_destroy        = optional(bool)
    tags                 = optional(map(string))
  })
}
