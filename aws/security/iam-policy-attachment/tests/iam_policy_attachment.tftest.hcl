mock_provider "aws" {}

variables {
  name       = "read-only-everywhere"
  policy_arn = "arn:aws:iam::123456789012:policy/ReadOnly"

  iam_policy_attachment_optional = {
    roles = ["app-role"]
  }
}

run "required_inputs_reach_the_resource" {
  command = plan

  assert {
    condition     = aws_iam_policy_attachment.iam_policy_attachment.policy_arn == var.policy_arn
    error_message = "policy_arn must be passed through unmodified."
  }

  assert {
    condition     = aws_iam_policy_attachment.iam_policy_attachment.name == "read-only-everywhere"
    error_message = "name must be passed through unmodified."
  }
}

run "all_three_target_kinds_flow_through" {
  command = plan

  variables {
    iam_policy_attachment_optional = {
      roles  = ["app-role"]
      users  = ["ci-bot"]
      groups = ["admins"]
    }
  }

  assert {
    condition     = contains(aws_iam_policy_attachment.iam_policy_attachment.roles, "app-role")
    error_message = "roles must come from iam_policy_attachment_optional."
  }

  assert {
    condition     = contains(aws_iam_policy_attachment.iam_policy_attachment.users, "ci-bot")
    error_message = "users must come from iam_policy_attachment_optional."
  }

  assert {
    condition     = contains(aws_iam_policy_attachment.iam_policy_attachment.groups, "admins")
    error_message = "groups must come from iam_policy_attachment_optional."
  }
}

# Regression test. This module used to accept a call with no target at all: it
# planned cleanly and only failed at apply with the provider's own
# "one of groups,roles,users must be specified". A variable validation now
# rejects it at plan time, and this keeps it that way.
run "no_target_is_rejected_at_plan_time" {
  command = plan

  variables {
    iam_policy_attachment_optional = {}
  }

  expect_failures = [
    var.iam_policy_attachment_optional,
  ]
}
