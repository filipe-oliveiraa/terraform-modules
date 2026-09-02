# IAM Policy: Lambda S3 Mirror

An IAM policy for a Lambda that copies objects from one S3 bucket to another,
scoped to the specific buckets and key prefixes involved rather than to `s3:*`
on `*`.

It grants, and only grants:

- `s3:ListBucket` on the source bucket, restricted to the listed prefixes
- read on source objects under the listed prefixes
- `s3:ListBucket` on the destination bucket, restricted to its prefixes
- write on destination objects under those prefixes

This module produces the policy document and the `aws_iam_policy`. Attaching it
to a role is a separate step - use
[`iam-role-policy-attachment`](../iam-role-policy-attachment).

## Prefix handling

Prefixes are normalised, so all of these mean the same thing and none of them
produces a double wildcard:

```
"incoming"     ->  incoming/*
"incoming/"    ->  incoming/*
"incoming/*"   ->  incoming/*
```

List permissions and object permissions are separate inputs because they take
different shapes in IAM: listing is constrained by an `s3:prefix` condition on
the bucket ARN, while object access is constrained by the object ARN itself.

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `source_bucket` | string | — | Bucket to read from. |
| `source_list_prefixes` | list(string) | — | Prefixes the Lambda may list in the source bucket. |
| `source_object_prefixes` | list(string) | — | Prefixes the Lambda may read objects under. |
| `dest_bucket` | string | — | Bucket to write to. |
| `dest_prefixes` | list(string) | — | Prefixes the Lambda may write under. |
| `iam_policy_optional` | object | `{}` | `name`, `name_prefix`, `path`, `description`, `tags`. |

## Outputs

`arn`, `id`, `policy_id`, `attachment_count`, `tags_all`.

## Example

```hcl
module "mirror_policy" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/security/iam-policy-lambda-s3-mirror?ref=iam-policy-lambda-s3-mirror/v1.0.0"

  source_bucket          = "acme-uploads"
  source_list_prefixes   = ["incoming/"]
  source_object_prefixes = ["incoming/"]

  dest_bucket   = "acme-archive"
  dest_prefixes = ["mirrored/"]

  iam_policy_optional = {
    name        = "lambda-s3-mirror"
    description = "Copy incoming/ from acme-uploads to mirrored/ in acme-archive"
  }
}

module "attach" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/security/iam-role-policy-attachment?ref=iam-role-policy-attachment/v1.0.0"

  role       = module.mirror_lambda_role.name
  policy_arn = module.mirror_policy.arn
}
```
