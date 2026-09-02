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
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/compute/Simple/lambda/lambda?ref=v1.0.0"

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
