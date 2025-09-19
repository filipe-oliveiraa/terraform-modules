output "id" {
  description = "The ARN of the SNS topic."
  value       = aws_sns_topic.sns_topic.id
}

output "arn" {
  description = "The ARN of the SNS topic (clone of id)."
  value       = aws_sns_topic.sns_topic.arn
}

output "beginning_archive_time" {
  description = "The oldest timestamp at which a FIFO topic subscriber can start a replay."
  value       = aws_sns_topic.sns_topic.beginning_archive_time
}

output "owner" {
  description = "The AWS Account ID of the SNS topic owner."
  value       = aws_sns_topic.sns_topic.owner
}

output "tags_all" {
  description = "All tags assigned to the resource, including those from provider-level default_tags."
  value       = aws_sns_topic.sns_topic.tags_all
}
