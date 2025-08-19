variable "bus_name" {
  description = "Name of the EventBridge bus to create. If null, do not create a new bus (use default bus)."
  type        = string
  default     = null
  validation {
    condition     = var.bus_name == null || can(regex("^[\\w+=,.@-]+$", var.bus_name))
    error_message = "bus_name may be null or must match [\\w+=,.@-] (no spaces or slashes)."
  }
}

variable "eventbridge_optional" {
  description = "Optional parameters for EventBridge (rules, targets, tags)."
  type = object({
    rules = optional(map(object({
      description         = optional(string)
      event_pattern       = optional(string) # jsonencode(...) string
      schedule_expression = optional(string) # cron(...) or rate(...)
      enabled             = optional(bool, true)
    })), {})

    targets = optional(map(list(object({
      name            = string
      arn             = string
      dead_letter_arn = optional(string)
      role_arn        = optional(string)

      input           = optional(string)
      input_path      = optional(string)
      input_paths_map = optional(map(string))

      input_transformer = optional(object({
        input_template = string
        input_paths    = optional(map(string))
      }))

      retry_policy = optional(object({
        maximum_event_age_in_seconds = optional(number)
        maximum_retry_attempts       = optional(number)
      }))

      ecs_target     = optional(any)
      batch_target   = optional(any)
      kinesis_target = optional(any)
    }))), {})

    tags = optional(map(string), {})
  })
  default = {}

  validation {
    condition = alltrue([
      for r in coalesce(values(lookup(var.eventbridge_optional, "rules", {})), []) :
      ((try(r.event_pattern, null) != null) != (try(r.schedule_expression, null) != null))
    ])
    error_message = "Each rule must specify exactly one of: event_pattern OR schedule_expression."
  }
}
