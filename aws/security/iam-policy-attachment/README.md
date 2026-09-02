# IAM Policy Attachment Module

Attaches an IAM policy ARN to any mix of users, groups, and roles in one call. Useful for broad grants without managing multiple separate attachments.

## Requirements / Assumptions
- Required: `name` (attachment name) and `policy_arn`.
- Provide at least one of `users`, `roles`, or `groups`.

## Inputs
- `name` (string, required)
- `policy_arn` (string, required)
- `iam_policy_attachment_optional` (object): `users`, `roles`, `groups` (lists)

## Outputs
- `id`, `name`

## Example
```hcl
module "policy_attachment" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/security/Simple/iam/iam_policy_attachment?ref=v1.0.0"

  name       = "s3-readonly-to-devs"
  policy_arn = module.iam_policy.arn
  iam_policy_attachment_optional = {
    roles = [module.iam_role.name]
    users = ["alice", "bob"]
  }
}
```
