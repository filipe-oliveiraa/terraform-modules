# Refer to https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission

resource "aws_lambda_permission" "lambda_permission" {
  #Required parameters
  action        = var.action
  function_name = var.function_name
  principal     = var.principal

  #Optional parameters
  event_source_token     = var.lambda_permission_optional.event_source_token
  function_url_auth_type = var.lambda_permission_optional.function_url_auth_type
  principal_org_id       = var.lambda_permission_optional.principal_org_id
  qualifier              = var.lambda_permission_optional.qualifier
  #region = var.lambda_permission_optional.region
  source_account      = var.lambda_permission_optional.source_account
  source_arn          = var.lambda_permission_optional.source_arn
  statement_id        = var.lambda_permission_optional.statement_id
  statement_id_prefix = var.lambda_permission_optional.statement_id_prefix

}