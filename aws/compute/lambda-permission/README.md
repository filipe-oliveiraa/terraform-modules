# Lambda Permission Module

Grants another AWS service or account permission to invoke a Lambda function. Wraps `aws_lambda_permission` with optional qualifiers and source scoping.

## Requirements / Assumptions
- Required: `action` (e.g., `lambda:InvokeFunction`), `function_name` (name or ARN), and `principal` (`events.amazonaws.com`, `s3.amazonaws.com`, etc.).
- Use `source_arn`/`source_account` to scope permissions for EventBridge, S3, API Gateway, or other callers.

## Inputs
- `action` (string, required): Lambda action to allow.
- `function_name` (string, required): Target Lambda name or ARN.
- `principal` (string, required): Calling service or account.
- `lambda_permission_optional` (object): `source_arn`, `source_account`, `qualifier`, `statement_id` or `statement_id_prefix`, `principal_org_id`, `event_source_token`, `function_url_auth_type`.

## Outputs
- This resource does not export additional outputs.

## Example (EventBridge rule invoking Lambda)
```hcl
module "lambda_permission_eventbridge" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/compute/Simple/lambda/lambda_permission?ref=v1.0.0"

  action        = "lambda:InvokeFunction"
  function_name = module.lambda.arn
  principal     = "events.amazonaws.com"
  lambda_permission_optional = {
    source_arn = aws_cloudwatch_event_rule.example.arn
    qualifier  = "live"
  }
}
```
