resource "aws_iam_policy" "policy" {
  # Required parameters for the IAM policy
  policy = var.policy
  # Optional parameters for the IAM policy
  description = var.iam_policy_optional.description
  name_prefix = var.iam_policy_optional.name_prefix
  name        = var.iam_policy_optional.name
  path        = var.iam_policy_optional.path
  tags        = var.iam_policy_optional.tags

}