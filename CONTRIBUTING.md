# Contributing

## The module contract

Every module in `aws/<domain>/<module-name>/` ships these files:

| File | Required | Contents |
|------|----------|----------|
| `main.tf` | yes | The resources. Named `main.tf` in every module, not `<resource>.tf`. |
| `variables.tf` | yes | Every input, each with a `description` and an explicit `type`. |
| `outputs.tf` | yes | Every output with a `description`. If the resource genuinely exports nothing useful, export its `id` and say why in a comment. |
| `versions.tf` | yes | `required_version` and `required_providers`. |
| `README.md` | yes | What it builds, inputs, outputs, at least one worked example. |
| `tests/*.tftest.hcl` | yes | `terraform test` with a mocked provider. |

Directory and file names are kebab-case. The domain folders are
`compute`, `integration`, `networking`, `observability`, `security` and
`storage`; add a new one only when a module genuinely fits none of them.

## Version constraints: floors here, pins in the caller

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0, < 7.0" }
  }
}
```

A library module says the minimum it needs and lets the root module choose the
exact version. Pinning `~> 6.62` here would force that choice on every consumer
and make two modules impossible to use together the moment their pins diverge.
The upper bound is there so a provider major cannot change resource behaviour
under a module version that was already released and tested.

Raise a module's floor only if it actually uses a newer feature, and say which
in a comment. Cross-variable `validation` needs 1.9, for instance - which is
why modules that need to check two variables against each other use a
`lifecycle` `precondition` instead, and stay on 1.5.

## Simple and Complex

The catalog splits modules two ways. This is metadata, not a directory level:

- **Simple** wraps one AWS resource and mirrors its arguments. It does not
  impose defaults, because a wrapper that quietly differs from the provider is
  harder to reason about than the provider itself.
- **Complex** composes several resources into a pattern and *does* come with
  guardrails - encryption, public-access blocks, ownership controls. If a
  Complex module does not make the safe thing the default, that is a bug.

There is one exception to Simple's neutrality: a default that is free, applies
in place, and prevents a well-known compromise. `ec2` sets
`metadata_options.http_tokens = "required"` for that reason. An explicit value
from the caller always wins.

## Say no at plan time, not at apply time

AWS has plenty of "one of X, Y or Z must be specified" rules. A module that
declares everything as `optional()` silently drops them, so a bad call plans
cleanly and fails minutes later during apply, quoting a resource argument the
caller never typed.

Encode those rules:

- inputs in **one** variable → a `validation` block on that variable
- inputs spanning **two** variables → a `precondition` in the resource's
  `lifecycle` (a variable `validation` referring to another variable needs 1.9)

Give the error message in terms of the module's own inputs, and add a
regression test with `expect_failures`.

## Suggest cost, never impose it

Access logging, tracing, detailed monitoring and customer-managed keys all cost
money. Do not turn them on by default and do not stay silent about them either.
Use a `check` block: it reports a warning on plan and apply and never blocks
either.

```hcl
check "cloudfront_access_logging" {
  assert {
    condition     = var.logging_bucket != null
    error_message = "CloudFront access logging is off. Set logging_bucket to enable it. ..."
  }
}
```

Same rule for anything that would force a resource to be replaced -
`ec2`'s root-volume encryption warns rather than defaults, because switching it
on an existing instance destroys and recreates it.

Note that `terraform test` treats a failing `check` as a test failure. Either
satisfy it in the test's `variables` block, or assert the warning on purpose:

```hcl
expect_failures = [check.cloudfront_access_logging]
```

## Writing tests

`mock_provider "aws" {}` - no cloud calls, no credentials, no cost. Three
things that will bite you:

1. **Optional+Computed attributes are unknown under `command = plan`.** A name
   AWS generates, `associate_public_ip_address` derived from the subnet: you
   cannot assert on them at plan. Assert something config-derived, or use
   `command = apply`.
2. **Comparisons against a computed id need `command = apply`** - for example
   checking a rule attaches to the group this module created.
3. **Set-type blocks cannot be indexed.** `rule[0]` fails on
   `aws_s3_bucket_server_side_encryption_configuration`. Use a `for` expression.

If a module renders a policy document, the mock's default random string is not
valid JSON and the provider rejects it. Give it one:

```hcl
mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" }
  }
}
```

## for_each keys are identities

Never let a list index reach a resource address, including indirectly. A map
built as `"${x.name}_${idx}" => x` looks like a `for_each` but behaves like a
`count`: delete one element and everything after it is re-keyed, which
Terraform carries out as destroy-and-recreate. Key on what identifies the thing
to AWS - for a Route 53 record that is name, type and `set_identifier`.

## Releasing

Tags are per module, `<module-name>/vX.Y.Z`:

```bash
git tag route53-zone-records/v1.1.0
git push origin route53-zone-records/v1.1.0
```

The separator is `/` on purpose. With a `-`, the tag `iam-role-v1.0.0` is a
prefix match for `iam-role-policy-attachment-v1.0.0`, so anything filtering
tags by module prefix would pick up both.

Consumers pin the tag:

```hcl
module "role" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/security/iam-role?ref=iam-role/v1.0.0"
}
```

Semver applies per module: patch for a fix that changes no inputs, minor for a
new optional input, **major for anything that changes an input's name, shape or
meaning, or that changes a resource address**. A re-keyed `for_each` is a major
even though no input changed, because it destroys and recreates.

Note that `git::` sources take an exact `ref` - there is no `~> 1.0` for them.
That is the trade-off for not running a registry.

## Before opening a PR

```bash
terraform fmt -check -recursive

# per module you touched
cd aws/<domain>/<module>
terraform init -backend=false && terraform validate && terraform test
```

CI runs the same thing for every module, plus `tfsec` over the catalog.
