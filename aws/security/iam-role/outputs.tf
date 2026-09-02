output "arn" {
  description = "The ARN of the IAM role."
  value       = aws_iam_role.iam_role.arn

}

output "create_date" {
  description = "The date and time when the IAM role was created."
  value       = aws_iam_role.iam_role.create_date

}

output "id" {
  description = "The ID of the IAM role."
  value       = aws_iam_role.iam_role.id

}

output "name" {
  description = "The name of the IAM role."
  value       = aws_iam_role.iam_role.name

}

output "tags_all" {
  description = "A map of tags assigned to the IAM role, including those inherited from the provider default_tags configuration."
  value       = aws_iam_role.iam_role.tags_all

}

output "unique_id" {
  description = "A unique identifier for the IAM role."
  value       = aws_iam_role.iam_role.unique_id

}