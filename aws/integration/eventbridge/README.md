# EventBridge Module

Thin wrapper around `terraform-aws-modules/eventbridge/aws` to create a custom bus (optional), rules, and targets with validation that each rule defines either an event pattern or a schedule.

## Requirements / Assumptions
- Set `bus_name` to create a bus; leave `null` to reuse the default bus.
- Each rule must set exactly one of `event_pattern` **or** `schedule_expression`.
- Targets can include DLQ/role wiring; pass additional target-specific blocks as needed.

## Inputs
- `bus_name` (string, default `null`): Create a named bus when provided.
- `eventbridge_optional` (object):
  - `rules` (map): Rule definitions with `description`, `event_pattern` (json string) **or** `schedule_expression`, `enabled` (default true).
  - `targets` (map): Targets keyed by rule, each a list with `name`, `arn`, optional `role_arn`, `dead_letter_arn`, input/transformer settings, retry policy, and service-specific targets (ECS, Batch, Kinesis, etc.).
  - `tags` (map): Tags applied by the upstream module.

## Outputs
- `eventbridge_bus_arn`, `eventbridge_rule_ids`, `eventbridge_schedule_arns`, `eventbridge_rules`

## Example
```hcl
module "events" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/integration/Simple/eventbridge?ref=v1.0.0"

  bus_name = "apps-bus"
  eventbridge_optional = {
    rules = {
      nightly = {
        schedule_expression = "cron(0 3 * * ? *)"
        description         = "Nightly job trigger"
      }
    }
    targets = {
      nightly = [
        {
          name = "invoke-lambda"
          arn  = module.lambda.arn
          input = jsonencode({
            task = "nightly-refresh"
          })
        }
      ]
    }
  }
}
```
