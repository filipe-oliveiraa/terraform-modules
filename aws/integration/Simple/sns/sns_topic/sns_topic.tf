resource "aws_sns_topic" "sns_topic" {
  # Region override
  #region                              = var.sns_topic_optional.region

  # Naming
  name        = var.sns_topic_optional.name
  name_prefix = var.sns_topic_optional.name_prefix

  # Basic config
  display_name    = var.sns_topic_optional.display_name
  policy          = var.sns_topic_optional.policy
  delivery_policy = var.sns_topic_optional.delivery_policy

  # Application feedback
  application_success_feedback_role_arn    = var.sns_topic_optional.application_success_feedback_role_arn
  application_success_feedback_sample_rate = var.sns_topic_optional.application_success_feedback_sample_rate
  application_failure_feedback_role_arn    = var.sns_topic_optional.application_failure_feedback_role_arn

  # HTTP feedback
  http_success_feedback_role_arn    = var.sns_topic_optional.http_success_feedback_role_arn
  http_success_feedback_sample_rate = var.sns_topic_optional.http_success_feedback_sample_rate
  http_failure_feedback_role_arn    = var.sns_topic_optional.http_failure_feedback_role_arn

  # KMS & signing
  kms_master_key_id = var.sns_topic_optional.kms_master_key_id
  signature_version = var.sns_topic_optional.signature_version

  # Tracing / FIFO scope
  tracing_config        = var.sns_topic_optional.tracing_config
  fifo_throughput_scope = var.sns_topic_optional.fifo_throughput_scope

  # FIFO & archive
  fifo_topic                  = var.sns_topic_optional.fifo_topic
  archive_policy              = var.sns_topic_optional.archive_policy
  content_based_deduplication = var.sns_topic_optional.content_based_deduplication

  # Lambda feedback
  lambda_success_feedback_role_arn    = var.sns_topic_optional.lambda_success_feedback_role_arn
  lambda_success_feedback_sample_rate = var.sns_topic_optional.lambda_success_feedback_sample_rate
  lambda_failure_feedback_role_arn    = var.sns_topic_optional.lambda_failure_feedback_role_arn

  # SQS feedback
  sqs_success_feedback_role_arn    = var.sns_topic_optional.sqs_success_feedback_role_arn
  sqs_success_feedback_sample_rate = var.sns_topic_optional.sqs_success_feedback_sample_rate
  sqs_failure_feedback_role_arn    = var.sns_topic_optional.sqs_failure_feedback_role_arn

  # Firehose feedback
  firehose_success_feedback_role_arn    = var.sns_topic_optional.firehose_success_feedback_role_arn
  firehose_success_feedback_sample_rate = var.sns_topic_optional.firehose_success_feedback_sample_rate
  firehose_failure_feedback_role_arn    = var.sns_topic_optional.firehose_failure_feedback_role_arn

  # Tags
  tags = var.sns_topic_optional.tags
}
