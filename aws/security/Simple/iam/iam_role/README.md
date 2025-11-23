# IAM Role Module

Creates an IAM role with optional inline policy and common tunables like max session duration, permissions boundary, and tags.

## Requirements / Assumptions
- Required: `assume_role_policy` JSON.
- Provide either `name` or `name_prefix`.
- Inline policy is optional; attach managed policies externally or via the role policy attachment module.

## Inputs
- `assume_role_policy` (string, required): JSON policy.
- `iam_role_optional` (object): `name`/`name_prefix`, `description`, `path`, `permissions_boundary`, `force_detach_policies`, `max_session_duration`, `tags`, optional `inline_policy` (`name`, `policy`).

## Outputs
- `id`, `name`, `arn`, `unique_id`, `create_date`, `tags_all`

## Example
```hcl
module "iam_role" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/security/Simple/iam/iam_role?ref=v1.0.0"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  iam_role_optional = {
    name                 = "lambda-exec"
    max_session_duration = 3600
    tags                 = { Service = "lambda" }
  }
}
```
*** End Patch
