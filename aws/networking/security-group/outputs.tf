output "arn" {
  description = "ARN of the security group."
  value       = aws_security_group.security_group.arn
}

output "id" {
  description = "ID of the security group."
  value       = aws_security_group.security_group.id
}

output "owner_id" {
  description = "Owner ID of the security group."
  value       = aws_security_group.security_group.owner_id
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_security_group.security_group.tags_all
}
