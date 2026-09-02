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

output "ingress_rule_ids" {
  description = "Security group rule IDs of the inbound rules, keyed by the same keys used in ingress_rules."
  value       = { for k, r in aws_vpc_security_group_ingress_rule.this : k => r.security_group_rule_id }
}

output "egress_rule_ids" {
  description = "Security group rule IDs of the outbound rules, keyed by the same keys used in egress_rules."
  value       = { for k, r in aws_vpc_security_group_egress_rule.this : k => r.security_group_rule_id }
}
