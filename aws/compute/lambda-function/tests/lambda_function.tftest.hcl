mock_provider "aws" {}

variables {
  function_name = "backup-freshness"
  role          = "arn:aws:iam::123456789012:role/lambda-exec"

  lambda_function_optional = {
    filename = "build/function.zip"
  }
}

run "required_inputs_reach_the_resource" {
  command = plan

  assert {
    condition     = aws_lambda_function.lambda_function.function_name == "backup-freshness"
    error_message = "function_name must be passed through unmodified."
  }

  assert {
    condition     = aws_lambda_function.lambda_function.role == var.role
    error_message = "role must be passed through unmodified."
  }
}

run "no_vpc_config_unless_asked_for" {
  command = plan

  # Attaching a Lambda to a VPC changes its whole egress path, so it must be an
  # explicit choice rather than something the module does by default.
  assert {
    condition     = length(aws_lambda_function.lambda_function.vpc_config) == 0
    error_message = "A Lambda must not be placed in a VPC unless vpc_config was set."
  }
}

run "vpc_config_block_renders_when_set" {
  command = plan

  variables {
    lambda_function_optional = {
      filename = "build/function.zip"
      vpc_config = {
        subnet_ids         = ["subnet-aaaa1111", "subnet-bbbb2222"]
        security_group_ids = ["sg-cccc3333"]
      }
    }
  }

  assert {
    condition     = length(aws_lambda_function.lambda_function.vpc_config) == 1
    error_message = "Setting vpc_config must render exactly one vpc_config block."
  }
}

run "runtime_and_handler_flow_through" {
  command = plan

  variables {
    lambda_function_optional = {
      filename = "build/function.zip"
      runtime  = "python3.12"
      handler  = "app.handler"
      timeout  = 60
    }
  }

  assert {
    condition     = aws_lambda_function.lambda_function.runtime == "python3.12"
    error_message = "runtime must come from lambda_function_optional."
  }

  assert {
    condition     = aws_lambda_function.lambda_function.timeout == 60
    error_message = "timeout must come from lambda_function_optional."
  }
}

# Regression tests. This module used to plan with no code source at all and
# only fail at apply, with the provider's own
# "one of filename,image_uri,s3_bucket must be specified".
run "no_code_source_is_rejected_at_plan_time" {
  command = plan

  variables {
    lambda_function_optional = {}
  }

  expect_failures = [
    aws_lambda_function.lambda_function,
  ]
}

run "two_code_sources_are_rejected_at_plan_time" {
  command = plan

  variables {
    lambda_function_optional = {
      filename  = "build/function.zip"
      image_uri = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/app:v1"
    }
  }

  expect_failures = [
    aws_lambda_function.lambda_function,
  ]
}

run "s3_source_without_key_is_rejected_at_plan_time" {
  command = plan

  variables {
    lambda_function_optional = {
      s3_bucket = "my-lambda-artifacts"
    }
  }

  expect_failures = [
    aws_lambda_function.lambda_function,
  ]
}
