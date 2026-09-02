mock_provider "aws" {}

variables {
  action        = "lambda:InvokeFunction"
  function_name = "backup-freshness"
  principal     = "events.amazonaws.com"
}

run "required_inputs_reach_the_resource" {
  command = plan

  assert {
    condition     = aws_lambda_permission.lambda_permission.action == "lambda:InvokeFunction"
    error_message = "action must be passed through unmodified."
  }

  assert {
    condition     = aws_lambda_permission.lambda_permission.principal == "events.amazonaws.com"
    error_message = "principal must be passed through unmodified."
  }
}

run "source_arn_flows_through" {
  command = plan

  variables {
    lambda_permission_optional = {
      statement_id = "AllowEventBridgeInvoke"
      source_arn   = "arn:aws:events:eu-west-1:123456789012:rule/every-hour"
    }
  }

  # source_arn is what stops "any EventBridge rule in any account" from being
  # able to invoke the function, so it is worth asserting it is not dropped.
  assert {
    condition     = aws_lambda_permission.lambda_permission.source_arn == "arn:aws:events:eu-west-1:123456789012:rule/every-hour"
    error_message = "source_arn must flow through - without it the permission is far broader than intended."
  }
}
