# Refer to https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html#idp_oidc_Create_GitHub


resource "aws_iam_openid_connect_provider" "this" {
  count = var.create_oidc_provider ? 1 : 0

  url             = var.oidc_provider_url
  client_id_list  = var.oidc_client_ids
  thumbprint_list = var.oidc_thumbprints
  tags            = var.tags
}

resource "aws_iam_role" "github_oidc_role" {
  name                 = var.role_name
  path                 = var.role_path
  description          = var.role_description
  max_session_duration = var.max_session_duration
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
  tags                 = var.tags
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.github_oidc_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline" {
  for_each = var.inline_policies

  name   = each.key
  role   = aws_iam_role.github_oidc_role.id
  policy = each.value
}
