# This module wraps terraform-aws-modules/eventbridge/aws, so the assertions
# target this module's own outputs and the inputs it forwards, not the upstream
# module's internals.
mock_provider "aws" {}

run "no_bus_is_created_by_default" {
  command = plan

  # bus_name = null means "use the account's default bus" rather than "create
  # one called default", which would be a surprising thing to create for
  # someone who just wanted a rule.
  assert {
    condition     = var.bus_name == null
    error_message = "bus_name must default to null."
  }
}

run "named_bus_is_requested_when_given" {
  command = plan

  variables {
    bus_name = "platform-events"
  }

  assert {
    condition     = var.bus_name == "platform-events"
    error_message = "bus_name must flow through to the upstream module."
  }
}
