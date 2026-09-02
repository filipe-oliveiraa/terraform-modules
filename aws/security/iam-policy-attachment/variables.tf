variable "name" {
  description = "The name of the IAM policy attachment"
  type        = string
}

variable "policy_arn" {
  description = "The ARN of the IAM policy to attach"
  type        = string
}

variable "iam_policy_attachment_optional" {
  description = "Targets of the attachment. Each field is individually optional, but at least one of users/roles/groups must be set - see the validation below."
  type = object({
    users  = optional(list(string)) # List of IAM users to attach the policy to
    roles  = optional(list(string)) # List of IAM roles to attach the policy to
    groups = optional(list(string)) # List of IAM groups to attach the policy to
  })

  # No default on purpose. Unlike the other *_optional objects in this catalog,
  # an empty object is not a valid call here: AWS requires at least one target.
  validation {
    condition = length(concat(
      coalesce(var.iam_policy_attachment_optional.users, []),
      coalesce(var.iam_policy_attachment_optional.roles, []),
      coalesce(var.iam_policy_attachment_optional.groups, []),
    )) > 0
    error_message = "Set at least one of users, roles or groups. aws_iam_policy_attachment requires a target, and without this check the call only fails at apply time with \"one of groups,roles,users must be specified\"."
  }
}
