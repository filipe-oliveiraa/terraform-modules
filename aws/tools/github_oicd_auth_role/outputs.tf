output "role_arn" {
  description = "ARN of the IAM role trusted by GitHub OIDC."
  value       = aws_iam_role.github_oidc_role.arn
}

output "role_name" {
  description = "Name of the IAM role trusted by GitHub OIDC."
  value       = aws_iam_role.github_oidc_role.name
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider used by this role."
  value       = local.oidc_provider_arn
}
