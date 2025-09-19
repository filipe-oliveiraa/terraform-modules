resource "aws_iam_policy_attachment" "iam_policy_attachment" {
  # Required parameters
  name       = var.name
  policy_arn = var.policy_arn

  # Optional parameters
  users  = var.iam_policy_attachment_optional.users
  roles  = var.iam_policy_attachment_optional.roles
  groups = var.iam_policy_attachment_optional.groups

}
