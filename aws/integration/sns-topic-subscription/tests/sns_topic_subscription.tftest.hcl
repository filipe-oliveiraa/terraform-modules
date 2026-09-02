mock_provider "aws" {}

variables {
  topic_arn = "arn:aws:sns:eu-west-1:123456789012:alerts"
  protocol  = "email"
  endpoint  = "ops@example.com"
}

run "required_inputs_reach_the_resource" {
  command = plan

  assert {
    condition     = aws_sns_topic_subscription.sns_topic_subscription.topic_arn == var.topic_arn
    error_message = "topic_arn must be passed through unmodified."
  }

  assert {
    condition     = aws_sns_topic_subscription.sns_topic_subscription.protocol == "email"
    error_message = "protocol must be passed through unmodified."
  }

  assert {
    condition     = aws_sns_topic_subscription.sns_topic_subscription.endpoint == "ops@example.com"
    error_message = "endpoint must be passed through unmodified."
  }
}

run "raw_message_delivery_is_off_unless_asked_for" {
  command = plan

  # Turning this on changes the message body subscribers receive, so it must
  # never be a default.
  assert {
    condition     = aws_sns_topic_subscription.sns_topic_subscription.raw_message_delivery != true
    error_message = "raw_message_delivery must not default to true - it changes the payload subscribers get."
  }
}

run "firehose_subscription_role_flows_through" {
  command = plan

  variables {
    protocol = "firehose"
    endpoint = "arn:aws:firehose:eu-west-1:123456789012:deliverystream/logs"
    sns_topic_subscription_optional = {
      subscription_role_arn = "arn:aws:iam::123456789012:role/sns-firehose"
      raw_message_delivery  = true
    }
  }

  assert {
    condition     = aws_sns_topic_subscription.sns_topic_subscription.subscription_role_arn == "arn:aws:iam::123456789012:role/sns-firehose"
    error_message = "subscription_role_arn is required for firehose subscriptions and must flow through."
  }
}
