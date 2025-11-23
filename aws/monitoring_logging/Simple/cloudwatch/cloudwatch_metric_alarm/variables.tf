variable "alarm_name" {
  description = "The descriptive name for the alarm. This name must be unique within the account/region."
  type        = string
}

variable "comparison_operator" {
  description = "The arithmetic operation to use when comparing the specified statistic and threshold (e.g., GreaterThanOrEqualToThreshold)."
  type        = string
}

variable "evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold."
  type        = number
}

variable "cloudwatch_metric_alarm_optional" {
  description = "Optional parameters for the CloudWatch metric alarm."
  type = object({
    metric_name                           = optional(string)
    namespace                             = optional(string)
    period                                = optional(number)
    statistic                             = optional(string)
    extended_statistic                    = optional(string)
    threshold                             = optional(number)
    threshold_metric_id                   = optional(string)
    actions_enabled                       = optional(bool)
    alarm_actions                         = optional(list(string))
    alarm_description                     = optional(string)
    datapoints_to_alarm                   = optional(number)
    dimensions                            = optional(map(string))
    ok_actions                            = optional(list(string))
    unit                                  = optional(string)
    treat_missing_data                    = optional(string)
    evaluate_low_sample_count_percentiles = optional(string)
    # metric_query                          = optional(list(object({
    #   id          = string
    #   expression  = optional(string)
    #   label       = optional(string)
    #   return_data = optional(bool)
    #   period      = optional(number)
    #   account_id  = optional(string)
    #   metric = optional(object({
    #     metric_name = string
    #     namespace   = string
    #     period      = number
    #     stat        = string
    #     unit        = optional(string)
    #     dimensions  = optional(map(string))
    #   }))
    # })))
    tags = optional(map(string))
  })
}
