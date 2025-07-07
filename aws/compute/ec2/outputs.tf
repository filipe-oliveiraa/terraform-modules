output "id" {
  description = "ID of the instance"
  value       = aws_instance.ec2_instance.id
}

output "availability_zone" {
  description = "Availability zone of the instance"
  value       = aws_instance.ec2_instance.availability_zone
}

output "arn" {
  description = "ARN of the instance"
  value       = aws_instance.ec2_instance.arn
}

output "capacity_reservation_specification" {
  description = "Capacity reservation specification of the instance"
  value       = aws_instance.ec2_instance.capacity_reservation_specification
}

output "outpost_arn" {
  description = "ARN of the Outpost the instance is assigned to"
  value       = aws_instance.ec2_instance.outpost_arn
}

output "password_data" {
  description = "Base-64 encoded encrypted password data for the instance"
  value       = aws_instance.ec2_instance.password_data
}

output "primary_network_interface_id" {
  description = "ID of the instance's primary network interface"
  value       = aws_instance.ec2_instance.primary_network_interface_id
}

output "private_dns" {
  description = "Private DNS name assigned to the instance"
  value       = aws_instance.ec2_instance.private_dns
}

output "public_dns" {
  description = "Public DNS name assigned to the instance"
  value       = aws_instance.ec2_instance.public_dns
}

output "public_ip" {
  description = "Public IP address assigned to the instance"
  value       = aws_instance.ec2_instance.public_ip
}

output "tags_all" {
  description = "Map of tags assigned to the resource, including inherited tags"
  value       = aws_instance.ec2_instance.tags_all
}