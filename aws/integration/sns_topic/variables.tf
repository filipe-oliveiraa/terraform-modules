variable "sns_topic_optional" {
  description = "Optional parameters for the SNS topic."
  type = object({
    # Region override
    region = optional(string)

    # Naming (mutually exclusive)
    name        = optional(string)
    name_prefix = optional(string)

    # Basic config
    display_name    = optional(string)
    policy          = optional(string) # JSON string
    delivery_policy = optional(string) # JSON string

    # Application feedback
    application_success_feedback_role_arn    = optional(string)
    application_success_feedback_sample_rate = optional(number) # 0..100
    application_failure_feedback_role_arn    = optional(string)

    # HTTP feedback
    http_success_feedback_role_arn    = optional(string)
    http_success_feedback_sample_rate = optional(number) # 0..100
    http_failure_feedback_role_arn    = optional(string)

    # KMS & signing
    kms_master_key_id = optional(string)
    signature_version = optional(number) # 1 or 2

    # Tracing / FIFO scope
    tracing_config        = optional(string) # "PassThrough" | "Active"
    fifo_throughput_scope = optional(string) # "Topic" | "MessageGroup"

    # FIFO & archive
    fifo_topic                  = optional(bool)
    archive_policy              = optional(string) # JSON string
    content_based_deduplication = optional(bool)

    # Lambda feedback
    lambda_success_feedback_role_arn    = optional(string)
    lambda_success_feedback_sample_rate = optional(number) # 0..100
    lambda_failure_feedback_role_arn    = optional(string)

    # SQS feedback
    sqs_success_feedback_role_arn    = optional(string)
    sqs_success_feedback_sample_rate = optional(number) # 0..100
    sqs_failure_feedback_role_arn    = optional(string)

    # Firehose feedback
    firehose_success_feedback_role_arn    = optional(string)
    firehose_success_feedback_sample_rate = optional(number) # 0..100
    firehose_failure_feedback_role_arn    = optional(string)

    # Tags
    tags = optional(map(string))
  })

}
