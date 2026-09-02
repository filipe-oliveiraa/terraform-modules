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
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/security/iam-policy-attachment?ref=iam-policy-attachment/v1.0.0"

  name       = "s3-readonly-to-devs"
  policy_arn = module.iam_policy.arn
  iam_policy_attachment_optional = {
    roles = [module.iam_role.name]
    users = ["alice", "bob"]
  }
}
```

## Behaviour worth knowing

**At least one target is required.** `aws_iam_policy_attachment` needs `users`,
`roles` or `groups`. The module used to accept none of them, plan cleanly, and
fail at apply with `"one of groups,roles,users must be specified"`. A variable
validation now rejects that at plan time.

Note this resource is *exclusive*: it takes over the full attachment list for
every principal it names. For attaching one policy to one role without claiming
ownership of that role's other policies, use
[`iam-role-policy-attachment`](../iam-role-policy-attachment) instead.
