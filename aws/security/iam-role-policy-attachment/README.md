# IAM Role Policy Attachment Module

Attaches a managed policy ARN to a single IAM role. Purpose-built for narrow role grants when you do not need to attach to users or groups.

## Requirements / Assumptions
- Required: `role` (name) and `policy_arn`.

## Inputs
- `role` (string, required): Target IAM role name.
- `policy_arn` (string, required): Managed policy ARN to attach.

## Outputs
- This resource does not export additional outputs.

## Example
```hcl
module "role_policy_attachment" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/security/Simple/iam/iam_role_policy_attachment?ref=v1.0.0"

  role       = module.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
```
