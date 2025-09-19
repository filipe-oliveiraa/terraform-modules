variable "endpoint" {
  description = "Endpoint to send data to. Varies by protocol (ARN, URL, phone number, email)."
  type        = string
}

variable "protocol" {
  description = "Protocol to use. One of: sqs, sms, lambda, firehose, application, email, email-json, http, https."
  type        = string
}

variable "topic_arn" {
  description = "ARN of the SNS topic to subscribe to."
  type        = string
}

variable "sns_topic_subscription_optional" {
  description = "Optional parameters for the SNS topic subscription."
  type = object({
    # Conditionally required if protocol == "firehose"
    subscription_role_arn = optional(string)

    # Optional 
    region                          = optional(string)
    confirmation_timeout_in_minutes = optional(number) # HTTP/HTTPS only; default 1
    delivery_policy                 = optional(string) # JSON string; HTTP/HTTPS only
    endpoint_auto_confirms          = optional(bool)   # default false
    filter_policy                   = optional(string) # JSON string
    filter_policy_scope             = optional(string) # "MessageAttributes" (default) or "MessageBody"
    raw_message_delivery            = optional(bool)   # default false
    redrive_policy                  = optional(string) # JSON string
    replay_policy                   = optional(string) # JSON string
  })
  #default = {}
}
