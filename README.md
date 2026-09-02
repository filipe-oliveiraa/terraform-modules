# Terraform Modules by Filipe Oliveira

AWS-first Terraform modules, built to be reused rather than copied. **Simple**
modules wrap one AWS resource and mirror its arguments; **Complex** modules
compose several into a pattern and bring guardrails with them.

**[Module catalog →](CATALOG.md)** (generated from the tree, so it cannot drift)

## Using a module

Modules are consumed straight from git, pinned to a per-module tag:

```hcl
module "deploy_role" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/security/iam-role?ref=iam-role/v1.0.0"

  assume_role_policy = data.aws_iam_policy_document.assume.json

  iam_role_optional = {
    name = "deploy"
    tags = { Team = "platform" }
  }
}
```

Tags are `<module-name>/vX.Y.Z`, so each module versions independently and a fix
to one does not bump the rest. A `git::` source takes an exact `ref` - there is
no `~> 1.0` range without a registry in front.

## What you can expect from a module

Every module in the catalog has:

- `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf` - the same four files,
  the same names, everywhere.
- A `description` and an explicit `type` on every input and output.
- `terraform test` coverage running against a mocked provider, so the tests
  need no credentials and cost nothing. **20 modules, 75 test cases.**
- Version *floors* rather than pins (`>= 1.5`, `aws >= 5.0, < 7.0`): the module
  states what it needs and the root module picks the exact version.

## Design rules

**Simple modules do not invent defaults.** They mirror the provider, because a
wrapper that quietly differs from the resource it wraps is harder to reason
about than the resource. The one exception is a default that is free, applies
in place, and prevents a well-known compromise - `ec2` sets
`metadata_options.http_tokens = "required"` so IMDSv2 is on unless you say
otherwise.

**Complex modules do bring guardrails.** Encryption, public access blocks,
ownership controls, origin access control. If a Complex module leaves the unsafe
option as the default, that is a bug rather than a preference.

**Invalid calls fail at plan, not at apply.** AWS has many "one of X, Y or Z
must be specified" rules that a fully-optional wrapper silently drops, so a bad
call plans cleanly and then fails minutes into an apply quoting an argument you
never typed. Those rules are encoded as variable `validation` blocks and
resource `precondition`s, phrased in terms of this module's inputs.

**Cost is surfaced, never imposed.** Access logging, tracing and customer-managed
keys all cost money, so they stay off - but the module warns rather than staying
silent. `check` blocks report on plan and apply and never block either:

```
Warning: Check block assertion failed
  CloudFront access logging is off. Set logging_bucket to enable it. ...
```

Do what it asks or accept it; either way it was a decision, not an accident.

**`for_each` keys are identities.** No list index ever reaches a resource
address, directly or via a map built from one - deleting one element must not
re-key and recreate everything after it.

## Repo layout

```
aws/
  compute/        ec2, lambda-function, lambda-permission
  integration/    eventbridge, sns-topic, sns-topic-subscription
  networking/     route53-zone-records, security-group
  observability/  cloudwatch-metric-alarm
  security/       iam-*, secrets-manager-secret, github-oidc-role
  storage/        s3-bucket-replication, s3-static-site-cloudfront, s3-tfstate-backend
tools/
  gen-catalog.sh  regenerates CATALOG.md from the tree
  package-lambdas/  packages mixed Node/Python Lambdas into deployable zips
```

`Simple` and `Complex` are a property of a module, not a directory level - they
live in the catalog table.

## Contributing

[CONTRIBUTING.md](CONTRIBUTING.md) has the module contract, the plan-time
validation rules, the `terraform test` gotchas, and the release process.

```bash
terraform fmt -check -recursive

cd aws/<domain>/<module>
terraform init -backend=false && terraform validate && terraform test
```

CI runs the same per module, plus `trivy config` across the catalog.
[SECURITY-BASELINE.md](SECURITY-BASELINE.md) records what the scanner reports
and the position taken on each finding.

## License

[Apache 2.0](LICENSE).

## About me

- GitHub: [github.com/filipe-oliveiraa](https://github.com/filipe-oliveiraa)
- LinkedIn: [linkedin.com/in/filipe-amaro-oliveira](https://www.linkedin.com/in/filipe-amaro-oliveira)
