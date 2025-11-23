resource "aws_iam_user" "iam_user" {
  # Required parameters
  name = var.name

  # Optional parameters
  path                 = var.iam_user_optional.path
  permissions_boundary = var.iam_user_optional.permissions_boundary
  force_destroy        = var.iam_user_optional.force_destroy
  tags                 = var.iam_user_optional.tags
}
