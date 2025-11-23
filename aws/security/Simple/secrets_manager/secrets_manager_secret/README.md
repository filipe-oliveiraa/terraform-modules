# Secrets Manager Secret Module

Creates a Secrets Manager secret with optional replica configuration and tagging. Keeps the surface close to the provider for easy drop-in use.

## Requirements / Assumptions
- Provide `name` or `name_prefix`. If using `aws:kms` CMK encryption, supply `kms_key_id`.
- Replication is optional; set `replica` with target `region` (and optional `kms_key_id`) to enable.

## Inputs
- `secretsmanager_secret_optional` (object): `name`/`name_prefix`, `description`, `kms_key_id`, `policy`, `recovery_window_in_days`, `force_overwrite_replica_secret`, `tags`, and optional `replica` block (`region`, `kms_key_id`).

## Outputs
- `arn`, `name`, `replica`, `tags_all`

## Example
```hcl
module "secret" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/security/Simple/secrets_manager/secrets_manager_secret?ref=v1.0.0"

  secretsmanager_secret_optional = {
    name        = "app/db-password"
    description = "Database password for app"
    kms_key_id  = aws_kms_key.secrets.arn
    tags        = { Service = "app" }
    replica = {
      region = "us-west-2"
    }
  }
}
```
