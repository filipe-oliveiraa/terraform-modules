# IAM User Module

Creates a single IAM user with optional path, permissions boundary, and tags. Useful for service or human users where you manage credentials separately.

## Requirements / Assumptions
- Required: `name`.
- This module does not create keys or login profiles; manage credentials/SSO elsewhere.

## Inputs
- `name` (string, required)
- `iam_user_optional` (object): `path`, `permissions_boundary`, `force_destroy`, `tags`

## Outputs
- `id`, `name`, `arn`, `unique_id`, `tags_all`

## Example
```hcl
module "iam_user" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/security/Simple/iam/iam_user?ref=v1.0.0"

  name = "ci-bot"
  iam_user_optional = {
    path = "/service/"
    tags = { Owner = "platform" }
  }
}
```
