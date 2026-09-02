mock_provider "aws" {}

variables {
  policy = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
}

run "policy_document_is_passed_through" {
  command = plan

  assert {
    condition     = aws_iam_policy.policy.policy == var.policy
    error_message = "The policy document must reach the resource unmodified."
  }
}

run "optionals_default_to_null" {
  command = plan

  # name/name_prefix are Optional+Computed, so they are unknown at plan when
  # unset - description is a plain Optional and is a fair check that the
  # default {} really does leave everything unset.
  assert {
    condition     = aws_iam_policy.policy.description == null
    error_message = "With iam_policy_optional defaulted, description must stay null."
  }
}

run "name_and_path_flow_through" {
  command = plan

  variables {
    iam_policy_optional = {
      name        = "read-only"
      path        = "/team/"
      description = "Read-only access"
    }
  }

  assert {
    condition     = aws_iam_policy.policy.name == "read-only"
    error_message = "name must come from iam_policy_optional."
  }

  assert {
    condition     = aws_iam_policy.policy.path == "/team/"
    error_message = "path must come from iam_policy_optional."
  }
}
