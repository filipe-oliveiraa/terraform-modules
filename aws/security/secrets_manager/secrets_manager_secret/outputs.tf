output "arn" {
  description = "The ARN of the Secrets Manager secret."
  value       = aws_secretsmanager_secret.secretsmanager_secret.arn
}

output "name" {
  description = "The name of the Secrets Manager secret."
  value       = aws_secretsmanager_secret.secretsmanager_secret.name
}

output "replica" {
  description = "The replica regions of the Secrets Manager secret."
  value       = aws_secretsmanager_secret.secretsmanager_secret.replica
}

output "tags_all" {
  description = "A map of tags assigned to the Secrets Manager secret, including those inherited from the provider default_tags configuration."
  value       = aws_secretsmanager_secret.secretsmanager_secret.tags_all
}
