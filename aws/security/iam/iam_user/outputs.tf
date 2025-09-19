output "arn" {
  description = "The ARN assigned by AWS for this IAM user."
  value       = aws_iam_user.iam_user.arn
}

output "id" {
  description = "The ID of the IAM user (same as the name)."
  value       = aws_iam_user.iam_user.id
}

output "name" {
  description = "The name of the IAM user."
  value       = aws_iam_user.iam_user.name
}

output "tags_all" {
  description = "A map of tags assigned to the IAM user, including those inherited from the provider default_tags configuration."
  value       = aws_iam_user.iam_user.tags_all
}

output "unique_id" {
  description = "A unique identifier for the IAM user."
  value       = aws_iam_user.iam_user.unique_id
}
