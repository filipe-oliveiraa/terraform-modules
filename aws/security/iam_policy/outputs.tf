output "arn" {
  description = "The ARN of the IAM role."
  value       = aws_iam_policy.policy.arn
}

output "attachment_count" {
  description = "Number of entities (users, groups, and roles) that the policy is attached to."
  value       = aws_iam_policy.policy.attachment_count
}

output "id" {
  description = "The ID of the IAM policy."
  value       = aws_iam_policy.policy.id
}

output "policy_id" {
  description = "The ID of the IAM policy."
  value       = aws_iam_policy.policy.policy_id
}

output "tags_all" {
  description = "Map of tags assigned to the IAM policy, including those inherited from the provider `default_tags` configuration block."
  value       = aws_iam_policy.policy.tags_all
}