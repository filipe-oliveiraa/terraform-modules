mock_provider "aws" {}

variables {
  alarm_name          = "backup-stale"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1

  cloudwatch_metric_alarm_optional = {
    namespace   = "GitLabBackup"
    metric_name = "BackupAgeHours"
    statistic   = "Maximum"
    period      = 3600
  }
}

run "required_inputs_reach_the_resource" {
  command = plan

  assert {
    condition     = aws_cloudwatch_metric_alarm.cloudwatch_metric_alarm.alarm_name == "backup-stale"
    error_message = "alarm_name must be passed through unmodified."
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.cloudwatch_metric_alarm.comparison_operator == "GreaterThanThreshold"
    error_message = "comparison_operator must be passed through unmodified."
  }
}

run "metric_and_threshold_flow_through" {
  command = plan

  variables {
    cloudwatch_metric_alarm_optional = {
      namespace   = "GitLabBackup"
      metric_name = "BackupAgeHours"
      statistic   = "Maximum"
      period      = 3600
      threshold   = 4
      dimensions  = { BackupBucket = "my-backups" }
    }
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.cloudwatch_metric_alarm.threshold == 4
    error_message = "threshold must come from cloudwatch_metric_alarm_optional."
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.cloudwatch_metric_alarm.dimensions["BackupBucket"] == "my-backups"
    error_message = "dimensions must come from cloudwatch_metric_alarm_optional."
  }
}

run "treat_missing_data_flows_through" {
  command = plan

  variables {
    cloudwatch_metric_alarm_optional = {
      namespace          = "GitLabBackup"
      metric_name        = "BackupAgeHours"
      treat_missing_data = "breaching"
      alarm_actions      = ["arn:aws:sns:eu-west-1:123456789012:alerts"]
    }
  }

  # "breaching" is what makes a broken metric publisher alarm instead of going
  # quiet, so it is worth proving the module does not swallow it.
  assert {
    condition     = aws_cloudwatch_metric_alarm.cloudwatch_metric_alarm.treat_missing_data == "breaching"
    error_message = "treat_missing_data must flow through - it decides whether a missing metric alarms or is ignored."
  }

  assert {
    condition     = contains(aws_cloudwatch_metric_alarm.cloudwatch_metric_alarm.alarm_actions, "arn:aws:sns:eu-west-1:123456789012:alerts")
    error_message = "alarm_actions must come from cloudwatch_metric_alarm_optional."
  }
}

# Regression test. The module used to plan with no metric_name and no
# metric_query, and only fail at apply with the provider's own
# "one of evaluation_criteria,metric_name,metric_query must be specified".
run "alarm_with_no_metric_is_rejected_at_plan_time" {
  command = plan

  variables {
    cloudwatch_metric_alarm_optional = {}
  }

  expect_failures = [
    aws_cloudwatch_metric_alarm.cloudwatch_metric_alarm,
  ]
}
