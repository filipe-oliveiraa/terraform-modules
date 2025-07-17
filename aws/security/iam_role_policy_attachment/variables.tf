variable "role" {
  description = "The name of the IAM role to attach the policy to."
  type        = string
}

variable "policy_arn" {
  description = "The ARN of the IAM policy to attach to the role."
  type        = string
}