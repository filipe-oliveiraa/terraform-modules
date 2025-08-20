module "eventbridge" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "4.1.0"

  create_bus = var.bus_name != null
  bus_name   = coalesce(var.bus_name, "default")

  # Stop creating the generic IAM role named "default"
  create_role = false # Set to false to avoid creating a default role, use aws_lambda_permission module 

  rules   = lookup(var.eventbridge_optional, "rules", {})
  targets = lookup(var.eventbridge_optional, "targets", {})
  tags    = lookup(var.eventbridge_optional, "tags", {})
}
