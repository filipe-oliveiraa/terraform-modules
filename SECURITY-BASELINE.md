# Security baseline

What `trivy config aws` reports on this catalog, and the position taken on each
finding. CI runs the scan on every push but does not fail on it, because a
scanner cannot tell a deliberate design choice from an oversight. This file is
where that distinction lives.

Re-run it yourself:

```bash
trivy config aws --severity CRITICAL,HIGH,MEDIUM,LOW
```

## Fixed

| ID | Module | Finding | What changed |
|----|--------|---------|--------------|
| AWS-0028 | `ec2` | Instance does not require IMDS access to require a token | The module now always renders `metadata_options` with `http_tokens = "required"`, so IMDSv2 is the default. An instance answering IMDSv1 turns any SSRF in an app on the box into instance-role credential theft. Setting it is an in-place update, so nothing is replaced. An explicit `http_tokens` still wins. |
| AWS-0131 | `ec2` | Root block device is not encrypted | `root_block_device` is now rendered unconditionally with `encrypted` defaulting to true, so a call passing no block still gets an encrypted root volume. This was first shipped as a `check` warning instead, on the grounds that encryption forces instance replacement - true, but only for instances that already exist. Making it the default and taking the major version was the better trade, and `encrypt_root_volume = false` remains as an opt-out that warns. Released as `ec2/v2.0.0`. |

## Accepted, with the decision surfaced at plan time

Each of these stays open on purpose. All but one produce a `check` block
warning when you plan, so the choice is presented rather than silently made.

| ID | Sev | Module | Why it stays |
|----|-----|--------|--------------|
| AWS-0132 | HIGH | `s3-tfstate-backend` | Bucket uses SSE-S3 rather than a customer managed key. SSE-KMS adds per-request KMS charges and another key policy to keep correct, for a bucket only Terraform writes to. If your compliance posture requires a CMK, this is the finding to act on. Not warned about, because there is no cost-free version of the fix to point at. |
| AWS-0010 | MEDIUM | `s3-static-site-cloudfront` | CloudFront access logging off. Logs are billed as S3 storage and requests. A `check` block warns on every plan; set `logging_bucket` to act on it. |
| AWS-0089 | LOW | `s3-static-site-cloudfront`, `s3-tfstate-backend` | S3 server access logging off. Same reasoning. `s3-tfstate-backend` gained `access_log_bucket`/`access_log_prefix` and a `check` warning; the static-site origin bucket is reached only through CloudFront OAC, so CloudFront's own logs are the more useful of the two. |
| AWS-0066 | LOW | `lambda-function` | X-Ray tracing off. Tracing is billed per trace and is a property of the application being deployed rather than of the wrapper. Set `tracing_config` to enable. |

## Why Simple modules mostly do not appear here

A Simple module wraps one resource and mirrors its arguments; it does not impose
defaults, because a wrapper that quietly differs from the resource it wraps is
harder to reason about than the resource. A scanner will therefore report
things like "this could be created unencrypted" - true, and the caller's
decision.

The exception is a default that is **free, applies in place, and prevents a
well-known compromise**. IMDSv2 above is the only case in the catalog that meets
all three.

Complex modules are held to a higher bar: they compose a pattern, so they own
its guardrails. Encryption at rest, public access blocks, ownership controls and
origin access control are on by default in `s3-static-site-cloudfront` and
`s3-tfstate-backend`, and there are tests asserting each of them stays that way.

## Scanner choice

Trivy, not tfsec. tfsec is in maintenance mode and its parser rejects Terraform
1.5 `check` blocks (`Blocks of type "check" are not expected here`), which
several modules here rely on. Trivy is its supported successor and reads them.
