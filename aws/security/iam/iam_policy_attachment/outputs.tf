output "name" {
  description = "Name of the IAM policy attachment."
  value       = aws_iam_policy_attachment.iam_policy_attachment.name
}

output "id" {
  description = "The Policy's ID."
  value       = aws_iam_policy_attachment.iam_policy_attachment.id
}
