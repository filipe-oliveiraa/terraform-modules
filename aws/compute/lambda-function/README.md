# Lambda Function Module

Creates an AWS Lambda function with most provider options exposed via a single optional object. Supports Zip or container image packaging, VPC networking, SnapStart, logging config, and edge cases like file system mounts or DLQ.

## Requirements / Assumptions
- Required: `function_name` and `role` (IAM role ARN).
- For Zip deploys: set `runtime` and `handler`, and provide one of `filename` or `s3_bucket`/`s3_key`/`s3_object_version`. For image deploys: set `package_type = "Image"` and `image_uri`.
- SnapStart, logging, VPC, file system, and DLQ blocks are optional and only rendered when provided.

## Inputs
- `function_name` (string, required): Lambda name.
- `role` (string, required): Execution role ARN.
- `lambda_function_optional` (object): Optional settings like `runtime`, `handler`, `architectures`, `memory_size`, `timeout`, `layers`, `publish`, `kms_key_arn`, `vpc_config`, `environment`, `logging_config`, `snap_start`, `file_system_config`, `dead_letter_config`, `tracing_config`, `ephemeral_storage`, tags, and package sources (`filename` or `s3_*` or `image_uri`).

## Outputs
- `arn`, `invoke_arn`, `qualified_arn`, `qualified_invoke_arn`
- `version`, `code_sha256`, `source_code_size`, `last_modified`
- `snap_start_optimization_status`, `vpc_id`, `tags_all`, `signing_job_arn`, `signing_profile_version_arn`

## Example (Zip package from S3)
```hcl
module "lambda" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/compute/lambda-function?ref=lambda-function/v1.0.0"

  function_name = "payments-worker"
  role          = aws_iam_role.lambda_exec.arn

  lambda_function_optional = {
    runtime     = "python3.11"
    handler     = "handler.lambda_handler"
    s3_bucket   = "my-lambda-artifacts"
    s3_key      = "payments-worker.zip"
    timeout     = 30
    memory_size = 512
    environment = {
      variables = {
        STAGE = "prod"
      }
    }
    vpc_config = {
      subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
      security_group_ids = [aws_security_group.lambda.id]
    }
    logging_config = {
      log_format = "JSON"
      log_group  = "/aws/lambda/payments-worker"
    }
    tags = { Service = "payments" }
  }
}
```

## Behaviour worth knowing

**Exactly one code source, checked at plan time.** `filename`, `image_uri` and
`s3_bucket` are mutually exclusive and one of them is required; if you use
`s3_bucket` you also need `s3_key`. Preconditions enforce both at plan, so a
call that gets it wrong fails immediately with a message about the module's
inputs, rather than partway into an apply with the provider's
`"one of filename,image_uri,s3_bucket must be specified"`.

**No VPC unless you ask.** `vpc_config` is only rendered when you set it -
attaching a Lambda to a VPC changes its entire egress path, so it stays an
explicit choice.
