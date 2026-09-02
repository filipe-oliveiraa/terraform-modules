# CloudWatch Metric Alarm Module

Creates a single CloudWatch metric alarm with flexible dimensions, actions, and statistic settings. Optional fields are exposed via one object to keep usage compact.

## Requirements / Assumptions
- Required: `alarm_name`, `comparison_operator`, and `evaluation_periods`.
- Supply metric context through `metric_name`, `namespace`, `statistic`/`extended_statistic`, `period`, and `threshold` or a `metric_query` (commented in variables if you choose to extend).

## Inputs
- `alarm_name` (string, required)
- `comparison_operator` (string, required)
- `evaluation_periods` (number, required)
- `cloudwatch_metric_alarm_optional` (object): Metric details (`metric_name`, `namespace`, `statistic`/`extended_statistic`, `period`, `threshold`), dimensions, datapoints to alarm, treat missing data policy, actions (`alarm_actions`, `ok_actions`), tags, and more.

## Outputs
- This module surfaces the upstream resource attributes; see Terraform state for resolved values.

## Example
```hcl
module "cpu_alarm" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/observability/cloudwatch-metric-alarm?ref=cloudwatch-metric-alarm/v1.0.0"

  alarm_name          = "high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2

  cloudwatch_metric_alarm_optional = {
    metric_name  = "CPUUtilization"
    namespace    = "AWS/EC2"
    statistic    = "Average"
    period       = 60
    threshold    = 80
    dimensions   = { InstanceId = module.ec2.id }
    alarm_actions = [aws_sns_topic.alerts.arn]
    ok_actions    = [aws_sns_topic.alerts.arn]
    treat_missing_data = "missing"
    tags = { Service = "web" }
  }
}
```

## Behaviour worth knowing

**A metric is required at plan time.** `metric_name` (with `namespace`) must be
set; a precondition catches a call without one instead of letting it fail at
apply with `"one of evaluation_criteria,metric_name,metric_query must be
specified"`.

**Metric-math and multi-metric alarms are out of scope.** `metric_query` is
commented out in both the variable and the resource, so this module handles
single-metric alarms only.

**Consider `treat_missing_data`.** The AWS default (`missing`) means an alarm
whose metric stops arriving goes quiet rather than firing - which is the exact
failure mode most alarms exist to catch. `"breaching"` is usually what you want
for a liveness-style alarm.
