resource "aws_cloudwatch_metric_alarm" "cloudwatch_metric_alarm" {
  alarm_name          = var.alarm_name
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods


  # Optional
  metric_name                           = var.cloudwatch_metric_alarm_optional.metric_name
  namespace                             = var.cloudwatch_metric_alarm_optional.namespace
  period                                = var.cloudwatch_metric_alarm_optional.period
  statistic                             = var.cloudwatch_metric_alarm_optional.statistic
  threshold                             = var.cloudwatch_metric_alarm_optional.threshold
  threshold_metric_id                   = var.cloudwatch_metric_alarm_optional.threshold_metric_id
  actions_enabled                       = var.cloudwatch_metric_alarm_optional.actions_enabled
  alarm_actions                         = var.cloudwatch_metric_alarm_optional.alarm_actions
  alarm_description                     = var.cloudwatch_metric_alarm_optional.alarm_description
  datapoints_to_alarm                   = var.cloudwatch_metric_alarm_optional.datapoints_to_alarm
  dimensions                            = var.cloudwatch_metric_alarm_optional.dimensions
  insufficient_data_actions             = []
  ok_actions                            = var.cloudwatch_metric_alarm_optional.ok_actions
  unit                                  = var.cloudwatch_metric_alarm_optional.unit
  extended_statistic                    = var.cloudwatch_metric_alarm_optional.extended_statistic
  treat_missing_data                    = var.cloudwatch_metric_alarm_optional.treat_missing_data
  evaluate_low_sample_count_percentiles = var.cloudwatch_metric_alarm_optional.evaluate_low_sample_count_percentiles
  #metric_query = var.cloudwatch_metric_alarm_optional.metric_query
  tags = var.cloudwatch_metric_alarm_optional.tags

  lifecycle {
    # An alarm needs something to alarm on. Without this the module plans with
    # no metric at all and only fails at apply, with the provider's own
    # "one of evaluation_criteria,metric_name,metric_query must be specified".
    # Only metric_name is checked: metric_query is not wired up in this module.
    # The input and the argument are both commented out above, so metric-math
    # and multi-metric alarms are out of scope here.
    precondition {
      condition     = var.cloudwatch_metric_alarm_optional.metric_name != null
      error_message = "Set cloudwatch_metric_alarm_optional.metric_name, together with namespace. This module does not support metric_query alarms."
    }
  }
}
