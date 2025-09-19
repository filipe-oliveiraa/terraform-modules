resource "aws_sns_topic_subscription" "sns_topic_subscription" {
  # Required
  endpoint  = var.endpoint
  protocol  = var.protocol
  topic_arn = var.topic_arn

  # Conditionally required (when protocol = "firehose")
  subscription_role_arn = var.sns_topic_subscription_optional.subscription_role_arn

  # Optional 
  #region                           = var.sns_topic_subscription_optional.region
  confirmation_timeout_in_minutes = var.sns_topic_subscription_optional.confirmation_timeout_in_minutes
  delivery_policy                 = var.sns_topic_subscription_optional.delivery_policy
  endpoint_auto_confirms          = var.sns_topic_subscription_optional.endpoint_auto_confirms
  filter_policy                   = var.sns_topic_subscription_optional.filter_policy
  filter_policy_scope             = var.sns_topic_subscription_optional.filter_policy_scope
  raw_message_delivery            = var.sns_topic_subscription_optional.raw_message_delivery
  redrive_policy                  = var.sns_topic_subscription_optional.redrive_policy
  replay_policy                   = var.sns_topic_subscription_optional.replay_policy
}
