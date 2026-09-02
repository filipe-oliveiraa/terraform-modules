variable "name" {
  description = "The name of the IAM policy attachment"
  type        = string
}

variable "policy_arn" {
  description = "The ARN of the IAM policy to attach"
  type        = string
}

variable "iam_policy_attachment_optional" {
  description = "Optional parameters for the IAM policy attachment"
  type = object({
    users  = optional(list(string)) # List of IAM users to attach the policy to
    roles  = optional(list(string)) # List of IAM roles to attach the policy to
    groups = optional(list(string)) # List of IAM groups to attach the policy to
  })
}
