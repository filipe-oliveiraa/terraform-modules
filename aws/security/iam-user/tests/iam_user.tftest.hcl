mock_provider "aws" {}

variables {
  name = "ci-bot"
}

run "name_is_required_and_passed_through" {
  command = plan

  assert {
    condition     = aws_iam_user.iam_user.name == "ci-bot"
    error_message = "name must reach the resource unmodified."
  }
}

run "force_destroy_defaults_to_null_not_true" {
  command = plan

  # Worth asserting explicitly: force_destroy silently deletes a user's access
  # keys, so it must never be on unless the caller asked for it.
  assert {
    condition     = aws_iam_user.iam_user.force_destroy != true
    error_message = "force_destroy must not default to true - it deletes access keys without asking."
  }
}

run "optionals_flow_through" {
  command = plan

  variables {
    iam_user_optional = {
      path                 = "/bots/"
      permissions_boundary = "arn:aws:iam::123456789012:policy/Boundary"
      tags                 = { Team = "platform" }
    }
  }

  assert {
    condition     = aws_iam_user.iam_user.path == "/bots/"
    error_message = "path must come from iam_user_optional."
  }

  assert {
    condition     = aws_iam_user.iam_user.permissions_boundary == "arn:aws:iam::123456789012:policy/Boundary"
    error_message = "permissions_boundary must come from iam_user_optional."
  }
}
