
# Terraform Modules by Filipe Oliveira

AWS-first Terraform modules built to be reusable, opinionated where it matters, and easy to slot into real projects. Simple modules map 1:1 to core AWS resources; complex modules compose multiple services (and guardrails) into production-ready stacks.

## What this repo offers
- A curated AWS module catalog split into **Simple** (single-resource wrappers) and **Complex** (multi-resource patterns) to cover common infrastructure blocks.
- Modules wired with optional dynamic blocks so you only set what you need.
- Inputs/outputs kept consistent across modules plus examples/tests applied in a sandbox before landing here; still run your own `terraform validate/plan/apply`.
- Extras like Lambda packaging scripts to speed up delivery alongside infra code.

## Module catalog
| Module path | Type | What it builds | Key AWS resources |
| --- | --- | --- | --- |
| `aws/compute/Simple/ec2` | Simple | Highly configurable EC2 instance | `aws_instance` |
| `aws/compute/Simple/lambda/lambda` | Simple | Lambda function with optional VPC, env, code/package inputs | `aws_lambda_function` |
| `aws/compute/Simple/lambda/lambda_permission` | Simple | Lambda invoke permission for cross-service access | `aws_lambda_permission` |
| `aws/integration/Simple/eventbridge` | Simple | EventBridge bus/rules/targets via upstream module | EventBridge bus, rules, targets |
| `aws/integration/Simple/sns/sns_topic` | Simple | SNS topic with FIFO/KMS/feedback options | `aws_sns_topic` |
| `aws/integration/Simple/sns/sns_topic_subscription` | Simple | SNS subscription (HTTP/SQS/Lambda/Firehose, filters) | `aws_sns_topic_subscription` |
| `aws/networking/Simple/security_group` | Simple | Security group with dynamic ingress/egress blocks | `aws_security_group` |
| `aws/networking/Complex/route53_zone_and_records` | Complex | Hosted zone plus validated record set (alias/standard) | `aws_route53_zone`, `aws_route53_record` |
| `aws/monitoring_logging/Simple/cloudwatch/cloudwatch_metric_alarm` | Simple | Metric alarm with flexible dimensions and actions | `aws_cloudwatch_metric_alarm` |
| `aws/security/Simple/secrets_manager/secrets_manager_secret` | Simple | Secrets Manager secret with optional replica | `aws_secretsmanager_secret` |
| `aws/security/Simple/iam/iam_user` | Simple | IAM user with optional PGP key/tags | `aws_iam_user` |
| `aws/security/Simple/iam/iam_role` | Simple | IAM role with inline policy option | `aws_iam_role` |
| `aws/security/Simple/iam/iam_policy` | Simple | IAM policy document wrapper | `aws_iam_policy` |
| `aws/security/Simple/iam/iam_policy_attachment` | Simple | Attach policy to users/groups/roles | `aws_iam_policy_attachment` |
| `aws/security/Simple/iam/iam_role_policy_attachment` | Simple | Attach policy to a role | `aws_iam_role_policy_attachment` |
| `aws/storage/Complex/s3_static_site_cloudfront_oac` | Complex | Private S3 static site fronted by CloudFront OAC (certs, logging, headers) | `aws_s3_bucket*`, `aws_cloudfront_distribution`, `aws_cloudfront_origin_access_control`, `aws_s3_bucket_policy` |
| `aws/storage/Complex/s3_bucket_replication` | Complex | Same- or cross-account S3 replication with IAM wiring | `aws_iam_role`, `aws_iam_role_policy`, `aws_s3_bucket_replication_configuration` |

## Using a module
- Pin a git tag/branch: `source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/storage/Complex/s3_static_site_cloudfront_oac?ref=v1.0.0"`.
- Run `terraform fmt`, `terraform init`, `terraform validate`, then `terraform plan/apply`.
- Complex modules ship with README examples; Simple modules mirror AWS provider arguments for minimal cognitive load.

## Repo layout
- `aws/compute|integration|networking|security|storage|monitoring_logging/`: Modules grouped by domain, split into `Simple` and `Complex`.
- `aws/test/`: Lightweight validation stacks used to exercise modules before inclusion.
- `tools/scripts/package_lambdas_shell/package_lambdas.sh`: Helper to package mixed Node/Python Lambdas into deployable zips.

## Design philosophy
- Reusable inputs and minimal defaults; opt into advanced features.
- Dynamic blocks to avoid null/empty clutter while keeping the full AWS surface available.
- Opinionated guardrails in complex modules (encryption, ownership controls, public access blocks) that are safe for production use.
- Clear docs and outputs so consumers can plug modules into larger architectures quickly.

## About me
- GitHub: [github.com/filipe-oliveiraa](https://github.com/filipe-oliveiraa)
- LinkedIn: [linkedin.com/in/filipe-amaro-oliveira](https://www.linkedin.com/in/filipe-amaro-oliveira)
