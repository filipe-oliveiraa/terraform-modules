output "eventbridge_bus_arn" {
  description = "ARN of the created or referenced EventBridge bus."
  value       = try(module.eventbridge.eventbridge_bus_arn, null)
}

output "eventbridge_rule_ids" {
  description = "IDs of the EventBridge rules created."
  value       = try(module.eventbridge.eventbridge_rule_ids, [])
}

output "eventbridge_schedule_arns" {
  description = "The EventBridge schedule ARNs created (if any)."
  value       = try(module.eventbridge.eventbridge_schedule_arns, [])
}

output "eventbridge_rules" {
  description = "The EventBridge rules created and their attributes."
  value       = try(module.eventbridge.eventbridge_rules, {})
}
