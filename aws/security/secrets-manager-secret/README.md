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
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/security/secrets-manager-secret?ref=secrets-manager-secret/v1.0.0"

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

## Behaviour worth knowing

**This module creates the secret container, never its value.** There used to be
a `secret_string` input. It was declared and wired to nothing, so setting it
stored no value in Secrets Manager while still putting the secret into the plan
output and the state file - the worst of both outcomes.

It was removed rather than wired up, because `aws_secretsmanager_secret_version`
keeps the plaintext in state permanently, readable by anyone with access to the
state backend. Put the value in out of band, once:

```bash
aws secretsmanager put-secret-value --secret-id <name> --secret-string '...'
```

and let whatever needs it read it at runtime.
