mock_provider "aws" {}

variables {
  role       = "app-role"
  policy_arn = "arn:aws:iam::123456789012:policy/ReadOnly"
}

run "both_inputs_reach_the_resource" {
  command = plan

  assert {
    condition     = aws_iam_role_policy_attachment.iam_role_policy_attachment.role == "app-role"
    error_message = "role must be passed through unmodified."
  }

  assert {
    condition     = aws_iam_role_policy_attachment.iam_role_policy_attachment.policy_arn == var.policy_arn
    error_message = "policy_arn must be passed through unmodified."
  }
}
