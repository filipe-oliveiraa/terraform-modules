# S3 Terraform State Backend Module

Creates the S3 bucket a Terraform `backend "s3"` writes to, with the settings a
state bucket needs rather than the ones a general-purpose bucket gets: object
lock, versioning, encryption at rest, and public access fully blocked.

## Requirements / Assumptions

- Bucket names are globally unique across all of AWS; `bucket_name` must be free.
- Since Terraform 1.10 you no longer need a DynamoDB table for locking - use
  `use_lockfile = true` in the backend config and the lock lives in S3 next to
  the state.

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `bucket_name` | string | — | Name of the bucket. |
| `s3_bucket_optional` | object | `{}` | `bucket_prefix`, `force_destroy`, `object_lock_enabled`, `tags`. |
| `s3_bucket_versioning_optional` | object | `{}` | `mfa_delete`, `expected_bucket_owner`, `mfa`. |
| `access_log_bucket` | string | `null` | Target bucket for S3 server access logs. Null leaves logging off. |
| `access_log_prefix` | string | `null` | Key prefix for delivered logs. Defaults to `<bucket_name>/`. |

## Outputs

`id`, `arn`, `bucket_domain_name`, `bucket_regional_domain_name`,
`hosted_zone_id`, `region`, `versioning_status`, `public_access_block_id`.

## Example

```hcl
module "tfstate" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/storage/s3-tfstate-backend?ref=s3-tfstate-backend/v1.0.0"

  bucket_name = "acme-terraform-state"

  s3_bucket_optional = {
    tags = { Purpose = "terraform-state" }
  }

  access_log_bucket = "acme-audit-logs"
}
```

Then, in the configuration whose state it holds:

```hcl
terraform {
  backend "s3" {
    bucket       = "acme-terraform-state"
    key          = "prod/network/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

## Behaviour worth knowing

**Object lock defaults to on, and now honours `false`.** It was previously
hardcoded to `true`, so a caller asking for `false` silently got `true` - on a
setting that cannot be undone once the bucket exists. It still defaults to `true`
(right default for a state bucket: it stops a corrupted write from overwriting
the last good state), but an explicit `false` is respected.

**Access logging is opt-in and warned about.** Set `access_log_bucket` (and
optionally `access_log_prefix`) to enable it. While it is off, a `check` block
reports a warning on plan and apply without blocking either. It is off by
default because the log objects cost S3 storage, and warned about because this
bucket holds every resource id in your deployment.

**Encryption is SSE-S3, not SSE-KMS.** Security scanners flag this as "not using
a customer managed key". That is a deliberate trade-off: SSE-KMS adds per-request
KMS charges and another key policy to keep correct. If your compliance posture
requires a CMK, that is a good reason to change it.
