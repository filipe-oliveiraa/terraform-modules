output "zone_id" {
  description = "ID of the Route 53 hosted zone."
  value       = aws_route53_zone.this.zone_id
}

output "zone_arn" {
  description = "ARN of the Route 53 hosted zone."
  value       = aws_route53_zone.this.arn
}

output "name_servers" {
  description = "Name server set assigned to the hosted zone."
  value       = aws_route53_zone.this.name_servers
}

output "zone_name" {
  description = "Domain name associated with the hosted zone."
  value       = aws_route53_zone.this.name
}

output "record_fqdns" {
  description = "Map of record identifiers to their fully qualified domain names."
  value = {
    for key, record in aws_route53_record.this :
    key => record.fqdn
  }
}
