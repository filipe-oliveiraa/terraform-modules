output "cloudwatch_metric_alarm_id" {
  description = "The ID of the CloudWatch Metric Alarm."
  value       = aws_cloudwatch_metric_alarm.cloudwatch_metric_alarm.id
}

output "cloudwatch_metric_alarm_arn" {
  description = "The ARN of the CloudWatch Metric Alarm."
  value       = aws_cloudwatch_metric_alarm.cloudwatch_metric_alarm.arn
}

output "tags_all" {
  description = "The name of the CloudWatch Metric Alarm."
  value       = aws_cloudwatch_metric_alarm.cloudwatch_metric_alarm.tags_all
}
