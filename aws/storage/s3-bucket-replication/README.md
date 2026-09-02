# S3 Cross-Account Replication Module

Implements cross-account S3 replication using the AWS provider resource `aws_s3_bucket_replication_configuration` (per the official docs) with IAM role and bucket policy wiring included.

## Requirements / Assumptions
- Source and destination buckets already exist and **versioning is enabled** on both.
- You know the source bucket ID/ARN and destination bucket ID/ARN and the destination account ID.
- Optional: destination KMS key ARN when encrypting replicas.

## Inputs
- `source_bucket_id` (string, required): ID of the source bucket where replication is configured.
- `source_bucket_arn` (string, required): ARN of the source bucket.
- `destination_bucket_id` (string, required): ID of the destination bucket.
- `destination_bucket_arn` (string, required): ARN of the destination bucket.
- `destination_account_id` (string, default `null`): AWS account ID that owns the destination bucket. Leave `null` for same-account replication.
- `replication_rules` (list(object), default `[]`): One or more rules to create. Each rule supports:
  - `id` (string): Rule identifier.
  - `filter_prefix` (string, optional): Prefix scope; omit/empty to replicate all keys.
  - `enable_replication` (bool, default `true`): Enable/disable the rule.
  - `enable_delete_marker_replication` (bool, default `false`): Toggle delete marker replication.
  - `destination_storage_class` (string, default `STANDARD`): Storage class for replicas.
  - `destination_kms_key_arn` (string, optional): KMS key ARN for replicas.
  - `enable_bucket_owner_enforced` (bool, default `true`): Add access control translation so destination is owner. Requires `destination_account_id` (only for cross-account).
- `replication_role_name` (string, required): IAM role name used by replication.
- `manage_destination_bucket_policy` (bool, default `false`): Attach destination bucket policy from this module. Leave `false` when you cannot or do not need to modify the destination bucket policy.
- `tags` (map(string), default `{}`): Tags applied to IAM role.

## Outputs
- `replication_role_arn`: ARN of the IAM replication role.
- `replication_role_name`: Name of the IAM replication role.
- `destination_bucket_policy_json`: JSON for the destination bucket policy (useful if attaching from another account).
- `replication_configuration_id`: ID of the replication configuration rule.

## Example: Live replication (no delete markers) for a prefix

### Cross-account (destination in another account)
```hcl
module "s3_cross_acct_replication" {
  source = "../../modules/s3_cross_acct_replication"

  source_bucket_id  = aws_s3_bucket.source.id
  source_bucket_arn = aws_s3_bucket.source.arn

  destination_bucket_id  = aws_s3_bucket.dest.id
  destination_bucket_arn = aws_s3_bucket.dest.arn
  destination_account_id = data.aws_caller_identity.dest.account_id

  replication_rules = [
    {
      id                            = "live-replication-bananas"
      filter_prefix                 = "live-data/bananas/"
      enable_delete_marker_replication = false
      destination_storage_class     = "STANDARD"
      destination_kms_key_arn       = aws_kms_key.replica.arn
      enable_bucket_owner_enforced  = true
    },
    {
      id                            = "live-replication-apples"
      filter_prefix                 = "live-data/apples/"
      enable_delete_marker_replication = false
    }
  ]

  manage_destination_bucket_policy = false # leave false; destination account applies the exported policy
  tags = {
    Project = "replication"
    Env     = "prod"
  }
}
```

Notes:
- Ensure versioning is enabled on both buckets before applying.
- Leave `manage_destination_bucket_policy = false` when you cannot modify the destination bucket policy; send `destination_bucket_policy_json` to the destination account to attach.
- For same-account replication, leave `destination_account_id = null`; a destination bucket policy is typically not needed.
- Only set `enable_bucket_owner_enforced = true` when `destination_account_id` is provided (cross-account). For same-account leave it true/false as needed, but access control translation is skipped automatically if no destination account ID is set.

### Same-account replication (replicate all objects)
```hcl
module "s3_replication_same_account" {
  source = "../../modules/s3_cross_acct_replication"

  source_bucket_id  = aws_s3_bucket.source.id
  source_bucket_arn = aws_s3_bucket.source.arn

  destination_bucket_id  = aws_s3_bucket.dest.id
  destination_bucket_arn = aws_s3_bucket.dest.arn
  destination_account_id = null

  replication_rules = [
    {
      id                            = "full-replication"
      enable_delete_marker_replication = false
    }
  ]

  manage_destination_bucket_policy = false
}
```
