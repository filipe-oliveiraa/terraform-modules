resource "aws_iam_role" "iam_role" {
  # Required parameters
  assume_role_policy = var.assume_role_policy

  #optional parameters
  description           = var.iam_role_optional.description
  force_detach_policies = var.iam_role_optional.force_detach_policies
  max_session_duration  = var.iam_role_optional.max_session_duration
  name                  = var.iam_role_optional.name
  name_prefix           = var.iam_role_optional.name_prefix
  path                  = var.iam_role_optional.path
  permissions_boundary  = var.iam_role_optional.permissions_boundary
  tags                  = var.iam_role_optional.tags

  dynamic "inline_policy" {
    for_each = var.iam_role_optional.inline_policy != null ? [1] : []
    content {
      name   = var.iam_role_optional.inline_policy.name
      policy = var.iam_role_optional.inline_policy.policy
    }
  }
}

