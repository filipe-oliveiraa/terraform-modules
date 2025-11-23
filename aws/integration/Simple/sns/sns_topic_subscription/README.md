# SNS Topic Subscription Module

Creates an SNS subscription for any supported protocol (HTTP/S, Lambda, SQS, Firehose, SMS, email, etc.) with optional delivery, filter, and replay policies.

## Requirements / Assumptions
- Required: `topic_arn`, `protocol`, and `endpoint` appropriate for the protocol.
- When `protocol = "firehose"`, set `subscription_role_arn`.
- HTTP/HTTPS endpoints may use `confirmation_timeout_in_minutes` and `delivery_policy`.

## Inputs
- `endpoint` (string, required): Destination (URL, ARN, email, phone, etc.).
- `protocol` (string, required): `sqs`, `lambda`, `firehose`, `http`, `https`, `email`, `email-json`, `sms`, `application`.
- `topic_arn` (string, required): Topic to subscribe to.
- `sns_topic_subscription_optional` (object): `subscription_role_arn`, `confirmation_timeout_in_minutes`, `delivery_policy`, `endpoint_auto_confirms`, `filter_policy`, `filter_policy_scope`, `raw_message_delivery`, `redrive_policy`, `replay_policy`, `region`.

## Outputs
- `arn`, `id`, `owner_id`, `pending_confirmation`, `confirmation_was_authenticated`

## Example (Lambda subscriber)
```hcl
module "sns_subscription_lambda" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/integration/Simple/sns/sns_topic_subscription?ref=v1.0.0"

  topic_arn = module.sns_topic.arn
  protocol  = "lambda"
  endpoint  = module.lambda.arn

  sns_topic_subscription_optional = {
    filter_policy = jsonencode({ event = ["created", "updated"] })
  }
}
```
