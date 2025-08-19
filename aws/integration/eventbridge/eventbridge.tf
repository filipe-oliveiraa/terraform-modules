# Refer to: https://registry.terraform.io/modules/terraform-aws-modules/eventbridge/aws/latest#eventbridge-complete

module "eventbridge" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "4.1.0" #Adjust the version as needed in documentation

  create_bus = var.bus_name != null
  # If caller passes null, use the default bus name explicitly
  bus_name = coalesce(var.bus_name, "default")

  rules   = lookup(var.eventbridge_optional, "rules", {})
  targets = lookup(var.eventbridge_optional, "targets", {})
  tags    = lookup(var.eventbridge_optional, "tags", {})
}
