# Unit tests: mocked AWS provider, so nothing is created and nothing is billed.
mock_provider "aws" {}

variables {
  assume_role_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
}

run "required_input_reaches_the_resource" {
  command = plan

  assert {
    condition     = aws_iam_role.iam_role.assume_role_policy == var.assume_role_policy
    error_message = "assume_role_policy must be passed through unmodified."
  }
}

run "optional_object_defaults_to_empty" {
  command = plan

  # The point of default = {} : the module is callable with only the required
  # inputs. name is deliberately not asserted here - it is Optional+Computed,
  # so when it is left unset the provider fills it and the value is unknown
  # until apply.
  assert {
    condition     = length(aws_iam_role.iam_role.inline_policy) == 0
    error_message = "No inline_policy input must produce no inline_policy block."
  }
}

run "optional_values_flow_through" {
  command = plan

  variables {
    iam_role_optional = {
      name                 = "svc-role"
      path                 = "/service/"
      max_session_duration = 7200
      tags                 = { Owner = "platform" }
    }
  }

  assert {
    condition     = aws_iam_role.iam_role.name == "svc-role"
    error_message = "name must come from iam_role_optional."
  }

  assert {
    condition     = aws_iam_role.iam_role.max_session_duration == 7200
    error_message = "max_session_duration must come from iam_role_optional."
  }

  assert {
    condition     = aws_iam_role.iam_role.tags["Owner"] == "platform"
    error_message = "tags must come from iam_role_optional."
  }
}

run "inline_policy_block_appears_only_when_set" {
  command = plan

  variables {
    iam_role_optional = {
      name = "svc-role"
      inline_policy = {
        name   = "inline"
        policy = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
      }
    }
  }

  assert {
    condition     = length(aws_iam_role.iam_role.inline_policy) == 1
    error_message = "Setting inline_policy must render exactly one inline_policy block."
  }
}
