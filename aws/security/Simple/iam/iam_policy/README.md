# IAM Policy Module

Creates a standalone IAM policy from a JSON document with optional naming controls and tags. Pair with the policy attachment modules to bind it to users, groups, or roles.

## Requirements / Assumptions
- Required: `policy` JSON string.
- Provide either `name` or `name_prefix`.

## Inputs
- `policy` (string, required): IAM policy document.
- `iam_policy_optional` (object): `name`/`name_prefix`, `description`, `path`, `tags`

## Outputs
- `id`, `arn`, `policy_id`, `attachment_count`, `tags_all`

## Example
```hcl
module "iam_policy" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/security/Simple/iam/iam_policy?ref=v1.0.0"

  policy = data.aws_iam_policy_document.s3_access.json
  iam_policy_optional = {
    name = "s3-readonly"
    tags = { ManagedBy = "terraform" }
  }
}
```
