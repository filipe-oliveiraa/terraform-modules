# SNS Topic Module

Creates an SNS topic with full optionality for FIFO, KMS encryption, delivery policies, and feedback roles. Mirrors the AWS provider attributes so you can tune throughput, tracing, and per-protocol feedback.

## Requirements / Assumptions
- Set either `name` or `name_prefix`.
- For FIFO topics, set `fifo_topic = true` and use `.fifo` suffix in the name/prefix.
- Provide `kms_master_key_id` when you need CMK encryption.

## Inputs
- `sns_topic_optional` (object): Naming (`name`/`name_prefix`), display and delivery policies, FIFO flags, archive policy, KMS key, tracing, feedback roles/sample rates for HTTP/Lambda/SQS/Firehose/Application, signature version, and tags.

## Outputs
- `id`/`arn`, `owner`, `beginning_archive_time`, `tags_all`

## Example
```hcl
module "sns_topic" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/integration/Simple/sns/sns_topic?ref=v1.0.0"

  sns_topic_optional = {
    name            = "orders-updates"
    kms_master_key_id = aws_kms_key.sns.arn
    fifo_topic        = false
    tracing_config    = "PassThrough"
    tags = { Service = "orders" }
  }
}
```
